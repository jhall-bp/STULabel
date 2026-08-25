// Copyright 2018 Stephan Tolksdorf

import Foundation
import STULabelSwift
import SnapshotTesting
import Testing

@MainActor
struct TextFrameLineBreakingTests {
  let displayScale: CGFloat = 2
  let font = UIFont(name: "HelveticaNeue", size: 18)!

  func textFrame(
    _ attributedString: NSAttributedString, width: CGFloat = 1000,
    _ options: STUTextFrameOptions? = nil
  ) -> STUTextFrame {
    let options =
      options
      ?? STUTextFrameOptions { builder in builder.defaultTextAlignment = .start }
    let frame = STUTextFrame(
      STUShapedString(
        attributedString,
        defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: width, height: 10000), displayScale: displayScale,
      options: options)
    return frame
  }

  func textFrame(_ string: String, width: CGFloat = 1000) -> STUTextFrame {
    let attributes: [NSAttributedString.Key: Any] = [.font: font]
    return textFrame(NSAttributedString(string: string, attributes: attributes), width: width)
  }

  func typographicWidth(_ attributedString: NSAttributedString, width: CGFloat = 1000) -> CGFloat {
    return textFrame(attributedString, width: width).layoutBounds.size.width
  }

  func typographicWidth(_ string: String, width: CGFloat = 1000) -> CGFloat {
    return textFrame(string, width: width).layoutBounds.size.width
  }

  func image(_ textFrame: STUTextFrame) -> UIImage {
    var bounds = textFrame.layoutBounds
    bounds.origin.x = floor(bounds.origin.x * 2) / 2
    bounds.origin.y = floor(bounds.origin.y * 2) / 2
    bounds.size.width = ceil(bounds.size.width * 2) / 2
    bounds.size.height = ceil(bounds.size.height * 2) / 2
    bounds = bounds.insetBy(dx: -5, dy: -5)
    return createImage(
      bounds.size, scale: displayScale, backgroundColor: .white, .grayscale,
      { context in
        textFrame.draw(
          at: -bounds.origin, in: context, contextBaseCTM_d: 1,
          pixelAlignBaselines: true)
      })
  }

