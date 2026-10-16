import Foundation
import STULabelSwift
import Testing
import UIKit

nonisolated private struct PreviewAccentTrait: UITraitDefinition {
  static let defaultValue = 0
}

nonisolated private final class RenderingObservations: @unchecked Sendable {
  private let lock = NSLock()
  private var values: [(scale: CGFloat, traits: UITraitCollection)] = []

  func draw(_ parameters: STULabelDrawingBlockParameters) {
    lock.withLock {
      values.append((abs(parameters.context.ctm.a), UITraitCollection.current))
    }
    parameters.draw()
  }

  func take() -> [(scale: CGFloat, traits: UITraitCollection)] {
    lock.withLock {
      let result = values
      values.removeAll()
      return result
    }
  }
}

@MainActor
struct RenderingStateTests {
  @Test(arguments: [false, true])
  func replacingPreparedContentUsesThePrerenderedText(matchingTraits: Bool) {
    let targetTraits = UITraitCollection {
      $0.userInterfaceStyle = .dark
      $0.displayScale = 1
    }
    let sourceTraits = matchingTraits ? targetTraits : UITraitCollection {
      $0.userInterfaceStyle = .light
      $0.displayScale = 1
    }
    let layer = STULabelLayer()
    layer.renderingTraitCollection = targetTraits
    layer.text = "Previous content"
    // Preparing text without displaying it is useful during a cell's sizing pass.
    _ = layer.shapedText

    let prerenderer = STULabelPrerenderer(traitCollection: sourceTraits)
    prerenderer.attributedText = NSAttributedString(string: "Replacement content")
    prerenderer.setSize(CGSize(width: 300, height: 80), contentInsets: .zero, options: [])
    prerenderer.render()
    layer.configure(with: prerenderer)

    #expect(layer.text == "Replacement content")
    #expect(layer.textFrame.originalAttributedString.string == "Replacement content")
  }

  @Test(arguments: [CGFloat(1), CGFloat(3)])
  func prerenderingReusesImagesAtTheRequestedRasterScale(rasterScale: CGFloat) {
    let traits = UITraitCollection {
      $0.userInterfaceStyle = .dark
      $0.displayScale = 3
    }
    let observations = RenderingObservations()
    let prerenderer = STULabelPrerenderer(traitCollection: traits)
    prerenderer.displayScale = rasterScale
    prerenderer.attributedText = NSAttributedString(string: "Prerendered content")
    prerenderer.setSize(CGSize(width: 300, height: 80), contentInsets: .zero, options: [])
    prerenderer.drawingBlock = { observations.draw($0) }
    prerenderer.render()
    #expect(observations.take().count == 1)

    let layer = STULabelLayer()
    layer.renderingTraitCollection = traits
    layer.configure(with: prerenderer)
    #expect(layer.contentsScale == rasterScale)
    #expect(layer.textFrame.textFrame === prerenderer.textFrame)
    #expect(layer.contents != nil)
    layer.displayIfNeeded()
    #expect(observations.take().isEmpty)
  }

  @Test
  func offscreenTilesKeepTheRequestedRasterScale() throws {
    let observations = RenderingObservations()
    let layer = STULabelLayer()
    layer.contentsScale = 3
    layer.bounds = CGRect(x: 0, y: 0, width: 200, height: 2400)
    layer.maximumNumberOfLines = 0
    layer.attributedText = NSAttributedString(
      string: String(repeating: "A line of text\n", count: 100),
      attributes: [.font: UIFont.systemFont(ofSize: 20)])
    layer.drawingBlock = { observations.draw($0) }
    layer.drawingBlockImageBounds = .viewBounds
    layer.display()
    let tiledContent = try #require(layer.sublayers?.first)
    _ = observations.take()
    tiledContent.layoutIfNeeded()
    tiledContent.display()

    let draws = observations.take()
    #expect(!draws.isEmpty)
    #expect(draws.allSatisfy { $0.scale == 3 })
  }

  @Test
  func linkPreviewDrawingKeepsTheSourceEnvironment() throws {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 240, height: 120))
    let controller = UIViewController()
    window.rootViewController = controller
    window.makeKeyAndVisible()
    defer { window.isHidden = true }
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
    label.overrideUserInterfaceStyle = .dark
    label.traitOverrides[PreviewAccentTrait.self] = 7
    controller.view.addSubview(label)
    label.attributedText = NSAttributedString(
      string: "Link",
      attributes: [.font: UIFont.systemFont(ofSize: 20),
                   .link: URL(string: "https://example.com")!])
    let observations = RenderingObservations()
    label.drawingBlock = { observations.draw($0) }
    label.layoutIfNeeded()
    label.layer.display()
    let sourceTraits = label.traitCollection
    let preview = try #require(label.targetedPreview(for: label.links[0], dragItem: nil))
    _ = observations.take()

    let ambientTraits = UITraitCollection {
      $0.userInterfaceStyle = .light
      $0.displayScale = 1
      $0[PreviewAccentTrait.self] = 9
    }
    ambientTraits.performAsCurrent {
      _ = UIGraphicsImageRenderer(size: preview.view.bounds.size).image { context in
        preview.view.layer.render(in: context.cgContext)
      }
      #expect(UITraitCollection.current.userInterfaceStyle == .light)
      #expect(UITraitCollection.current[PreviewAccentTrait.self] == 9)
    }

    let draws = observations.take()
    #expect(!draws.isEmpty)
    // UIKit's performAsCurrent may add private traits, so compare rendering dependencies
    // directly rather than requiring equality of the entire collection.
    for draw in draws {
      #expect(draw.traits.userInterfaceStyle == .dark)
      #expect(draw.traits[PreviewAccentTrait.self] == 7)
      #expect(draw.traits.displayScale == sourceTraits.displayScale)
      #expect(draw.traits.displayGamut == sourceTraits.displayGamut)
      #expect(draw.traits.layoutDirection == sourceTraits.layoutDirection)
      #expect(draw.traits.preferredContentSizeCategory == sourceTraits.preferredContentSizeCategory)
      #expect(draw.traits.accessibilityContrast == sourceTraits.accessibilityContrast)
      #expect(draw.traits.legibilityWeight == sourceTraits.legibilityWeight)
      #expect(draw.traits.userInterfaceLevel == sourceTraits.userInterfaceLevel)
      #expect(draw.traits.horizontalSizeClass == sourceTraits.horizontalSizeClass)
      #expect(draw.traits.verticalSizeClass == sourceTraits.verticalSizeClass)
    }
  }
}
