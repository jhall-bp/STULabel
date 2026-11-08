import CoreText
import STULabelSwift
import Testing

@MainActor
struct TextRenderingParityTests {
  private let size = CGSize(width: 300, height: 120)

  enum FontTransform: CaseIterable {
    case identity, shear, rotation, translation

    var matrix: CGAffineTransform {
      switch self {
      case .identity: .identity
      case .shear: CGAffineTransform(a: 1, b: 0, c: 0.3, d: 1, tx: 0, ty: 0)
      case .rotation: CGAffineTransform(rotationAngle: 0.1).scaledBy(x: 0.9, y: 1.1)
      case .translation: CGAffineTransform(translationX: 3, y: 2)
      }
    }
  }

  private func text(strokeWidth: CGFloat, transform: FontTransform = .shear) -> NSAttributedString {
    let descriptor = UIFont.systemFont(ofSize: 28).fontDescriptor.withMatrix(transform.matrix)
    return NSAttributedString(string: "Affine ffi 123", attributes: [
      .font: UIFont(descriptor: descriptor, size: 28),
      .foregroundColor: UIColor.black, .strokeColor: UIColor.black, .strokeWidth: strokeWidth,
    ])
  }

  private func pixels(_ draw: (CGContext) -> Void) throws -> Data {
    let context = try #require(CGContext(
      data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8,
      bytesPerRow: Int(size.width) * 4, space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1, y: -1)
    draw(context)
    return Data(bytes: try #require(context.data), count: context.bytesPerRow * context.height)
  }

  @Test(arguments: [CGFloat(0), -3], FontTransform.allCases)
  func fontMatrixMatchesCoreTextAcrossDrawingPaths(strokeWidth: CGFloat, transform: FontTransform) throws {
    let string = text(strokeWidth: strokeWidth, transform: transform)
    let frame = STUTextFrame(
      STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
      size: size, displayScale: 1)
    let origin = CGPoint(x: 20, y: 20)
    let baseline = try #require(frame.lines.first).baselineOrigin
    let reference = try pixels { context in
      context.translateBy(x: origin.x + baseline.x, y: origin.y + baseline.y)
      context.scaleBy(x: 1, y: -1)
      context.textMatrix = .identity
      context.textPosition = .zero
      CTLineDraw(CTLineCreateWithAttributedString(string), context)
    }
    #expect(reference.contains { $0 != 0 })
    for drawingPath in 0..<3 {
      let options = STUTextFrame.DrawingOptions()
      if drawingPath == 1 { options.overrideTextColor = .black }
      if drawingPath == 2 {
        options.highlightRange = STUTextRange(range: NSRange(0..<6), type: .rangeInOriginalString)
        options.highlightStyle = STUTextHighlightStyle { $0.textColor = .black }
      }
      let bounds = frame.imageBounds(frameOrigin: origin, displayScale: 1, options: options)
      let actual = try pixels { context in
        // An image sized to the advertised bounds must retain every rendered pixel.
        context.clip(to: bounds.integral.insetBy(dx: -1, dy: -1))
        frame.draw(at: origin, in: context, contextBaseCTM_d: 1,
                   pixelAlignBaselines: false, options: options)
      }
      let unclipped = try pixels { context in
        frame.draw(at: origin, in: context, contextBaseCTM_d: 1,
                   pixelAlignBaselines: false, options: options)
      }
      #expect(actual == unclipped, "Image bounds for path: \(drawingPath)")
      #expect(unclipped == reference, "Drawing path: \(drawingPath)")
    }
  }

