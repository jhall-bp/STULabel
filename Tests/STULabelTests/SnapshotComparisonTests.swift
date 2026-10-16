import SnapshotTesting
import Testing
import UIKit

@MainActor
struct SnapshotComparisonTests {
  private func image(grayscale: Bool, value: UInt8, size: Int = 1024) throws -> UIImage {
    let bytesPerPixel = grayscale ? 1 : 3
    let data = Data(repeating: value, count: size * size * bytesPerPixel)
    let provider = try #require(CGDataProvider(data: data as CFData))
    let image = try #require(CGImage(
      width: size, height: size, bitsPerComponent: 8, bitsPerPixel: bytesPerPixel * 8,
      bytesPerRow: size * bytesPerPixel,
      space: grayscale ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
      provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent))
    return UIImage(cgImage: image, scale: 1, orientation: .up)
  }

  @Test(arguments: [true, false])
  func imageMismatchReportsFailureForDifferentPixelFormats(grayscaleReference: Bool) throws {
    // Exercise the failure-reporting path as well as comparison. The PNG round trip
    // may preserve grayscale or RGB24 storage; neither is a packed RGBA8 buffer.
    let reference = try image(grayscale: grayscaleReference, value: 0)
    let failure = try image(grayscale: !grayscaleReference, value: 255)
    let difference = try #require(Diffing<UIImage>.image(scale: 1).diff(reference, failure))
    #expect(!difference.0.isEmpty)
    #expect(difference.1.count == 3)
  }

  @Test
  func perceptualMismatchReportsFailure() throws {
    let reference = try image(grayscale: false, value: 0, size: 2)
    let failure = try image(grayscale: false, value: 255, size: 2)
    let difference = try #require(
      Diffing<UIImage>.image(perceptualPrecision: 0.99, scale: 1).diff(reference, failure))
    #expect(!difference.0.isEmpty)
    #expect(difference.1.count == 3)
  }
}
