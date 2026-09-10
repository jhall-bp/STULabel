import Foundation
import STULabelSwift
import Testing
import UIKit

nonisolated private final class TileDrawObservations: @unchecked Sendable {
  private let lock = NSLock()
  private var values: [UITraitCollection] = []
  private var shouldHold = false
  let started = DispatchSemaphore(value: 0)
  let resume = DispatchSemaphore(value: 0)
  let finished = DispatchSemaphore(value: 0)

  func dynamicColor() -> UIColor {
    UIColor { traits in
      self.record()
      return traits.userInterfaceStyle == .dark ? .red : .white
    }
  }

  func record() {
    lock.lock()
    values.append(UITraitCollection.current)
    let hold = shouldHold
    shouldHold = false
    lock.unlock()
    if hold {
      started.signal()
      _ = resume.wait(timeout: .now() + 10)
      finished.signal()
    }
  }

  func take() -> [UITraitCollection] {
    lock.lock()
    defer { lock.unlock() }
    let result = values
    values.removeAll()
    return result
  }

  func holdNextDraw() {
    lock.lock()
    shouldHold = true
    lock.unlock()
  }
}

@MainActor
struct TiledRenderingTraitsTests {
  @Test(arguments: [false, true], [false, true])
  func `Drawing uses target traits after the parent display scope ends`(
    tiled: Bool, customDrawing: Bool
  ) throws {
    print("Rendering traits runtime: \(ProcessInfo.processInfo.operatingSystemVersionString)")
    let observations = TileDrawObservations()
    let color = observations.dynamicColor()
    let layer = STULabelLayer()
    layer.contentsScale = 1
    layer.bounds = CGRect(x: 0, y: 0, width: 200, height: tiled ? 6000 : 100)
    layer.maximumNumberOfLines = 0
    layer.attributedText = NSAttributedString(
      string: String(repeating: "Line of text\n", count: tiled ? 200 : 1),
      attributes: [.font: UIFont.systemFont(ofSize: 20), .foregroundColor: color])
    if customDrawing {
      layer.drawingBlock = { parameters in
        observations.record()
        parameters.draw()
      }
    }

    let ambient = UITraitCollection(userInterfaceStyle: .light)
    var previousFrame: STUTextFrame?
    for style in [UIUserInterfaceStyle.dark, .light, .dark] {
      let target = UITraitCollection { traits in
        traits.userInterfaceStyle = style
        traits.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
        traits.layoutDirection = .rightToLeft
        traits.horizontalSizeClass = .compact
        traits.displayScale = 1
      }
      layer.renderingTraitCollection = target
      ambient.performAsCurrent {
        layer.display()
      }
      let frame = layer.textFrame.textFrame
      if let previousFrame {
        #expect(frame === previousFrame)
      }
      previousFrame = frame
      if tiled {
        let tiles = try #require(layer.sublayers?.first)
        #expect(NSStringFromClass(type(of: tiles)).contains("STULabelTiledLayer"))
        _ = observations.take()
        ambient.performAsCurrent {
          tiles.layoutIfNeeded()
          tiles.display()
        }
        let images = (tiles.sublayers ?? []).compactMap { $0.contents }.map { $0 as! CGImage }
        #expect(images.count > 1)
        if style == .dark {
          #expect(images.allSatisfy { $0.colorSpace?.model == .rgb })
        }
        let image = try #require(images.first)
        let context = try #require(CGContext(
          data: nil, width: image.width, height: image.height,
          bitsPerComponent: 8, bytesPerRow: image.width * 4,
          space: CGColorSpace(name: CGColorSpace.sRGB)!,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        let bytes = try #require(context.data).assumingMemoryBound(to: UInt8.self)
        let coloredPixels = stride(from: 0, to: context.bytesPerRow * image.height, by: 4)
          .filter { bytes[$0 + 3] > 128 }
        #expect(!coloredPixels.isEmpty)
        #expect(coloredPixels.allSatisfy {
          style == .dark
            ? bytes[$0] > 100 && bytes[$0 + 1] < 10 && bytes[$0 + 2] < 10
            : bytes[$0] > 100 && bytes[$0 + 1] > 100 && bytes[$0 + 2] > 100
        })
      }
      let draws = observations.take()
      #expect(!draws.isEmpty)
      #expect(draws.allSatisfy {
        $0.userInterfaceStyle == style
          && $0.preferredContentSizeCategory == .accessibilityExtraExtraExtraLarge
          && $0.layoutDirection == .rightToLeft
          && $0.horizontalSizeClass == .compact
      })
      #expect(layer.textFrame.textFrame === frame)
    }
  }

  @Test
  func `Changing target traits abandons an in flight tile generation`() throws {
    let observations = TileDrawObservations()
    let viewport = CALayer()
    viewport.bounds = CGRect(x: 0, y: 0, width: 200, height: 1800)
    viewport.masksToBounds = true
    let layer = STULabelLayer()
    layer.frame = CGRect(x: 0, y: 0, width: 200, height: 6000)
    layer.contentsScale = 1
    layer.maximumNumberOfLines = 0
    layer.attributedText = NSAttributedString(
      string: String(repeating: "Line of text\n", count: 200),
      attributes: [.font: UIFont.systemFont(ofSize: 20), .foregroundColor: UIColor.label])
    layer.drawingBlock = { parameters in
      observations.record()
      parameters.draw()
    }
    layer.renderingTraitCollection = UITraitCollection(userInterfaceStyle: .dark)
    viewport.addSublayer(layer)
    layer.display()
    let tiles = try #require(layer.sublayers?.first)
    #expect(NSStringFromClass(type(of: tiles)).contains("STULabelTiledLayer"))
    tiles.layoutIfNeeded()
    tiles.display()
    _ = observations.take()

    observations.holdNextDraw()
    defer { observations.resume.signal() }
    viewport.bounds.origin.y = 1
    tiles.setNeedsLayout()
    tiles.layoutIfNeeded()
    tiles.display()
    try #require(observations.started.wait(timeout: .now() + 3) == .success)
    let oldDraws = observations.take()
    #expect(!oldDraws.isEmpty)
    #expect(oldDraws.allSatisfy { $0.userInterfaceStyle == .dark })

    layer.renderingTraitCollection = UITraitCollection(userInterfaceStyle: .light)
    #expect((tiles.sublayers ?? []).allSatisfy { $0.contents == nil })
    observations.resume.signal()
    try #require(observations.finished.wait(timeout: .now() + 3) == .success)
    layer.display()
    tiles.layoutIfNeeded()
    tiles.display()
    let newDraws = observations.take()
    #expect(!newDraws.isEmpty)
    #expect(newDraws.allSatisfy { $0.userInterfaceStyle == .light })
    #expect((tiles.sublayers ?? []).contains { $0.contents != nil })
  }
}
