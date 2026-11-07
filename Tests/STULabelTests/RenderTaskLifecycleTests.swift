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


nonisolated final class LayoutCancellationProbe: @unchecked Sendable {
  let entered = DispatchSemaphore(value: 0)
  let resume = DispatchSemaphore(value: 0)
  private let finished = DispatchSemaphore(value: 0)
  private let lock = NSLock()
  private var calls = 0
  private var cancellationStart: UInt64 = 0
  private var cancellationDuration: UInt64 = 0

  var callCount: Int { lock.withLock { calls } }
  var cancellationNanoseconds: UInt64 { lock.withLock { cancellationDuration } }

  func waitForEntry() -> DispatchTimeoutResult { entered.wait(timeout: .now() + 10) }
  func waitForFinish() -> DispatchTimeoutResult { finished.wait(timeout: .now() + 10) }

  func resumeAfterCancellation() {
    lock.withLock { cancellationStart = DispatchTime.now().uptimeNanoseconds }
    resume.signal()
  }

  // The old task is the last owner after the layer replaces its text and finder.
  // Releasing the finder therefore observes completion without polling or a sleep.
  private final class Lifetime {
    let probe: LayoutCancellationProbe
    init(_ probe: LayoutCancellationProbe) { self.probe = probe }
    deinit {
      probe.lock.withLock {
        probe.cancellationDuration = DispatchTime.now().uptimeNanoseconds - probe.cancellationStart
      }
      probe.finished.signal()
    }
  }

  func makeFinder() -> STULastHyphenationLocationInRangeFinder {
    let lifetime = Lifetime(self)
    return { _, range in
      let probe = lifetime.probe
      let first = probe.lock.withLock {
        probe.calls += 1
        return probe.calls == 1
      }
      if first {
        probe.entered.signal()
        probe.resume.wait()
      }
      return STUHyphenationLocation(index: range.location, hyphen: 45, options: [])
    }
  }
}

@MainActor
func makeCancellableLayoutLayer(_ probe: LayoutCancellationProbe) -> STULabelLayer {
  let paragraph = NSMutableParagraphStyle()
  paragraph.hyphenationFactor = 1
  let layer = STULabelLayer()
  layer.bounds = CGRect(x: 0, y: 0, width: 80, height: 50_000)
  layer.maximumNumberOfLines = 0
  layer.attributedText = NSAttributedString(
    string: String(repeating: "antidisestablishmentarianism ", count: 500),
    attributes: [.font: UIFont(name: "HelveticaNeue", size: 18)!, .paragraphStyle: paragraph])
  layer.lastHyphenationLocationInRangeFinder = probe.makeFinder()
  layer.displaysAsynchronously = true
  return layer
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

  @Test(arguments: [false, true])
  func abandoningWorkCancelsInFlightDrawing(usePrerenderer: Bool) async throws {
    let gate = RenderGate()
    let layer = STULabelLayer()
    var prerenderer: STULabelPrerenderer?
    if usePrerenderer {
      prerenderer = STULabelPrerenderer(traitCollection: UITraitCollection.current)
      prerenderer!.setSize(CGSize(width: 240, height: 80), contentInsets: .zero)
      prerenderer!.attributedText = NSAttributedString(string: "Obsolete render")
      prerenderer!.drawingBlock = { @Sendable parameters in gate.draw(parameters) }
      prerenderer!.renderAsync()
    } else {
      layer.bounds = CGRect(x: 0, y: 0, width: 240, height: 80)
      layer.text = "Obsolete render"
      layer.displaysAsynchronously = true
      layer.drawingBlock = { @Sendable parameters in gate.draw(parameters) }
      layer.display()
    }
    let entered = await Task.detached { gate.waitForEntry() }.value
    defer { gate.resume.signal() }
    try #require(entered == .success)
    prerenderer = nil
    layer.text = "Replacement"
    gate.resume.signal()
    let finished = await Task.detached { gate.waitForFinish() }.value
    try #require(finished == .success)
    #expect(gate.observedCancellation)
  }
  enum DisplayMode: String, CaseIterable, Sendable {
    case synchronous, asynchronous, tiled
  }

  @Test(arguments: DisplayMode.allCases, [false, true])
  func releasedFramesPreserveUncachedLinks(mode: DisplayMode, releaseAfterDisplay: Bool) async throws {
    let layer = STULabelLayer()
    let tiled = mode == .tiled
    layer.bounds = tiled ? CGRect(x: 0, y: 0, width: 200, height: 2400)
                         : CGRect(x: 0, y: 0, width: 240, height: 80)
    layer.contentsScale = 3
    layer.maximumNumberOfLines = 0
    layer.verticalAlignment = .center
    layer.attributedText = NSAttributedString(
      string: tiled ? String(repeating: "A line of text\n", count: 100)
                    : "A link survives frame release",
      attributes: [.font: UIFont.systemFont(ofSize: 20),
                   .link: URL(string: "https://example.com")!])
    layer.releasesTextFrameAfterRendering = !releaseAfterDisplay
    let delegate = RenderDisplayDelegate()
    if mode == .asynchronous {
      layer.labelLayerDelegate = delegate
      layer.displaysAsynchronously = true
    } else if tiled {
      layer.drawingBlock = { $0.draw() }
      layer.drawingBlockImageBounds = .viewBounds
    }
    weak var frame: STUTextFrame?
    autoreleasepool {
      frame = layer.__textFrame
      layer.display()
    }
    if mode == .asynchronous {
      for _ in 0..<500 where delegate.displayCount == 0 {
        try await Task.sleep(for: .milliseconds(10))
      }
      try #require(delegate.displayCount == 1)
    }
    if releaseAfterDisplay {
      layer.releasesTextFrameAfterRendering = true
    }
    #expect((frame != nil) == tiled)
    try #require(layer.links.count == 1)
    let bounds = layer.links[0].bounds
    #expect(!bounds.isEmpty)
    if tiled {
      // Deferred tile drawing still needs the original layout.
      #expect(layer.__textFrame === frame)
    } else {
      // The preserved geometry must still follow a later origin-only change.
      let origin = layer.__textFrameOrigin
      layer.bounds.size.height += 40
      let newOrigin = layer.__textFrameOrigin
      #expect(layer.links[0].bounds == bounds.offsetBy(dx: newOrigin.x - origin.x,
                                                     dy: newOrigin.y - origin.y))
    }
  }

  @Test(arguments: [false, true])
  func replacingTextStopsInFlightLayout(preShaped: Bool) async throws {
    let probe = LayoutCancellationProbe()
    let layer = makeCancellableLayoutLayer(probe)
    if preShaped { _ = layer.shapedText }
    defer {
      layer.text = "Replacement"
      layer.lastHyphenationLocationInRangeFinder = nil
      probe.resume.signal()
    }
    layer.display()
    let entered = await Task.detached { probe.waitForEntry() }.value
    try #require(entered == .success)
    layer.text = "Replacement"
    layer.lastHyphenationLocationInRangeFinder = nil
    probe.resumeAfterCancellation()
    let finished = await Task.detached { probe.waitForFinish() }.value
    try #require(finished == .success)
    #expect(probe.callCount == 1)
    #expect(layer.textFrame.originalAttributedString.string == "Replacement")
  }

}
