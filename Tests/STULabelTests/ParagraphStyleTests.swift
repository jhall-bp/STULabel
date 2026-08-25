// Copyright 2018 Stephan Tolksdorf

import Foundation
import STULabelSwift
import Testing

@MainActor
struct ParagraphStyleTests {
  @Test
  func `Initialization, encoding, equality, and hashing`() throws {
    let style0 = STUParagraphStyle()
    #expect(style0.firstLineOffset == .offsetOfFirstBaselineFromDefault(0))
    #expect(style0.minimumBaselineDistance == 0)
    #expect(style0.numberOfInitialLines == 0)
    #expect(style0.initialLinesHeadIndent == 0)
    #expect(style0.initialLinesTailIndent == 0)

    let style0b = STUParagraphStyle { _ in }
    #expect(style0b.firstLineOffset == .offsetOfFirstBaselineFromDefault(0))
    #expect(style0b.minimumBaselineDistance == 0)
    #expect(style0b.numberOfInitialLines == 0)
    #expect(style0b.initialLinesHeadIndent == 0)
    #expect(style0b.initialLinesTailIndent == 0)

    #expect(style0 == style0b)
    #expect(style0.hash == style0b.hash)

    let style1 = STUParagraphStyle { (builder) in
      builder.firstLineOffset = .offsetOfFirstBaselineFromTop(1)
      builder.minimumBaselineDistance = 1.5
      builder.numberOfInitialLines = 2
      builder.initialLinesHeadIndent = 3.5
      builder.initialLinesTailIndent = -4.5
    }
    #expect(style1.firstLineOffset == .offsetOfFirstBaselineFromTop(1))
    #expect(style1.minimumBaselineDistance == 1.5)
    #expect(style1.numberOfInitialLines == 2)
    #expect(style1.initialLinesHeadIndent == 3.5)
    #expect(style1.initialLinesTailIndent == -4.5)

    #expect(style1 != style0)
    #expect(style1.hash != style0.hash)

    let style1b = style1.copy(updates: { _ in })
    #expect(style1b.firstLineOffset == .offsetOfFirstBaselineFromTop(1))
    #expect(style1b.minimumBaselineDistance == 1.5)
    #expect(style1b.numberOfInitialLines == 2)
    #expect(style1b.initialLinesHeadIndent == 3.5)
    #expect(style1b.initialLinesTailIndent == -4.5)

    #expect(style1 !== style1b)
    #expect(style1 == style1b)
    #expect(style1.hash == style1b.hash)
    #expect(style1 as NSObject != "Test" as NSObject)

    let style2 = style1b.copy { (builder) in builder.initialLinesTailIndent -= 1 }
    #expect(style2.firstLineOffset == .offsetOfFirstBaselineFromTop(1))
    #expect(style2.minimumBaselineDistance == 1.5)
    #expect(style2.numberOfInitialLines == 2)
    #expect(style2.initialLinesHeadIndent == 3.5)
    #expect(style2.initialLinesTailIndent == -5.5)
    #expect(style1.hash != style2.hash)
    #expect(style1 != style2)

    let data1 = try NSKeyedArchiver.archivedData(
      withRootObject: style1, requiringSecureCoding: true)
    let style1c = try NSKeyedUnarchiver.unarchivedObject(
      ofClass: STUParagraphStyle.self, from: data1)
    #expect(style1 == style1c)
  }

