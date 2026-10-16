import STULabelSwift
import Testing

@MainActor
private final class SharedPrerenderDisplayDelegate: NSObject, STULabelLayerDelegate {
  var displayCount = 0

  func labelLayer(_ labelLayer: STULabelLayer, didDisplayTextWith flags: STUTextFrame.Flags,
                  in contentBounds: CGRect) {
    displayCount += 1
  }
}

@MainActor
struct SharedPrerendererLifecycleTests {
  @Test
  func completedSharedPrerenderDoesNotKeepPreviousWaitersWhenLayerIsReused() async throws {
    let firstLayer = STULabelLayer()
    let reusedLayer = STULabelLayer()
    let delegate = SharedPrerenderDisplayDelegate()
    firstLayer.labelLayerDelegate = delegate
    reusedLayer.labelLayerDelegate = delegate
    firstLayer.displaysAsynchronously = true
    reusedLayer.displaysAsynchronously = true

    func prerenderer(_ text: String) -> STULabelPrerenderer {
      let result = STULabelPrerenderer(traitCollection: UITraitCollection.current)
      result.setSize(CGSize(width: 240, height: 80), contentInsets: .zero)
      result.attributedText = NSAttributedString(string: text)
      // Finish rendering now while leaving delivery queued on the main thread.
      result.render(scheduler: { context, function in function(context) })
      return result
    }

    let first = prerenderer("Shared initial render")
    firstLayer.configure(with: first)
    reusedLayer.configure(with: first)
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async { continuation.resume() }
    }
    try #require(delegate.displayCount == 2)

    weak var second: STULabelPrerenderer?
    autoreleasepool {
      let next = prerenderer("Second render")
      second = next
      reusedLayer.configure(with: next)
      // Remove the only waiter before its queued delivery.
      reusedLayer.text = "Replacement"
    }
    #expect(second == nil)
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async { continuation.resume() }
    }

    #expect(delegate.displayCount == 2)
    #expect(firstLayer.text == "Shared initial render")
    #expect(reusedLayer.text == "Replacement")
  }
}
