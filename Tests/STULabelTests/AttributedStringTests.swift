import CoreText
import STULabelSwift
import Testing

@MainActor
struct AttributedStringTests {
  @Test
  func scopedRoundTripPreservesAttributesAndAttachmentLayout() throws {
    let font = UIFont.systemFont(ofSize: 18)
    let background = STUBackgroundAttribute { $0.color = .yellow }
    let paragraph = STUParagraphStyle { $0.firstLineOffset = .offsetOfFirstBaselineFromTop(30) }
    let truncation = STUTruncationScope(maximumNumberOfLines: 1)
    let attachment = STUTextAttachment(
      width: 24, ascent: 16, descent: 4, leading: 0, imageBounds: .zero,
      colorInfo: [], stringRepresentation: "star")
    let source = NSMutableAttributedString(string: "Link \u{FFFC}\u{FFFC}", attributes: [
      .font: font, .stuBackground: background, .stuParagraphStyle: paragraph,
      .stuTruncationScope: truncation, .stuHyphenationLocaleIdentifier: "de_DE",
      .accessibilitySpeechLanguage: "de-DE",
    ])
    let url = try #require(URL(string: "https://example.com/details"))
    source.addAttribute(.link, value: url, range: NSRange(location: 0, length: 4))
    source.addAttribute(.stuAttachment, value: attachment, range: NSRange(location: 5, length: 2))

    let text = try AttributedString(source, including: \.stu)
    #expect(text.stuBackground == background)
    #expect(text.stuParagraphStyle == paragraph)
    #expect(text.stuTruncationScope === truncation)
    #expect(text.stuHyphenationLocaleIdentifier == "de_DE")
    let restored = try NSAttributedString(text, including: \.stu)
    #expect(restored.attribute(.link, at: 0, effectiveRange: nil) as? URL == url)
    #expect(restored.attribute(.accessibilitySpeechLanguage, at: 0, effectiveRange: nil) as? String == "de-DE")
    for index in [5, 6] {
      #expect(restored.attribute(.stuAttachment, at: index, effectiveRange: nil) as? STUTextAttachment === attachment)
    }

    let frame = STUTextFrame(
      STUShapedString(restored, defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 300, height: 100), displayScale: 1)
    let prefix = CTLineCreateWithAttributedString(NSAttributedString(
      string: "Link ", attributes: [.font: font]))
    let line = try #require(frame.lines.first)
    #expect(abs(line.width - CGFloat(CTLineGetTypographicBounds(prefix, nil, nil, nil)) - 48) < 0.001)
    #expect(line.baselineOrigin.y == 30)

    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
    label.attributedText = restored
    label.layer.display()
    let element = try #require(label.accessibilityElement.accessibilityElements.first as? UIAccessibilityElement)
    #expect(element.accessibilityLabel == "Link starstar")
    #expect(label.links.count == 1)
    #expect(label.links[0].rangeInOriginalString == NSRange(location: 0, length: 4))

    let context = try #require(CGContext(
      data: nil, width: 300, height: 100, bitsPerComponent: 8, bytesPerRow: 1200,
      space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
    context.translateBy(x: 0, y: 100)
    context.scaleBy(x: 1, y: -1)
    frame.draw(in: context, contextBaseCTM_d: 1, pixelAlignBaselines: true)
    let pixels = Data(bytes: try #require(context.data), count: 120000)
    #expect(pixels.contains { $0 != 0 })
  }

  @Test
  func typedAttachmentsDoNotSpreadToInsertedText() throws {
    let attachment = STUTextAttachment(
      width: 24, ascent: 16, descent: 4, leading: 0, imageBounds: .zero,
      colorInfo: [], stringRepresentation: "star")
    var text = AttributedString("\u{FFFC}")
    text.stuAttachment = attachment
    text.stuHyphenationLocaleIdentifier = "de_DE"
    text.characters.append(contentsOf: "x")
    let restored = try NSAttributedString(text, including: \.stu)
    #expect(restored.attribute(.stuAttachment, at: 0, effectiveRange: nil) as? STUTextAttachment === attachment)
    #expect(restored.attribute(.stuAttachment, at: 1, effectiveRange: nil) == nil)
    #expect(restored.attribute(.stuHyphenationLocaleIdentifier, at: 1, effectiveRange: nil) as? String == "de_DE")
  }
}