  @Test
  func `Input clamping`() {
    let builder = STUParagraphStyleBuilder()
    builder.firstLineOffset = .offsetOfFirstBaselineFromDefault(-1)
    #expect(builder.firstLineOffset == .offsetOfFirstBaselineFromDefault(-1))

    builder.firstLineOffset = .offsetOfFirstBaselineFromTop(-1)
    #expect(builder.firstLineOffset == .offsetOfFirstBaselineFromTop(0))

    builder.firstLineOffset = .offsetOfFirstLineCenterFromTop(-1)
    #expect(builder.firstLineOffset == .offsetOfFirstLineCenterFromTop(0))

    builder.firstLineOffset = .offsetOfFirstLineCapHeightCenterFromTop(-1)
    #expect(builder.firstLineOffset == .offsetOfFirstLineCapHeightCenterFromTop(0))

    builder.firstLineOffset = .offsetOfFirstLineXHeightCenterFromTop(-1)
    #expect(builder.firstLineOffset == .offsetOfFirstLineXHeightCenterFromTop(0))

    builder.firstLineOffset = .offsetOfFirstBaselineFromDefault(1)
    #expect(builder.firstLineOffset == .offsetOfFirstBaselineFromDefault(1))

    builder.__setFirstLineOffset(
      1, type: unsafeBitCast(UInt8(123), to: STUFirstLineOffsetType.self))
    #expect(builder.firstLineOffset == .offsetOfFirstBaselineFromDefault(0))

    builder.minimumBaselineDistance = -1
    #expect(builder.minimumBaselineDistance == 0)

    builder.numberOfInitialLines = -1
    #expect(builder.numberOfInitialLines == 0)

    builder.initialLinesHeadIndent = -CGFloat.infinity
    #expect(builder.initialLinesHeadIndent == 0)

    builder.initialLinesTailIndent = 1
    #expect(builder.initialLinesTailIndent == 0)
  }

  @Test
  func `First line offset`() {
    let font = UIFont(name: "HelveticaNeue", size: 20)!

    func secondLineBaseline(_ offset: STUFirstLineOffset? = nil) -> CGFloat {
      let style = NSMutableParagraphStyle()
      style.paragraphSpacingBefore = 10

      var attribs: StringAttributes = [.paragraphStyle: style]
      if let offset = offset {
        attribs[.stuParagraphStyle] = STUParagraphStyle { b in b.firstLineOffset = offset }
      }
      let string = NSAttributedString([("L\n", [:]), ("L", attribs)], [.font: font])
      let tf = STUTextFrame(
        STUShapedString(string), size: CGSize(width: 100, height: 100),
        displayScale: 0)
      return tf.lines[1].baselineOrigin.y
    }

    let ascent = font.ascender
    let descent = -font.descender
    let leading = font.leading
    let capHeight = font.capHeight
    let xHeight = font.xHeight
    let lineHeight = ascent + descent + leading
    let paragraphTop = lineHeight + 10

    let y0 = paragraphTop + leading / 2 + ascent
    expectApproximatelyEqual(secondLineBaseline(), y0, tolerance: CGFloat(Float32(y0).ulp))

    let y1 = y0 - 3
    expectApproximatelyEqual(
      secondLineBaseline(.offsetOfFirstBaselineFromDefault(-3)),
      y1, tolerance: CGFloat(Float32(y1).ulp))

    let y2 = paragraphTop + 13
    expectApproximatelyEqual(
      secondLineBaseline(.offsetOfFirstBaselineFromTop(13)),
      y2, tolerance: CGFloat(Float32(y2).ulp))

    let y3 = paragraphTop + 13 - lineHeight / 2 + leading / 2 + ascent
    expectApproximatelyEqual(
      secondLineBaseline(.offsetOfFirstLineCenterFromTop(13)),
      y3, tolerance: CGFloat(Float32(y3).ulp))

    let y4 = paragraphTop + capHeight / 2 + 13
    expectApproximatelyEqual(
      secondLineBaseline(.offsetOfFirstLineCapHeightCenterFromTop(13)),
      y4, tolerance: CGFloat(Float32(y4).ulp))

    let y5 = paragraphTop + xHeight / 2 + 13
    expectApproximatelyEqual(
      secondLineBaseline(.offsetOfFirstLineXHeightCenterFromTop(13)),
      y5, tolerance: CGFloat(Float32(y5).ulp))
  }

