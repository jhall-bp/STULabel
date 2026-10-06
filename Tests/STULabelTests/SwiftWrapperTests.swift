// Copyright 2018 Stephan Tolksdorf

import Foundation
import STULabelSwift
import Testing

@MainActor
struct SwiftWrapperTests {
  let font = UIFont(name: "HelveticaNeue", size: 20)!

  @Test
  func fullySpecifiedTextReassignmentPreservesShapedText() {
    let label = STULabel()
    let text = NSAttributedString(
      string: "Reusable text", attributes: [.font: font, .foregroundColor: UIColor.label])
    label.attributedText = text
    let shaped = label.shapedText
    label.attributedText = text
    #expect(label.shapedText === shaped)

    let mutable = NSMutableAttributedString(attributedString: text)
    label.attributedText = mutable
    mutable.replaceCharacters(in: NSRange(location: 0, length: mutable.length), with: "Changed")
    #expect(label.text == text.string)
  }

  @Test
  func centeredTextUsesTheInsetContentCenter() {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
    label.contentScaleFactor = 1
    label.font = font
    label.text = "Centered"
    label.textAlignment = .center
    label.verticalAlignment = .center
    label.contentInsets = UIEdgeInsets(top: 12, left: 20, bottom: 36, right: 60)
    let bounds = label.layoutInfo.layoutBounds
    #expect(abs(bounds.midX - 130) <= 0.5)
    #expect(abs(bounds.midY - 88) <= 0.5)
  }

  @Test
  func firstAndLastLineMetricsRemainDistinct() {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
    label.maximumNumberOfLines = 0
    let text = NSMutableAttributedString(
      string: "Large\n", attributes: [.font: UIFont.systemFont(ofSize: 40)])
    text.append(NSAttributedString(
      string: "Small", attributes: [.font: UIFont.systemFont(ofSize: 10)]))
    label.attributedText = text
    let info = label.layoutInfo
    #expect(info.lineCount == 2)
    #expect(info.firstLineHeight > 2 * info.lastLineHeight)
  }

  @Test
  func `STULabelSwift re-exports STULabel`() {
    let label = STULabel()
    label.text = "SwiftPM"
    #expect(label.text == "SwiftPM")
  }

