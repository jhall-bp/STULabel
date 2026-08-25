// Copyright 2018 Stephan Tolksdorf

import STULabel
import SnapshotTesting
import Testing
import UIKit

@MainActor
struct TruncationTests {
  let displayScale: CGFloat = 2

  let font = UIFont(name: "HelveticaNeue", size: 18)!

  func textFrame(
    _ attributedString: NSAttributedString, width: CGFloat = 1000,
    maxLineCount: Int = 0,
    lastLineTruncationMode: STULastLineTruncationMode = .end,
    truncationToken: NSAttributedString? = nil
  )
    -> STUTextFrame
  {
    let options = STUTextFrameOptions { builder in
      builder.textLayoutMode = .textKit
      builder.defaultTextAlignment = .start
      builder.lastLineTruncationMode = lastLineTruncationMode
      builder.maximumNumberOfLines = maxLineCount
      builder.truncationToken = truncationToken
    }
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
    _ string: String, font: UIFont? = nil, width: CGFloat = 1000, maxLineCount: Int = 0,
    lastLineTruncationMode: STULastLineTruncationMode = .end,
    truncationToken: NSAttributedString? = nil
  )
    -> STUTextFrame
  {
    let attributes: StringAttributes = [.font: font ?? self.font]
    return textFrame(
      NSAttributedString(string: string, attributes: attributes), width: width,
      maxLineCount: maxLineCount,
      lastLineTruncationMode: lastLineTruncationMode,
      truncationToken: truncationToken)
  }

  func typographicWidth(_ attributedString: NSAttributedString, width: CGFloat = 1000) -> CGFloat {
    return textFrame(attributedString, width: width).layoutBounds.size.width
  }

  func typographicWidth(_ string: String, font: UIFont? = nil, width: CGFloat = 1000) -> CGFloat {
    return textFrame(string, font: font, width: width).layoutBounds.size.width
  }

  func image(_ textFrame: STUTextFrame) -> UIImage {
    let bounds = ceilToScale(textFrame.layoutBounds, displayScale).insetBy(-1)
    return createImage(
      bounds.size, scale: displayScale, backgroundColor: .white, .grayscale,
      { context in
        textFrame.draw(
          at: -bounds.origin, in: context, contextBaseCTM_d: 1,
          pixelAlignBaselines: true)
      })
  }

  @Test
  func `Left-to-right line-end truncation`() {
    let width = typographicWidth("Test") + typographicWidth("…")
    let f = textFrame("Testing", width: width + 0.001, maxLineCount: 1)

    #expect(
      f.truncatedAttributedString.isEqual(
        NSAttributedString(string: "Test…", attributes: [.font: font])))
    #expect(f.rangeInOriginalString == NSRange(0..<7))
    #expect(f.rangeOfLastTruncationToken == f.range(forRangeInTruncatedString: NSRange(4..<5)))
    let paras = f.paragraphs
    #expect(paras[0].rangeInOriginalString == NSRange(0..<7))
    #expect(paras[0].excisedRangeInOriginalString == NSRange(4..<7))
    #expect(paras[0].rangeInTruncatedString == NSRange(0..<5))
    let lines = f.lines
    #expect(lines.count == 1)
    #expect(lines[0].rangeInOriginalString == NSRange(0..<7))
    #expect(lines[0].excisedRangeInOriginalString == NSRange(4..<7))
    #expect(lines[0].rangeInTruncatedString == NSRange(0..<5))
  }

  @Test
  func `Single-character token font selection`() {
    let font = UIFont(name: "HoeflerText-Regular", size: 17)!
    let width =
      typographicWidth("XX", font: font)
      + typographicWidth("…", font: UIFont(name: "PingFangSC-Regular", size: font.pointSize)!)
    do {
      let f = textFrame(
        "X测测X", font: font, width: width + 1, maxLineCount: 1,
        lastLineTruncationMode: .middle)
      assertSnapshot(of: image(f), as: .image, named: "PingFang")
    }
    do {
      let f = textFrame(
        "X测测X", font: font, width: width + 1, maxLineCount: 1,
        lastLineTruncationMode: .middle,
        truncationToken: NSAttributedString(string: "…", attributes: [.font: font]))
      assertSnapshot(of: image(f), as: .image, named: "Hoefler")
    }

    do {
      let f = textFrame(
        "X测X测X", font: font, width: width + 1, maxLineCount: 1,
        lastLineTruncationMode: .middle)
      assertSnapshot(of: image(f), as: .image, named: "PingFang")
    }

    do {
      let f = textFrame(
        "X测X测XX", font: font, width: width + 1, maxLineCount: 1,
        lastLineTruncationMode: .middle)
      assertSnapshot(of: image(f), as: .image, named: "PingFang")
    }

    do {
      let f = textFrame(
        "XX测X测X", font: font, width: width + 1, maxLineCount: 1,
        lastLineTruncationMode: .middle)
      assertSnapshot(of: image(f), as: .image, named: "Hoefler")
    }

    do {
      let f = textFrame(
        "XX测X测X测X", font: font, width: width + 1, maxLineCount: 1,
        lastLineTruncationMode: .middle)
      assertSnapshot(of: image(f), as: .image, named: "Hoefler")
    }

    do {
      let f = textFrame(
        "XX测测X测X测X", font: font, width: width + 1, maxLineCount: 1,
        lastLineTruncationMode: .middle)
      assertSnapshot(of: image(f), as: .image, named: "PingFang")
    }
  }

}
