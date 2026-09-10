import Foundation
import STULabelSwift
import Testing
import UIKit

nonisolated private struct RenderAccentTrait: UITraitDefinition {
  static let defaultValue = 0
}

nonisolated private final class EnvironmentDraws: @unchecked Sendable {
  private let lock = NSLock()
  private var traits: [UITraitCollection] = []
  private var hold = false
  var hasDrawn: Bool {
    lock.lock()
    defer { lock.unlock() }
    return !traits.isEmpty
  }
  let resume = DispatchSemaphore(value: 0)

  func suspendNextDraw() {
    lock.lock()
    hold = true
    lock.unlock()
  }

  func draw(_ parameters: STULabelDrawingBlockParameters) {
    lock.lock()
    traits.append(UITraitCollection.current)
    let suspend = hold
    hold = false
    lock.unlock()
    if suspend {
      _ = resume.wait(timeout: .now() + 5)
    }
    parameters.draw()
  }

  func take() -> [UITraitCollection] {
    lock.lock()
    defer { lock.unlock() }
    let result = traits
    traits.removeAll()
    return result
  }
}

@MainActor
private final class EnvironmentDisplayDelegate: NSObject, STULabelDelegate {
  var displays = 0
  func label(_ label: STULabel, didDisplayTextWithFlags flags: STUTextFrame.Flags, in rect: CGRect) {
    displays += 1
  }
}

@MainActor
struct RenderingEnvironmentTests {
  private func makeLabel() -> STULabel {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    label.attributedText = NSAttributedString(
      string: "Target environment", attributes: [.font: UIFont.systemFont(ofSize: 17)])
    // Force the synchronous bitmap path; unattached UIView backing stores may defer drawing.
    let selector = NSSelectorFromString("stu_setAlwaysUsesContentSublayer:")
    let setContentSublayer = unsafeBitCast(
      label.layer.method(for: selector),
      to: (@convention(c) (NSObject, Selector, Bool) -> Void).self)
    setContentSublayer(label.layer, selector, true)
    return label
  }

  @Test
  func `System traits publish one complete environment without font adjustment`() throws {
    print("Rendering environment runtime: \(ProcessInfo.processInfo.operatingSystemVersionString)")
    let parent = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
    let label = makeLabel()
    parent.addSubview(label)
    label.contentScaleFactor = 1
    let draws = EnvironmentDraws()
    label.drawingBlock = { draws.draw($0) }
    label.layer.display()
    let originalFrame = label.textFrame.textFrame

    let changes: [(inout UITraitOverrides) -> Void] = [
      { $0.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge },
      { $0.horizontalSizeClass = .compact },
      { $0.verticalSizeClass = .regular },
      { $0.userInterfaceStyle = .dark },
      { $0.displayGamut = .P3 }
    ]
    for change in changes {
      change(&parent.traitOverrides)
      parent.updateTraitsIfNeeded()
      label.updateTraitsIfNeeded()
      #expect(label.layer.renderingTraitCollection.isEqual(label.traitCollection))
      _ = draws.take()
      label.layer.display()
      let rendered = draws.take()
      #expect(!rendered.isEmpty)
      #expect(rendered.allSatisfy { $0.isEqual(label.traitCollection) })
      #expect(label.textFrame.textFrame === originalFrame)
    }
    parent.traitOverrides.layoutDirection = .rightToLeft
    parent.updateTraitsIfNeeded()
    label.updateTraitsIfNeeded()
    #expect(label.layer.renderingTraitCollection.layoutDirection == .rightToLeft)
    #expect(label.layer.userInterfaceLayoutDirection == .rightToLeft)
    parent.traitOverrides.displayScale = 2
    parent.updateTraitsIfNeeded()
    label.updateTraitsIfNeeded()
    #expect(label.layer.contentsScale == 2)
    #expect(label.layer.renderingTraitCollection.displayScale == 2)

    // A caller's explicit raster scale survives unrelated trait-only changes.
    label.contentScaleFactor = 1
    parent.traitOverrides.userInterfaceStyle = .light
    parent.updateTraitsIfNeeded()
    label.updateTraitsIfNeeded()
    #expect(label.layer.contentsScale == 1)
    label.semanticContentAttribute = .forceLeftToRight
    #expect(label.layer.userInterfaceLayoutDirection == .leftToRight)
  }

  @Test
  func `Custom drawing dependencies invalidate through UIKit registration`() {
    let label = makeLabel()
    let draws = EnvironmentDraws()
    label.drawingBlock = { draws.draw($0) }
    label.registerForTraitChanges([RenderAccentTrait.self]) { (label: STULabel, _) in
      label.setNeedsDisplay()
    }
    label.layer.display()
    let frame = label.textFrame.textFrame
    _ = draws.take()
    label.traitOverrides[RenderAccentTrait.self] = 7
    label.updateTraitsIfNeeded()
    #expect(label.layer.renderingTraitCollection[RenderAccentTrait.self] == 7)
    #expect(label.layer.needsDisplay())
    label.layer.display()
    let rendered = draws.take()
    #expect(!rendered.isEmpty)
    #expect(rendered.allSatisfy { $0[RenderAccentTrait.self] == 7 })
    #expect(label.textFrame.textFrame === frame)
  }

  @Test(arguments: [false, true])
  func `Completed async work is checked against the current view environment`(
    prerendered: Bool
  ) async throws {
    let label = makeLabel()
    let delegate = EnvironmentDisplayDelegate()
    label.delegate = delegate
    label.displaysAsynchronously = true
    let draws = EnvironmentDraws()
    draws.suspendNextDraw()
    defer { draws.resume.signal() }
    if prerendered {
      let prerenderer = STULabelPrerenderer(traitCollection: label.traitCollection)
      prerenderer.attributedText = label.attributedText
      prerenderer.setSize(label.bounds.size, contentInsets: .zero, options: [])
      prerenderer.drawingBlock = { draws.draw($0) }
      prerenderer.renderAsync()
      label.configure(with: prerenderer)
    } else {
      label.drawingBlock = { draws.draw($0) }
      label.layer.display()
    }
    for _ in 0..<200 {
      if draws.hasDrawn { break }
      try await Task.sleep(for: .milliseconds(10))
    }
    try #require(draws.hasDrawn)
    #expect(draws.take().allSatisfy { $0[RenderAccentTrait.self] == 0 })

    // Deliberately omit registration to test the completion boundary independently
    // of invalidation callbacks. No obsolete result may be accepted even in this case.
    label.traitOverrides[RenderAccentTrait.self] = 1
    label.updateTraitsIfNeeded()
    #expect(label.layer.renderingTraitCollection[RenderAccentTrait.self] == 0)
    draws.resume.signal()
    for _ in 0..<200 {
      if label.layer.renderingTraitCollection[RenderAccentTrait.self] == 1 { break }
      try await Task.sleep(for: .milliseconds(10))
    }
    #expect(label.layer.renderingTraitCollection[RenderAccentTrait.self] == 1)
    #expect(delegate.displays == 0)
    label.layer.display()
    for _ in 0..<200 {
      if delegate.displays > 0 { break }
      try await Task.sleep(for: .milliseconds(10))
    }
    #expect(delegate.displays == 1)
    let rendered = draws.take()
    #expect(!rendered.isEmpty)
    #expect(rendered.allSatisfy { $0[RenderAccentTrait.self] == 1 })
  }
}