  @Test
  func `STULabel uses Dynamic Type body and label color by default`() {
    let label = STULabel()
    let defaultFont = UIFont.preferredFont(forTextStyle: .body)

    #expect(label.font == defaultFont)
    #expect(label.textColor == .label)

    label.text = "Plain text"
    #expect(
      label.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        == defaultFont)
    #expect(
      label.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)
        as? UIColor == .label)

    let attributedText = NSMutableAttributedString(string: "unstyled ")
    let attributedFont = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
    let attributedColor = UIColor.systemRed
    attributedText.append(NSAttributedString(string: "font", attributes: [.font: attributedFont]))
    attributedText.append(
      NSAttributedString(
        string: " color",
        attributes: [.foregroundColor: attributedColor]))
    label.attributedText = attributedText

    #expect(
      label.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        == defaultFont)
    #expect(
      label.attributedText.attribute(.foregroundColor, at: 0, effectiveRange: nil)
        as? UIColor == .label)
    #expect(
      label.attributedText.attribute(.font, at: 9, effectiveRange: nil) as? UIFont
        == attributedFont)
    #expect(
      label.attributedText.attribute(.foregroundColor, at: 9, effectiveRange: nil)
        as? UIColor == .label)
    #expect(
      label.attributedText.attribute(.font, at: 13, effectiveRange: nil) as? UIFont
        == defaultFont)
    #expect(
      label.attributedText.attribute(.foregroundColor, at: 13, effectiveRange: nil)
        as? UIColor == attributedColor)

    let labelFont = UIFont.systemFont(ofSize: 22, weight: .semibold)
    let labelColor = UIColor.systemGreen
    label.font = labelFont
    label.textColor = labelColor

    #expect(
      label.attributedText.attribute(.font, at: 9, effectiveRange: nil) as? UIFont
        == labelFont)
    #expect(
      label.attributedText.attribute(.foregroundColor, at: 13, effectiveRange: nil)
        as? UIColor == labelColor)
  }

  @Test
  func `STULabel uses link color by default`() {
    let label = STULabel()

    #expect(label.layer.overrideLinkColor == label.tintColor)

    label.tintColor = .systemRed
    #expect(label.layer.overrideLinkColor == .systemRed)
  }

  @Test
  func `STULabel preserves disabled link color through tint and hierarchy changes`() {
    let label = STULabel()
    let defaultDisabledLinkColor = UIColor.link.withProminence(.secondary)
    #expect(label.disabledLinkColor == defaultDisabledLinkColor)
    label.isEnabled = false
    #expect(label.layer.overrideLinkColor == defaultDisabledLinkColor)
    label.isEnabled = true
    #expect(label.layer.overrideLinkColor == label.tintColor)

    let disabledLinkColor = UIColor.systemRed
    label.disabledLinkColor = disabledLinkColor
    label.isEnabled = false

    #expect(label.layer.overrideLinkColor == disabledLinkColor)

    label.tintColor = .systemBlue
    label.tintColorDidChange()
    #expect(label.layer.overrideLinkColor == disabledLinkColor)

    let container = UIView()
    container.tintColor = .systemGreen
    container.addSubview(label)
    #expect(label.layer.overrideLinkColor == disabledLinkColor)

    label.didMoveToWindow()
    #expect(label.layer.overrideLinkColor == disabledLinkColor)

    label.disabledLinkColor = nil
    #expect(label.layer.overrideLinkColor == label.tintColor)

    label.isEnabled = true
    #expect(label.layer.overrideLinkColor == label.tintColor)
  }

  // Currently we just test here that these properties are actually callable (without causing a
  // linker error) and return the correct value in the simplest situation.
  @Test
  func `Text frame paragraph and line properties`() {
    let string = NSAttributedString(
      string: "Test \r\n",
      attributes: [
        .font: font,
        .underlineStyle: NSUnderlineStyle.single.rawValue,
      ])
    let tf = STUTextFrame(
      STUShapedString(string),
      size: CGSize(width: 100, height: 50),
      displayScale: 0)

    let para = tf.paragraphs[0]
    #expect(para.paragraphIndex == 0)
    #expect(para.lineIndexRange == 0..<1)
    #expect(para.initialLinesIndexRange == 0..<1)
    #expect(para.nonInitialLinesIndexRange == 1..<1)
    #expect(para.lines.indices == para.lineIndexRange)
    #expect(para.initialLines.indices == para.initialLinesIndexRange)
    #expect(para.nonInitialLines.indices == para.nonInitialLinesIndexRange)
    #expect(para.rangeInOriginalString == NSRange(0..<7))
    #expect(para.excisedRangeInOriginalString == NSRange(7..<7))
    #expect(para.rangeInTruncatedString == NSRange(0..<7))
    #expect(para.truncationTokenUTF16Length == 0)
    #expect(para.textFlags == [.hasUnderline])
    #expect(para.alignment == .left)
    #expect(para.baseWritingDirection == .leftToRight)
    #expect(para.isFirstParagraph)
    #expect(para.isLastParagraph)
    #expect(!para.excisedStringRangeIsContinuedInNextParagraph)
    #expect(!para.excisedStringRangeIsContinuationFromLastParagraph)
    #expect(para.paragraphTerminatorInOriginalStringUTF16Length == 2)
    #expect(!para.isIndented)
    #expect(para.initialLinesLeftIndent == 0)
    #expect(para.initialLinesRightIndent == 0)
    #expect(para.nonInitialLinesLeftIndent == 0)
    #expect(para.nonInitialLinesRightIndent == 0)

    let line = tf.lines[0]
    #expect(line.lineIndex == 0)
    #expect(line.paragraphIndex == 0)
    #expect(line.rangeInOriginalString == NSRange(0..<4))
    #expect(line.rangeInTruncatedString == NSRange(0..<4))
    #expect(line.trailingWhitespaceInTruncatedStringUTF16Length == 3)
    #expect(line.isFollowedByTerminatorInOriginalString)
    #expect(line.textFlags == [.hasUnderline])
    #expect(line.nonTokenTextFlags == [.hasUnderline])
    #expect(line.tokenTextFlags == [])
    #expect(line.paragraphBaseWritingDirection == .leftToRight)
    #expect(line.isFirstLine)
    #expect(line.isLastLine)
    #expect(line.isFirstLineInParagraph)
    #expect(line.isLastLineInParagraph)
    #expect(line.isInitialLineInParagraph)
    #expect(!line.hasInsertedHyphen)
    #expect(!line.isTruncatedAsRightToLeftLine)
    #expect(line.width == tf.rects(for: tf.indices, frameOrigin: .zero).bounds.width)
    #expect(line.baselineOrigin.x == 0)

    let expectedLeading =
      2
      * max(
        CGFloat(
          Float64(line.ascent) + Float64(line.leading) / 2
            - Float64(line.ascent)),
        CGFloat(
          Float64(line.descent) + Float64(line.leading) / 2
            - Float64(line.descent)))

    let expectedOriginY = CGFloat(Float32(font.ascender + expectedLeading / 2))
    #expect(line.baselineOrigin.y == expectedOriginY)

    #expect(line.ascent == CGFloat(Float32(font.ascender)))
    #expect(line.descent == CGFloat(Float32(-font.descender)))
    #expect(line.leading == expectedLeading)
  }
}
