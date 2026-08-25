// Copyright 2018 Stephan Tolksdorf

import STULabelSwift
import SnapshotTesting
import Testing
import UIKit

@MainActor
struct TextFrameHighlightingTests {
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
      size: CGSize(width: width, height: 10000),
      displayScale: displayScale,
      options: options)
    return frame
  }

  func textFrame(
    _ string: String, width: CGFloat = 1000,
    attributes: StringAttributes = [:]
  ) -> STUTextFrame {
    var attributes = attributes
    if attributes[.font] == nil {
      attributes[.font] = font
    }
    return textFrame(NSAttributedString(string: string, attributes: attributes), width: width)
  }

  func typographicWidth(_ string: String, width: CGFloat = 1000) -> CGFloat {
    return textFrame(string, width: width).layoutBounds.width
  }

  func image(
    _ textFrame: STUTextFrame,
    _ range: Range<STUTextFrame.Index>? = nil,
    _ highlight: (Range<STUTextFrame.Index>, STUTextHighlightStyle)? = nil
  ) -> UIImage {
    var bounds = textFrame.layoutBounds
    bounds.origin.x = floor(bounds.origin.x * 2) / 2
    bounds.origin.y = floor(bounds.origin.y * 2) / 2
    bounds.size.width = ceil(bounds.size.width * 2) / 2
    bounds.size.height = ceil(bounds.size.height * 2) / 2
    bounds = bounds.insetBy(dx: -5, dy: -5)
    return createImage(
      bounds.size, scale: displayScale, backgroundColor: .white, .rgb,
      { context in
        let range = range ?? textFrame.indices
        if let (highlightRange, style) = highlight {
          let options = STUTextFrame.DrawingOptions()
          options.setHighlightRange(highlightRange)
          options.highlightStyle = style
          textFrame.draw(
            range: range, at: -bounds.origin, in: context, contextBaseCTM_d: 1,
            pixelAlignBaselines: true, options: options)
        } else {
          textFrame.draw(
            range: range, at: -bounds.origin, in: context, contextBaseCTM_d: 1,
            pixelAlignBaselines: true)
        }
      })
  }

  @Test
  func `Truncated line highlighting`() {
    let string = NSMutableAttributedString()
    string.append(
      NSAttributedString(
        string: "012", attributes: [.font: font, .foregroundColor: UIColor.magenta]))
    string.append(
      NSAttributedString(
        string: "345____", attributes: [.font: font, .foregroundColor: UIColor.green]))
    string.append(
      NSAttributedString(string: "abc", attributes: [.font: font, .foregroundColor: UIColor.cyan]))
    string.append(
      NSAttributedString(string: "def", attributes: [.font: font, .foregroundColor: UIColor.blue]))
    let token = NSMutableAttributedString()
    token.append(
      NSAttributedString(string: "6", attributes: [.font: font, .foregroundColor: UIColor.black]))
    token.append(
      NSAttributedString(string: "78", attributes: [.font: font, .foregroundColor: UIColor.black]))
    let frameWidth = typographicWidth("012345678abcdef") + 2
    let f = STUTextFrame(
      STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: frameWidth, height: 100),
      displayScale: displayScale,
      options: STUTextFrameOptions { b in
        b.maximumNumberOfLines = 1
        b.lastLineTruncationMode = .middle
        b.truncationToken = token
      })
    assertSnapshot(of: image(f), as: .image, named: "no-highlighting")
    let hs = STUTextHighlightStyle { b in
      b.setUnderlineStyle(.single, color: nil)
      b.textColor = .red
    }
    assertSnapshot(of: image(f, nil, (f.indices, hs)), as: .image, named: "all-red")

    assertSnapshot(
      of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(0...1)), hs)), as: .image,
      named: "0-1-red")
    assertSnapshot(
      of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(4...4)), hs)), as: .image,
      named: "4-red")
    assertSnapshot(
      of: image(
        f, f.range(forRangeInOriginalString: NSRange(2...4)),
        (f.range(forRangeInOriginalString: NSRange(4...4)), hs)), as: .image,
      named: "2-4-drawn_4-red")
    assertSnapshot(
      of: image(
        f, f.range(forRangeInOriginalString: NSRange(5...10)),
        (f.range(forRangeInTruncatedString: NSRange(7...7)), hs)), as: .image,
      named: "5-a-drawn_7-red")
    assertSnapshot(
      of: image(f, nil, (f.range(forRangeInTruncatedString: NSRange(12...12)), hs)), as: .image,
      named: "d-red")
  }

  @Test
  func `Hyphen highlighting`() {
    let f = textFrame("Te\u{ad}st", width: typographicWidth("Test") - 1)
    let hyphenIndex = STUTextFrame.Index(
      utf16IndexInTruncatedString: 2,
      isIndexOfInsertedHyphen: true,
      lineIndex: 0)
    let indexAfterHyphen = STUTextFrame.Index(
      utf16IndexInTruncatedString: 3,
      isIndexOfInsertedHyphen: false,
      lineIndex: 0)
    let hs = STUTextHighlightStyle { b in
      b.setUnderlineStyle(.single, color: nil)
      b.textColor = .red
    }
    assertSnapshot(of: image(f, nil, (f.indices, hs)), as: .image, named: "all-red")
    assertSnapshot(
      of: image(
        f, f.range(forRangeInOriginalString: NSRange(1...3)),
        (hyphenIndex..<indexAfterHyphen, hs)),
      as: .image, named: "1-3-drawn_hyphen-red")
    assertSnapshot(
      of: image(f, hyphenIndex..<indexAfterHyphen, nil),
      as: .image, named: "black-hyphen-only")
  }

  @Test
  func `Non-monotonic run highlighting`() {
    let f = textFrame("ट्ट्ठिट्ट्ठि")
    let hs = STUTextHighlightStyle { b in
      b.setUnderlineStyle(.single, color: nil)
      b.textColor = .red
    }
    assertSnapshot(
      of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(0...4)), hs)),
      as: .image, named: "0-4-red")
    assertSnapshot(
      of: image(
        f, f.range(forRangeInOriginalString: NSRange(4...9)),
        (f.range(forRangeInOriginalString: NSRange(5...6)), hs)),
      as: .image, named: "4-9-drawn_5-6-red")
  }

  @Test
  func `Partial ligature highlighting`() {
    let hs = STUTextHighlightStyle { b in
      b.setUnderlineStyle(.single, color: nil)
      b.textColor = .red
    }
    do {
      // Hoefler Text contains caret positions for ligatures.
      let f = textFrame(
        NSAttributedString(
          string: "ffiffk", attributes: [.font: UIFont(name: "HoeflerText-Regular", size: 18)!]))

      let suffix = MemoryLayout<Int>.size == 4 ? "_32bit" : ""
      assertSnapshot(
        of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(1...1)), hs)),
        as: .image, named: "1-red" + suffix)
      assertSnapshot(
        of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(1...4)), hs)),
        as: .image, named: "1-4-red" + suffix)
      assertSnapshot(
        of: image(
          f, f.range(forRangeInOriginalString: NSRange(2...3)),
          (f.range(forRangeInOriginalString: NSRange(2...2)), hs)),
        as: .image, named: "2-3-drawn_2-red")
    }
    do {
      // Helvetica Neue does not contains caret positions for ligatures.
      let f = textFrame(
        NSAttributedString(
          string: "fi\u{2060}fi", attributes: [.font: UIFont(name: "HelveticaNeue", size: 18)!]))
      assertSnapshot(
        of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(1...3)), hs)),
        as: .image, named: "1-2-red")
      assertSnapshot(
        of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(3...4)), hs)),
        as: .image, named: "2-3-red")
    }
  }

  @Test
  func `Right-to-left line highlighting`() {
    let f = textFrame("עִברִית")
    let hs = STUTextHighlightStyle { b in
      b.setUnderlineStyle(.single, color: nil)
      b.textColor = .red
    }
    assertSnapshot(
      of: image(f, nil, (f.range(forRangeInOriginalString: NSRange(2...4)), hs)),
      as: .image, named: "2-4-red")
    assertSnapshot(
      of: image(
        f, f.range(forRangeInOriginalString: NSRange(2...6)),
        (f.range(forRangeInOriginalString: NSRange(5...6)), hs)),
      as: .image, named: "2-6-drawn_5-6-red")
  }
}