  @Test(arguments: FontTransform.allCases)
  func partialLigatureHighlightPreservesTransformedGlyphs(transform: FontTransform) throws {
    let font = try #require(UIFont(name: "HoeflerText-Regular", size: 28))
    let string = NSAttributedString(string: "ffi", attributes: [
      .font: UIFont(descriptor: font.fontDescriptor.withMatrix(transform.matrix), size: 28),
      .foregroundColor: UIColor.black,
    ])
    let line = CTLineCreateWithAttributedString(string)
    #expect(CTLineGetGlyphCount(line) == 1)
    let frame = STUTextFrame(STUShapedString(string), size: size, displayScale: 1)
    let origin = CGPoint(x: 20, y: 20)
    let baseline = try #require(frame.lines.first).baselineOrigin
    let cuts = [0, origin.x + baseline.x + CTLineGetOffsetForStringIndex(line, 1, nil),
                origin.x + baseline.x + CTLineGetOffsetForStringIndex(line, 2, nil), size.width]
    // Separately clipped pieces have different edge coverage from one unclipped draw.
    // Use Core Text's caret positions and draw each piece to reproduce that compositing.
    let reference = try pixels { context in
      for (left, right) in zip(cuts, cuts.dropFirst()) {
        context.saveGState()
        context.clip(to: CGRect(x: left, y: 0, width: right - left, height: size.height))
        context.translateBy(x: origin.x + baseline.x, y: origin.y + baseline.y)
        context.scaleBy(x: 1, y: -1)
        context.textMatrix = .identity
        context.textPosition = .zero
        CTLineDraw(line, context)
        context.restoreGState()
      }
    }
    let options = STUTextFrame.DrawingOptions()
    options.highlightRange = STUTextRange(range: NSRange(1..<2), type: .rangeInOriginalString)
    options.highlightStyle = STUTextHighlightStyle { $0.textColor = .black }
    let highlighted = try pixels {
      frame.draw(at: origin, in: $0, contextBaseCTM_d: 1, pixelAlignBaselines: false, options: options)
    }
    #expect(reference.contains { $0 != 0 })
    #expect(highlighted == reference)
  }

  @Test(arguments: FontTransform.allCases)
  func underlinesLeaveGapsForTransformedDescenders(transform: FontTransform) throws {
    let plain = NSAttributedString(string: "gypqj", attributes:
      text(strokeWidth: 0, transform: transform).attributes(at: 0, effectiveRange: nil))
    let underlined = NSMutableAttributedString(attributedString: plain)
    underlined.addAttributes([
      .underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: UIColor.red,
    ], range: NSRange(0..<underlined.length))
    let origin = CGPoint(x: 20, y: 20)
    func render(_ string: NSAttributedString) throws -> Data {
      let frame = STUTextFrame(STUShapedString(string), size: size, displayScale: 1)
      return try pixels {
        frame.draw(at: origin, in: $0, contextBaseCTM_d: 1, pixelAlignBaselines: false)
      }
    }
    let glyphs = try render(plain)
    let decorated = try render(underlined)
    let pixelOffsets = stride(from: 0, to: glyphs.count, by: 4)
    #expect(pixelOffsets.contains { decorated[$0] > 0 }) // The red underline is present.
    #expect(pixelOffsets.filter { glyphs[$0 + 3] > 127 }.allSatisfy { decorated[$0] == 0 })
  }

  @Test(arguments: FontTransform.allCases)
  func asyncPrerenderingPreservesTransformedAndStrokedGlyphs(transform: FontTransform) async throws {
    let traits = UITraitCollection {
      $0.displayScale = 1
      $0.userInterfaceStyle = .light
    }
    let string = text(strokeWidth: -3, transform: transform)
    let synchronous = STULabelLayer()
    synchronous.renderingTraitCollection = traits
    synchronous.contentsScale = 1
    synchronous.bounds = CGRect(origin: .zero, size: size)
    synchronous.attributedText = string
    synchronous.overrideTextColor = .black
    synchronous.display()

    let prerenderer = STULabelPrerenderer(traitCollection: traits)
    prerenderer.displayScale = 1
    prerenderer.attributedText = string
    prerenderer.overrideTextColor = .black
    prerenderer.setSize(size, contentInsets: .zero, options: [])
    let queue = DispatchQueue(label: "STULabelTests.font-matrix")
    prerenderer.renderAsync(on: queue)
    await withCheckedContinuation { continuation in
      queue.async { continuation.resume() }
    }
    let asynchronous = STULabelLayer()
    asynchronous.renderingTraitCollection = traits
    asynchronous.configure(with: prerenderer)
    let expected = try pixels { synchronous.render(in: $0) }
    let actual = try pixels { asynchronous.render(in: $0) }
    #expect(expected.contains { $0 != 0 })
    #expect(actual == expected)
  }
}
