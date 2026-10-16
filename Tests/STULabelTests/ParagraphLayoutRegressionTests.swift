import Foundation
import STULabelSwift
import Testing

@MainActor
struct ParagraphLayoutRegressionTests {
  @Test(arguments: [false, true], [false, true])
  func neutralParagraphsPreserveEarlierPunctuationOrder(
    firstParagraphIsRightToLeft: Bool, hasParagraphStyle: Bool
  ) throws {
    let firstParagraph = firstParagraphIsRightToLeft ? "אבג!" : "Hello!"
    let text = firstParagraph + "\n!!!\n???"
    var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18)]
    if hasParagraphStyle {
      attributes[.paragraphStyle] = NSParagraphStyle.default
    }
    let frame = STUTextFrame(
      STUShapedString(
        NSAttributedString(string: text, attributes: attributes),
        defaultBaseWritingDirection: firstParagraphIsRightToLeft ? .leftToRight : .rightToLeft),
      size: CGSize(width: 300, height: 200), displayScale: 0)
    try #require(frame.lines.count == 3)

    func bounds(ofCharacterAt index: Int) -> CGRect {
      frame.rects(
        for: frame.range(forRangeInOriginalString: NSRange(location: index, length: 1)),
        frameOrigin: .zero
      ).bounds
    }
    let firstLetter = bounds(ofCharacterAt: 0)
    let punctuation = bounds(ofCharacterAt: firstParagraph.utf16.count - 1)
    if firstParagraphIsRightToLeft {
      #expect(punctuation.maxX <= firstLetter.minX)
    } else {
      #expect(firstLetter.maxX <= punctuation.minX)
    }
  }

  @Test(arguments: [STUTextLayoutMode.default, .textKit], [CGFloat(0), 4])
  func descendingFontSizesFitTheirCombinedLineHeights(
    layoutMode: STUTextLayoutMode, paragraphLineSpacing: CGFloat
  ) throws {
    let headingFont = UIFont.systemFont(ofSize: 40)
    let bodyFont = UIFont.systemFont(ofSize: 10)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = paragraphLineSpacing
    let text = NSMutableAttributedString(
      string: "A\n", attributes: [.font: headingFont, .paragraphStyle: paragraphStyle])
    text.append(NSAttributedString(string: "b", attributes: [.font: bodyFont]))
    // UIKit font metrics provide room for both lines independently of STUTextFrame's measurement.
    let height = headingFont.lineHeight + bodyFont.lineHeight + paragraphLineSpacing + 1
    let frame = STUTextFrame(
      STUShapedString(text, defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 300, height: height), displayScale: 0,
      options: STUTextFrameOptions { $0.textLayoutMode = layoutMode })

    #expect(frame.lines.count == 2)
    #expect(!frame.flags.contains(.isTruncated))
    #expect(frame.truncatedAttributedString.string == text.string)
  }
}