  @Test
  func `Minimum baseline distance`() {
    let font = UIFont(name: "HelveticaNeue", size: 20)!

    do {
      let string = NSAttributedString(
        string: "Test",
        attributes: [
          .font: font,
          .stuParagraphStyle: STUParagraphStyle { b in
            b.minimumBaselineDistance = 30
          },
        ])
      let tf = STUTextFrame(
        STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 1)
      expectApproximatelyEqual(
        tf.layoutBounds.height, CGFloat(30), tolerance: CGFloat(Float32(30).ulp))
    }
    do {
      let string = NSAttributedString(string: "1\u{2028}2", attributes: [.font: font])
      let tf = STUTextFrame(
        STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 2)
      #expect(tf.lines[1].baselineOrigin.y - tf.lines[0].baselineOrigin.y < 30)
    }
    do {
      let string = NSAttributedString(
        string: "1\u{2028}2",
        attributes: [
          .font: font,
          .stuParagraphStyle: STUParagraphStyle { b in
            b.minimumBaselineDistance = 30
          },
        ])
      let tf = STUTextFrame(
        STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 2)
      #expect(tf.lines[1].baselineOrigin.y - tf.lines[0].baselineOrigin.y == 30)
    }
    do {
      let string = NSAttributedString([
        (
          "1\n",
          [
            .stuParagraphStyle: STUParagraphStyle { b in
              b.minimumBaselineDistance = 30
            }
          ]
        ),
        (
          "2",
          [
            .stuParagraphStyle: STUParagraphStyle { b in
              b.minimumBaselineDistance = 50
            }
          ]
        ),
      ])
      let tf = STUTextFrame(
        STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 2)
      #expect(tf.lines[1].baselineOrigin.y - tf.lines[0].baselineOrigin.y == 50)
    }
    do {
      let string = NSAttributedString([
        (
          "1\n",
          [
            .stuParagraphStyle: STUParagraphStyle { b in
              b.minimumBaselineDistance = 50
            }
          ]
        ),
        (
          "2",
          [
            .stuParagraphStyle: STUParagraphStyle { b in
              b.minimumBaselineDistance = 30
            }
          ]
        ),
      ])
      let tf = STUTextFrame(
        STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 2)
      #expect(tf.lines[1].baselineOrigin.y - tf.lines[0].baselineOrigin.y == 50)
    }
    do {
      let string = NSAttributedString([
        (
          "1\n",
          [
            .stuParagraphStyle: STUParagraphStyle { b in
              b.minimumBaselineDistance = 50
            }
          ]
        ),
        (
          "2",
          [
            .stuParagraphStyle: STUParagraphStyle { b in
              b.minimumBaselineDistance = 30
              b.firstLineOffset =
                .offsetOfFirstBaselineFromDefault(-10)
            }
          ]
        ),
      ])
      let tf = STUTextFrame(
        STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 2)
      #expect(tf.lines[1].baselineOrigin.y - tf.lines[0].baselineOrigin.y == 40)
    }
  }

