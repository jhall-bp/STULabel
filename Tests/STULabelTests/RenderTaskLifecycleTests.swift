import STULabelSwift
import Testing

nonisolated private final class RenderGate: @unchecked Sendable {
  let entered = DispatchSemaphore(value: 0)
  let resume = DispatchSemaphore(value: 0)
  let finished = DispatchSemaphore(value: 0)
  private let lock = NSLock()
  private var cancelled = false

  var observedCancellation: Bool { lock.withLock { cancelled } }

  func waitForEntry() -> DispatchTimeoutResult { entered.wait(timeout: .now() + 10) }
  func waitForFinish() -> DispatchTimeoutResult { finished.wait(timeout: .now() + 10) }

  func draw(_ parameters: STULabelDrawingBlockParameters) {
    entered.signal()
    // The test controls this pause and always releases it in defer. A deadline here can
    // expire while unrelated tests occupy the main actor, before cancellation is requested.
    resume.wait()
    let value = parameters.cancellationFlag.map { STUCancellationFlagGetValue($0) } ?? false
    lock.withLock { cancelled = value }
    parameters.draw()
    finished.signal()
  }
}

@MainActor
private final class RenderDisplayDelegate: NSObject, STULabelLayerDelegate {
  var displayCount = 0
  func labelLayer(_ labelLayer: STULabelLayer,
                  shouldDisplayAsynchronouslyWithProposedValue proposedValue: Bool) -> Bool { true }
  func labelLayer(_ labelLayer: STULabelLayer, didDisplayTextWith flags: STUTextFrame.Flags,
                  in contentBounds: CGRect) { displayCount += 1 }
}

@MainActor
struct RenderTaskLifecycleTests {
  @Test(arguments: [false, true])
  func publishedPrerenderLayoutSurvivesReleasePreferences(releaseShapedText: Bool) throws {
    let prerenderer = STULabelPrerenderer(traitCollection: UITraitCollection.current)
    prerenderer.setSize(CGSize(width: 240, height: 80), contentInsets: .zero)
    prerenderer.attributedText = NSAttributedString(string: "Published layout")
    prerenderer.releasesTextFrameAfterRendering = true
    prerenderer.releasesShapedStringAfterRendering = releaseShapedText
    // Finish the worker without allowing its main-queue handoff to execute yet.
    prerenderer.render(scheduler: { context, function in function(context) })
    let layer = STULabelLayer()
    layer.configure(with: prerenderer)
    let frame = try #require(layer.__textFrame as STUTextFrame?)
    #expect(frame.originalAttributedString.string == "Published layout")
  }

  @Test(arguments: [false, true])
  func asynchronousRedrawRecreatesReleasedLayout(releaseShapedText: Bool) async throws {
    let layer = STULabelLayer()
    layer.bounds = CGRect(x: 0, y: 0, width: 240, height: 80)
    layer.text = "Redraw after release"
    layer.releasesTextFrameAfterRendering = true
    layer.releasesShapedStringAfterRendering = releaseShapedText
    let delegate = RenderDisplayDelegate()
    layer.labelLayerDelegate = delegate
    layer.displaysAsynchronously = true
    layer.display()
    for _ in 0..<500 where delegate.displayCount == 0 {
      try await Task.sleep(for: .milliseconds(10))
    }
    try #require(delegate.displayCount == 1)
    layer.overrideTextColor = .red
    layer.display()
    for _ in 0..<500 where delegate.displayCount == 1 {
      try await Task.sleep(for: .milliseconds(10))
    }
    #expect(delegate.displayCount == 2)
    #expect(layer.textFrame.originalAttributedString.string == "Redraw after release")
  }

  @Test
  func replacingTextCancelsInFlightDrawing() async throws {
    let layer = STULabelLayer()
    layer.bounds = CGRect(x: 0, y: 0, width: 240, height: 80)
    layer.text = "Obsolete render"
    layer.displaysAsynchronously = true
    let gate = RenderGate()
    layer.drawingBlock = { @Sendable parameters in gate.draw(parameters) }
    layer.display()
    let entered = await Task.detached { gate.waitForEntry() }.value
    defer { gate.resume.signal() }
    try #require(entered == .success)
    layer.text = "Replacement"
    gate.resume.signal()
    let finished = await Task.detached { gate.waitForFinish() }.value
    try #require(finished == .success)
    #expect(gate.observedCancellation)
  }
}
