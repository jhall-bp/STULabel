// Copyright 2018 Stephan Tolksdorf

import STULabelSwift
import SnapshotTesting
import Testing
import UIKit

@MainActor
@Suite(.snapshots(record: .missing))
struct TextFrameDrawingTests {
  let displayScale: CGFloat = 2

  @Test
  func backgroundTranslationDoesNotDependOnPixelAlignment() throws {
    let frame = STUTextFrame(
      STUShapedString(NSAttributedString(
        string: "Background", attributes: [
          .font: UIFont.systemFont(ofSize: 18), .backgroundColor: UIColor.red,
        ])),
      size: CGSize(width: 200, height: 100), displayScale: 0)
    let origin = CGPoint(x: 10, y: 25)
    let options = STUTextFrame.DrawingOptions()
    options.drawingMode = .onlyBackground
    func render(translatingContext: Bool) throws -> Data {
      let context = try #require(CGContext(
        data: nil, width: 256, height: 100, bitsPerComponent: 8, bytesPerRow: 256 * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
      context.translateBy(x: 0, y: 100)
      context.scaleBy(x: 1, y: -1)
      if translatingContext {
        context.translateBy(x: origin.x, y: origin.y)
      }
      frame.draw(
        at: translatingContext ? .zero : origin, in: context, contextBaseCTM_d: 1,
        pixelAlignBaselines: false, options: options)
      return Data(bytes: try #require(context.data), count: context.bytesPerRow * context.height)
    }
    let translatedContext = try render(translatingContext: true)
    let translatedFrame = try render(translatingContext: false)
    #expect(translatedContext.contains { $0 != 0 })
    #expect(translatedFrame == translatedContext)
  }

  @Test(arguments: [128, 1024])
  func allBackgroundSegmentsDrawAfterBufferGrowth(_ segmentCount: Int) throws {
    let text = NSMutableAttributedString()
    let font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    for index in 0..<segmentCount {
      let background = STUBackgroundAttribute { builder in
        builder.color = index.isMultiple(of: 2) ? .red : .blue
        // Distinct attributes prevent equal colors from becoming one segment.
        builder.edgeInsets = UIEdgeInsets(top: CGFloat(index) / 10000, left: 0, bottom: 0, right: 0)
      }
      text.append(NSAttributedString(string: "M", attributes: [.font: font, .stuBackground: background]))
    }
    let frame = STUTextFrame(
      STUShapedString(text, defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 20000, height: 64), displayScale: 1)
    try #require(frame.lines.count == 1)
    let width = Int(ceil(frame.layoutBounds.maxX)) + 1
    let context = try #require(CGContext(
      data: nil, width: width, height: 64, bitsPerComponent: 8, bytesPerRow: width * 4,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue))
    context.translateBy(x: 0, y: 64)
    context.scaleBy(x: 1, y: -1)
    let options = STUTextFrame.DrawingOptions()
    options.drawingMode = .onlyBackground
    frame.draw(in: context, contextBaseCTM_d: 1, pixelAlignBaselines: true, options: options)
    let bytes = try #require(context.data).assumingMemoryBound(to: UInt8.self)
    let advance = frame.layoutBounds.width / CGFloat(segmentCount)
    let missingSegments = (0..<segmentCount).filter { index in
      let x = Int(frame.layoutBounds.minX + (CGFloat(index) + 0.5) * advance)
      let channel = index.isMultiple(of: 2) ? 0 : 2
      return !(0..<64).contains { y in
        let offset = y * context.bytesPerRow + x * 4
        return bytes[offset + channel] == 255 && bytes[offset + 3] == 255
      }
    }.count
    #expect(missingSegments == 0)
  }

  @Test
  func `Base CTM handling`() {
    let font = UIFont(name: "HelveticaNeue", size: 18)!
    let shadow = NSShadow()
    shadow.shadowOffset = CGSize(width: 8, height: 4)
    shadow.shadowBlurRadius = 2
    let frame = STUTextFrame(
      STUShapedString(
        NSAttributedString(
          string: "G",
          attributes: [
            .font: font,
            .shadow: shadow,
          ])),
      size: CGSize(width: 1000, height: 1000), displayScale: displayScale,
      options: nil)
    let imageSize = CGSize(width: 25, height: 25)

    // Draw with (implicit) contextBaseCTM_d:0 parameter into context created by UIKit.
    do {
      UIGraphicsBeginImageContextWithOptions(imageSize, true, 2)
      let cgContext = UIGraphicsGetCurrentContext()!
      #expect(cgContext.ctm.d == -2)
      UIColor.white.setFill()
      cgContext.fill(CGRect(origin: .zero, size: imageSize))
      frame.draw()
      let image = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      assertSnapshot(of: image, as: .image(perceptualPrecision: 0.99))
    }
    // Draw with explicit contextBaseCTM_d:-2 parameter into context created by UIKit.
    do {
      UIGraphicsBeginImageContextWithOptions(imageSize, true, 2)
      let cgContext = UIGraphicsGetCurrentContext()!
      #expect(cgContext.ctm.d == -2)
      UIColor.white.setFill()
      cgContext.fill(CGRect(origin: .zero, size: imageSize))
      frame.draw(in: cgContext, contextBaseCTM_d: -2, pixelAlignBaselines: true)
      let image = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      assertSnapshot(of: image, as: .image(perceptualPrecision: 0.99))
    }
    // Draw with explicit contextBaseCTM_d:1 parameter into context created with
    // CoreGraphics function.
    do {
      let cgImage = stu_createCGImage(
        size: imageSize, scale: displayScale,
        backgroundColor: UIColor.white.cgColor,
        STUCGImageFormat(.grayscale, [.withoutAlphaChannel]),
        { context in
          #expect(context.ctm.d == -2)
          frame.draw(in: context, contextBaseCTM_d: 1, pixelAlignBaselines: true)
        })!
      let image = UIImage(cgImage: cgImage, scale: displayScale, orientation: .up)
      assertSnapshot(of: image, as: .image(perceptualPrecision: 0.99))
    }
  }

  @Test
  func `Baseline rounding`() {
    let font = UIFont(name: "HelveticaNeue", size: 18.25)!
    let attributedString = NSAttributedString(
      string: "L",
      attributes: [
        .font: font,
        .underlineStyle: NSUnderlineStyle.single.rawValue,
        .backgroundColor: UIColor.red,
      ])
    let frame = STUTextFrame(
      STUShapedString(attributedString),
      size: CGSize(width: 1000, height: 1000), displayScale: 0,
      options: STUTextFrameOptions { (b) in b.textLayoutMode = .textKit })
    let layoutBounds = frame.layoutBounds
    let size = CGSize(width: ceil(layoutBounds.maxX + 2), height: ceil(layoutBounds.maxY + 2))
    do {
      UIGraphicsBeginImageContextWithOptions(size, false, 2)
      let cgContext = UIGraphicsGetCurrentContext()!
      #expect(cgContext.ctm.d == -2)
      cgContext.translateBy(x: -1, y: 1)
      frame.draw(at: CGPoint(x: 1.5, y: -0.25))
      let image = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      // If the rounding doesn't work, the horizontal edges of the underline and the background
      // will be aliased.
      assertSnapshot(of: image, as: .image(perceptualPrecision: 0.99))
    }

    let scaledFrame = STUTextFrame(
      STUShapedString(attributedString),
      size: CGSize(width: layoutBounds.size.width / 2, height: 1000),
      displayScale: 0,
      options: STUTextFrameOptions { (b) in
        b.textLayoutMode = .textKit
        b.minimumTextScaleFactor = 0.1
      })
    let scaledLayoutBounds = scaledFrame.layoutBounds
    do {
      UIGraphicsBeginImageContextWithOptions(
        CGSize(
          width: ceil(scaledLayoutBounds.maxX + 2),
          height: ceil(scaledLayoutBounds.maxY + 2)),
        false, 2)
      let cgContext = UIGraphicsGetCurrentContext()!
      #expect(cgContext.ctm.d == -2)
      cgContext.translateBy(x: -1, y: 1)
      scaledFrame.draw(at: CGPoint(x: 1.5, y: -0.25))
      let image = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext()
      // If the rounding doesn't work, the horizontal edges of the underline and the background
      // will be aliased.
      assertSnapshot(of: image, as: .image, named: "scaled")
    }
  }

  @Test
  func `Drawing into a PDF context`() throws {
    let font = UIFont(name: "HelveticaNeue", size: 18)!
    let attributedString = NSAttributedString(
      string: "Apple",
      attributes: [
        .font: font,
        .underlineStyle: NSUnderlineStyle.single.rawValue,
      ])
    let frame = STUTextFrame(
      STUShapedString(attributedString),
      size: CGSize(width: 1000, height: 1000), displayScale: 0,
      options: STUTextFrameOptions { (b) in b.textLayoutMode = .textKit })
    let m: CGFloat = 2
    let layoutBounds = frame.layoutBounds
    let size = CGSize(
      width: ceil(layoutBounds.maxX + 2 * m),
      height: ceil(layoutBounds.maxY + 2 * m))
    let data = NSMutableData()
    UIGraphicsBeginPDFContextToData(data, CGRect(origin: .zero, size: size), nil)
    UIGraphicsBeginPDFPage()
    let cgContext = try #require(UIGraphicsGetCurrentContext())
    frame.draw(
      at: CGPoint(x: m, y: m),
      in: cgContext, contextBaseCTM_d: 0, pixelAlignBaselines: false)
    UIGraphicsEndPDFContext()

    let pdfDataProvider = try #require(CGDataProvider(data: data))
    let pdfDocument = try #require(CGPDFDocument(pdfDataProvider))
    let pdfPage = try #require(pdfDocument.page(at: 1))

    // Compare generated PDF with reference by comparing images rendered at a high resolution.

    let pdfCGImage = try #require(
      stu_createCGImage(
        size: size, scale: -20,
        backgroundColor: UIColor.white.cgColor,
        STUCGImageFormat(.rgb, [.withoutAlphaChannel]),
        { context in
          context.drawPDFPage(pdfPage)
        }))
    let pdfImage = UIImage(cgImage: pdfCGImage, scale: 1, orientation: .up)

    assertSnapshot(of: pdfImage, as: .image(perceptualPrecision: 0.99))

    // TODO: Replicate this behaviour

    //    let pdfPath = pathRelativeToCurrentSourceDir(
    //                    "ReferenceImages/TextFrameDrawingTests/testDrawingIntoPDFContext.pdf")
    //    let referencePDFPage = CGPDFDocument(URL(fileURLWithPath: pdfPath) as CFURL)!
    //                            .page(at: 1)!
    //    let referencePDFCGImage = stu_createCGImage(size: size, scale: -20,
    //                                                backgroundColor: UIColor.white.cgColor,
    //                                                STUCGImageFormat(.grayscale, [.withoutAlphaChannel]),
    //                                                { context in
    //                                                  context.drawPDFPage(referencePDFPage)
    //                                                })!
    //    let referencePDFImage = UIImage(cgImage: referencePDFCGImage, scale: 1, orientation: .up)

    //    self.checkSnapshotImage(pdfImage, referenceImage: referencePDFImage)
  }
}