  @Test
  func `Initial lines indent`() {
    let font = UIFont(name: "HelveticaNeue", size: 20)!

    let paraStyle = NSMutableParagraphStyle()
    paraStyle.firstLineHeadIndent = 7
    paraStyle.headIndent = 3
    paraStyle.tailIndent = -13

    let string0 = NSAttributedString(
      string: "1\u{2028}2\u{2028}3\u{2028}4", attributes: [.font: font]
    )
    do {
      let tf = STUTextFrame(
        STUShapedString(string0, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 4)
      #expect(tf.lines[0].baselineOrigin.x == 0)
      #expect(tf.lines[1].baselineOrigin.x == 0)
      #expect(tf.lines[2].baselineOrigin.x == 0)
      #expect(tf.lines[3].baselineOrigin.x == 0)
    }

    let string1 = NSAttributedString(
      string: "1\u{2028}2\u{2028}3\u{2028}4",
      attributes: [
        .font: font, .paragraphStyle: paraStyle,
        .stuParagraphStyle: STUParagraphStyle(),
      ]
    )
    do {
      let tf = STUTextFrame(
        STUShapedString(string1, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 4)
      #expect(tf.lines[0].baselineOrigin.x == 7)
      #expect(tf.lines[1].baselineOrigin.x == 3)
      #expect(tf.lines[2].baselineOrigin.x == 3)
      #expect(tf.lines[3].baselineOrigin.x == 3)
    }

    do {
      paraStyle.alignment = .right
      let tf = STUTextFrame(
        STUShapedString(string1, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 4)
      #expect(tf.lines[0].baselineOrigin.x == 50 - 13 - tf.lines[0].width)
      #expect(tf.lines[1].baselineOrigin.x == 50 - 13 - tf.lines[1].width)
      #expect(tf.lines[2].baselineOrigin.x == 50 - 13 - tf.lines[2].width)
      #expect(tf.lines[3].baselineOrigin.x == 50 - 13 - tf.lines[3].width)
    }

    do {
      let tf = STUTextFrame(
        STUShapedString(string1, defaultBaseWritingDirection: .rightToLeft),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 4)
      #expect(tf.lines[0].baselineOrigin.x == 50 - 7 - tf.lines[0].width)
      #expect(tf.lines[1].baselineOrigin.x == 50 - 3 - tf.lines[1].width)
      #expect(tf.lines[2].baselineOrigin.x == 50 - 3 - tf.lines[2].width)
      #expect(tf.lines[3].baselineOrigin.x == 50 - 3 - tf.lines[3].width)
    }

    paraStyle.alignment = .left
    let string2 = NSAttributedString(
      string: "1\u{2028}2\u{2028}3\u{2028}4",
      attributes: [
        .font: font, .paragraphStyle: paraStyle,
        .stuParagraphStyle: STUParagraphStyle { b in
          b.numberOfInitialLines = 2
          b.initialLinesHeadIndent = 5
          b.initialLinesTailIndent = -11
        },
      ]
    )

    do {
      let tf = STUTextFrame(
        STUShapedString(string2, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.paragraphs[0].isIndented)
      #expect(tf.paragraphs[0].initialLinesIndexRange == 0..<2)
      #expect(tf.paragraphs[0].initialLinesLeftIndent == 5)
      #expect(tf.paragraphs[0].initialLinesRightIndent == 11)
      #expect(tf.paragraphs[0].nonInitialLinesLeftIndent == 3)
      #expect(tf.paragraphs[0].nonInitialLinesRightIndent == 13)
      #expect(tf.lines.count == 4)
      #expect(tf.lines[0].baselineOrigin.x == 5)
      #expect(tf.lines[1].baselineOrigin.x == 5)
      #expect(tf.lines[2].baselineOrigin.x == 3)
      #expect(tf.lines[3].baselineOrigin.x == 3)
    }

    paraStyle.alignment = .right
    do {
      let tf = STUTextFrame(
        STUShapedString(string2, defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 4)
      #expect(tf.paragraphs[0].initialLinesIndexRange == 0..<2)
      #expect(tf.paragraphs[0].initialLinesLeftIndent == 5)
      #expect(tf.paragraphs[0].initialLinesRightIndent == 11)
      #expect(tf.paragraphs[0].nonInitialLinesLeftIndent == 3)
      #expect(tf.paragraphs[0].nonInitialLinesRightIndent == 13)
      #expect(tf.lines[0].baselineOrigin.x == 50 - 11 - tf.lines[0].width)
      #expect(tf.lines[1].baselineOrigin.x == 50 - 11 - tf.lines[1].width)
      #expect(tf.lines[2].baselineOrigin.x == 50 - 13 - tf.lines[2].width)
      #expect(tf.lines[3].baselineOrigin.x == 50 - 13 - tf.lines[3].width)
    }

    do {
      let tf = STUTextFrame(
        STUShapedString(string2, defaultBaseWritingDirection: .rightToLeft),
        size: CGSize(width: 50, height: 100), displayScale: 0)
      #expect(tf.lines.count == 4)
      #expect(tf.paragraphs[0].initialLinesIndexRange == 0..<2)
      #expect(tf.paragraphs[0].initialLinesLeftIndent == 11)
      #expect(tf.paragraphs[0].initialLinesRightIndent == 5)
      #expect(tf.paragraphs[0].nonInitialLinesLeftIndent == 13)
      #expect(tf.paragraphs[0].nonInitialLinesRightIndent == 3)
      #expect(tf.lines[0].baselineOrigin.x == 50 - 5 - tf.lines[0].width)
      #expect(tf.lines[1].baselineOrigin.x == 50 - 5 - tf.lines[1].width)
      #expect(tf.lines[2].baselineOrigin.x == 50 - 3 - tf.lines[2].width)
      #expect(tf.lines[3].baselineOrigin.x == 50 - 3 - tf.lines[3].width)
    }
  }
}