  @Test func `Empty lines`() {
    let f = textFrame("\n\r\n", width: 0)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<0))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[0].width == 0)
    #expect(lines[1].rangeInOriginalString == NSRange(1..<1))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 2)
    #expect(lines[1].width == 0)
  }

  @Test func `Simple line breaks`() {
    do {
      let width = typographicWidth("Test")
      let f = textFrame("Test Test", width: width)
      let lines = f.lines
      #expect(lines.count == 2)
      #expect(lines[0].rangeInOriginalString == NSRange(0..<4))
      #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 1)
      #expect(lines[0].width == width)
      #expect(lines[1].rangeInOriginalString == NSRange(5..<9))
      #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
      #expect(lines[1].width == width)
    }
    do {
      let width = typographicWidth("Tes")
      let f = textFrame("Test\r\n", width: width)
      let lines = f.lines
      #expect(lines.count == 2)
      #expect(lines[0].rangeInOriginalString == NSRange(0..<3))
      #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
      #expect(lines[0].width == width)
      #expect(lines[1].rangeInOriginalString == NSRange(3..<4))
      #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 2)
      #expect(lines[1].width == typographicWidth("t"))
    }
  }

  @Test func `Line breaks for zero-width frames`() {
    do {
      let f = textFrame("T\u{2028}", width: 0)
      let lines = f.lines
      #expect(lines.count == 1)
      #expect(lines[0].rangeInOriginalString == NSRange(0..<1))
      #expect(lines[0].width == typographicWidth("T"))
      #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    }
    do {
      let f = textFrame("Te😀  \n", width: 0)
      let lines = f.lines
      #expect(lines.count == 3)
      #expect(lines[0].rangeInOriginalString == NSRange(0..<1))
      #expect(lines[0].width == typographicWidth("T"))
      #expect(lines[1].rangeInOriginalString == NSRange(1..<2))
      #expect(lines[1].width == typographicWidth("e"))
      #expect(lines[2].rangeInOriginalString == NSRange(2..<4))
      #expect(lines[2].width == typographicWidth("😀"))
      #expect(lines[2].trailingWhitespaceInTruncatedStringUTF16Length == 3)
    }
  }

  @Test func `Soft hyphen`() {
    let width = typographicWidth("Test Te‐")
    let f = textFrame("Test Te\u{00AD}st", width: width + 0.01)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<8))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[0].width == width)

    #expect(lines[1].rangeInOriginalString == NSRange(8..<10))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[1].width == typographicWidth("st"))
    assertSnapshot(of: image(f), as: .image)
  }

  @Test func `Line width is checked after inserting a hyphen`() {
    let f = textFrame("Test Te\u{00AD}st", width: typographicWidth("Test Te‐") - 0.1)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<4))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[0].width == typographicWidth("Test"))
    #expect(lines[1].rangeInOriginalString == NSRange(5..<10))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[1].width == typographicWidth("Test"))
  }

  @Test func `Hyphen is omitted if it does not fit and there is no other line-break opportunity`() {
    let f = textFrame("Test\u{00AD}Test", width: typographicWidth("Test") + 1)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(!lines[0].hasInsertedHyphen)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<5))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[0].width == typographicWidth("Test"))
    #expect(!lines[1].hasInsertedHyphen)
    #expect(lines[1].rangeInOriginalString == NSRange(5..<9))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[1].width == typographicWidth("Test"))
  }

  @Test func `Hyphen in right-to-left line`() {
    // https://github.com/w3c/alreq/issues/108
    let width = CGFloat(32.8464851 as Float32)
    let f = textFrame("دامي\u{00AD}دى", width: width + 0.01)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(lines[0].hasInsertedHyphen)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<5))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    expectApproximatelyEqual(lines[0].width, width, tolerance: width * CGFloat(Float32.ulpOfOne))
    #expect(lines[1].rangeInOriginalString == NSRange(5..<7))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    // The vertical hyphen position isn't yet optimal.
    assertSnapshot(of: image(f), as: .image)
  }

  @Test func `Hyphen in the middle of a left-to-right right-to-left line`() {
    let width = typographicWidth("Test:") + CGFloat(32.8464851 as Float32)
    let f = textFrame("Test:دامي\u{00AD}دى", width: width + 0.01)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(lines[0].hasInsertedHyphen)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<10))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    expectApproximatelyEqual(lines[0].width, width, tolerance: width * CGFloat(Float32.ulpOfOne))
    #expect(lines[1].rangeInOriginalString == NSRange(10..<12))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    assertSnapshot(of: image(f), as: .image)
  }

  @Test func `Line break after zero-width space in right-to-left line`() {
    let width = typographicWidth("دامي")
    let f = textFrame("دامي\u{200C}\u{200B}\u{200C}\u{200B}دى\u{200C}", width: width + 0.001)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<8))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[0].width == width)
    #expect(lines[1].width == typographicWidth("دى"))
    #expect(lines[1].rangeInOriginalString == NSRange(8..<11))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
  }

  @Test func `Hyphen in non-monotonic run`() {
    let width = typographicWidth("ट्ट्ठि‐")
    let f = textFrame("ट्ट्ठि\u{200C}\u{200C}\u{AD}ट्ट्ठि", width: width + 0.01)
    let lines = f.lines
    #expect(lines.count == 2)
    #expect(lines[0].hasInsertedHyphen)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<9))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[0].width == width)
    #expect(lines[1].rangeInOriginalString == NSRange(9..<15))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[1].width == typographicWidth("ट्ट्ठि"))
  }

  @Test func `Locale-based hyphenation`() {
    let string = NSMutableAttributedString()
    string.append(NSAttributedString(string: "bettler\n", attributes: [:]))
    string.append(
      NSAttributedString(
        string: "bettler\n", attributes: [.stuHyphenationLocaleIdentifier: "en_US"]))
    string.append(
      NSAttributedString(
        string: "bettler\n", attributes: [.stuHyphenationLocaleIdentifier: "en_US"]))
    string.append(
      NSAttributedString(
        string: "bettler\n", attributes: [.stuHyphenationLocaleIdentifier: "de_DE"]))
    string.append(
      NSAttributedString(
        string: "bettlaken\n", attributes: [.stuHyphenationLocaleIdentifier: "de_DE"]))
    string.append(
      NSAttributedString(
        string: "bettler\n", attributes: [.stuHyphenationLocaleIdentifier: "en_US"]))
    string.append(
      NSAttributedString(
        string: "bettler\n", attributes: [.stuHyphenationLocaleIdentifier: "ar_EG"]))

    let paraStyle = NSMutableParagraphStyle()
    paraStyle.hyphenationFactor = 1

    string.addAttributes(
      [.font: font, .paragraphStyle: paraStyle],
      range: NSRange(0..<string.length))

    let width = typographicWidth("bettle")
    let f = textFrame(string, width: width)
    let lines = f.lines
    #expect(lines.count == 14)
    #expect(!lines[0].hasInsertedHyphen)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<6))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[0].width == width)
    #expect(!lines[1].hasInsertedHyphen)
    #expect(lines[1].rangeInOriginalString == NSRange(6..<7))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[1].width == typographicWidth("r"))

    #expect(lines[2].hasInsertedHyphen)
    #expect(lines[2].rangeInOriginalString == NSRange(8..<11))
    #expect(lines[2].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[2].width == typographicWidth("bet‐"))
    #expect(!lines[3].hasInsertedHyphen)
    #expect(lines[3].rangeInOriginalString == NSRange(11..<15))
    #expect(lines[3].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[3].width == typographicWidth("tler"))

    #expect(lines[4].hasInsertedHyphen)
    #expect(lines[4].rangeInOriginalString == NSRange(16..<19))
    #expect(lines[4].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[4].width == typographicWidth("bet‐"))
    #expect(!lines[5].hasInsertedHyphen)
    #expect(lines[5].rangeInOriginalString == NSRange(19..<23))
    #expect(lines[5].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[5].width == typographicWidth("tler"))

    #expect(lines[6].hasInsertedHyphen)
    #expect(lines[6].rangeInOriginalString == NSRange(24..<28))
    #expect(lines[6].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[6].width == typographicWidth("bett‐"))
    #expect(!lines[7].hasInsertedHyphen)
    #expect(lines[7].rangeInOriginalString == NSRange(28..<31))
    #expect(lines[7].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[7].width == typographicWidth("ler"))

    #expect(lines[8].hasInsertedHyphen)
    #expect(lines[8].rangeInOriginalString == NSRange(32..<36))
    #expect(lines[8].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[8].width == typographicWidth("bett‐"))
    #expect(!lines[9].hasInsertedHyphen)
    #expect(lines[9].rangeInOriginalString == NSRange(36..<41))
    #expect(lines[9].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[9].width == typographicWidth("laken"))

    #expect(lines[10].hasInsertedHyphen)
    #expect(lines[10].rangeInOriginalString == NSRange(42..<45))
    #expect(lines[10].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[10].width == typographicWidth("bet‐"))
    #expect(!lines[11].hasInsertedHyphen)
    #expect(lines[11].rangeInOriginalString == NSRange(45..<49))
    #expect(lines[11].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[11].width == typographicWidth("tler"))

    #expect(!lines[12].hasInsertedHyphen)
    #expect(lines[12].rangeInOriginalString == NSRange(50..<56))
    #expect(lines[12].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[12].width == width)
    #expect(!lines[13].hasInsertedHyphen)
    #expect(lines[13].rangeInOriginalString == NSRange(56..<57))
    #expect(lines[13].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[13].width == typographicWidth("r"))
  }

  @Test func `Hyphenation threshold`() {
    let partialWidth = typographicWidth("test")
    let fullWidth = typographicWidth("test success")
    let frameWidth = fullWidth - 0.01
    let threshold = partialWidth / frameWidth

    let paraStyle = NSMutableParagraphStyle()
    paraStyle.hyphenationFactor = Float32(threshold + 0.01)

    let string = NSAttributedString(
      string: "test success",
      attributes: [
        .font: font, .paragraphStyle: paraStyle,
        .stuHyphenationLocaleIdentifier: "en_US",
      ])

    do {
      let f = textFrame(string, width: frameWidth)
      let lines = f.lines
      #expect(lines.count == 2)
      #expect(lines[0].hasInsertedHyphen)
      #expect(lines[0].rangeInOriginalString == NSRange(0..<8))
      #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 0)
      #expect(lines[0].width == typographicWidth("test suc‐"))
      #expect(!lines[1].hasInsertedHyphen)
      #expect(lines[1].rangeInOriginalString == NSRange(8..<12))
      #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
      #expect(lines[1].width == typographicWidth("cess"))
    }

    paraStyle.hyphenationFactor = Float32(threshold - 0.01)
    do {
      let f = textFrame(string, width: frameWidth)
      let lines = f.lines
      #expect(lines.count == 2)
      #expect(!lines[0].hasInsertedHyphen)
      #expect(lines[0].rangeInOriginalString == NSRange(0..<4))
      #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 1)
      #expect(lines[0].width == partialWidth)
      #expect(!lines[1].hasInsertedHyphen)
      #expect(lines[1].rangeInOriginalString == NSRange(5..<12))
      #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
      #expect(lines[1].width == typographicWidth("success"))
    }
  }

  @Test func `Finder-based hyphenation`() {
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.hyphenationFactor = 1
    paraStyle.baseWritingDirection = .leftToRight
    let attributedString =
      NSAttributedString(
        string: "\n🐉✊🏿🌈",
        attributes: [
          .font: font,
          .paragraphStyle: paraStyle,
        ]
      )
      .copy() as! NSAttributedString
    var counter = 0
    let options = STUTextFrameOptions { builder in
      builder.lastHyphenationLocationInRangeFinder = {
        (attributedStringArg, range)
          -> STUHyphenationLocation in
        #expect(attributedStringArg == attributedString)
        let string = attributedString.string
        let index = string.index(string.endIndex, offsetBy: -counter)
        counter += 1
        #expect(range == NSRange(1..<index.utf16Offset(in: string)))
        return STUHyphenationLocation(
          index: string.index(before: index).utf16Offset(in: string),
          hyphen: UnicodeScalar("🤯").value,
          options: [])
      }
    }

    let f = textFrame(attributedString, width: typographicWidth("🐉✊🏿🌈") - 0.1, options)
    let lines = f.lines
    #expect(lines.count == 3)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<0))
    #expect(lines[0].trailingWhitespaceInTruncatedStringUTF16Length == 1)
    #expect(lines[0].width == 0)

    #expect(lines[1].hasInsertedHyphen)
    #expect(lines[1].rangeInOriginalString == NSRange(1..<3))
    #expect(lines[1].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[1].width == typographicWidth("🐉🤯"))

    #expect(!lines[2].hasInsertedHyphen)
    #expect(lines[2].rangeInOriginalString == NSRange(3..<8))
    #expect(lines[2].trailingWhitespaceInTruncatedStringUTF16Length == 0)
    #expect(lines[2].width == typographicWidth("✊🏿🌈"))
  }

  @Test func `Left-to-right justification`() {
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.alignment = .justified
    let string = NSMutableAttributedString(
      string: "Test TestTest",
      attributes: [.font: font, .paragraphStyle: paraStyle])
    string.addAttribute(
      .underlineStyle, value: NSUnderlineStyle.single.rawValue,
      range: NSRange(2..<3))
    let width = typographicWidth("TestTest")
    let f = textFrame(string, width: width)
    assertSnapshot(of: image(f), as: .image)
  }

  @Test func `Right-to-left justification`() {
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.alignment = .justified
    let string = NSMutableAttributedString(
      string: "הבדיקה הבדיקההבדיקה",
      attributes: [.font: font, .paragraphStyle: paraStyle])
    string.addAttribute(
      .underlineStyle, value: NSUnderlineStyle.single.rawValue,
      range: NSRange(4..<5))
    let width = typographicWidth("הבדיקההבדיקה")
    let f = textFrame(string, width: width)
    assertSnapshot(of: image(f), as: .image)
  }

  @Test func `Justification with a hyphen in a left-to-right right-to-left line`() {
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.alignment = .justified
    let string = NSMutableAttributedString(
      string: "Test: اخ\u{00AD}تباراختباراختبار",
      attributes: [.font: font, .paragraphStyle: paraStyle])
    string.addAttribute(
      .underlineStyle, value: NSUnderlineStyle.single.rawValue,
      range: NSRange(6..<7))
    let f = textFrame(string, width: typographicWidth("اختباراختباراختبار"))
    assertSnapshot(of: image(f), as: .image)
  }
}
