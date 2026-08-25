// Copyright 2018 Stephan Tolksdorf

import STULabelSwift

import Foundation
import Testing

@MainActor
struct TextFrameLayoutInfoTests {
  private func expectEqual(_ actual: CGFloat, _ expected: CGFloat, accuracy: CGFloat) {
    #expect(abs(actual - expected) <= accuracy)
  }

  private func expectEqual(_ actual: CGFloat, _ expected: CGFloat, accuracyInULP: CGFloat) {
    #expect(abs(actual - expected) <= accuracyInULP * expected.ulp)
  }

  private func expectEqual(_ actual: CGFloat, _ expected: CGFloat,
                           accuracyInFloat32ULP: CGFloat) {
    #expect(abs(actual - expected) <= accuracyInFloat32ULP * CGFloat(Float32(expected).ulp))
  }

  private func assertLayoutInfoConsistency(_ tf: STUTextFrame, origin: CGPoint) {
    let info0 = tf.layoutInfo(frameOrigin: origin, displayScale: nil)
    let info1 = tf.layoutInfo(frameOrigin: origin)
    let s: CGFloat = 0.5
    let info2 = tf.layoutInfo(frameOrigin: origin, displayScale: s)

    let tfo = STUTextFrameWithOrigin(tf, origin, displayScale: s)
    let info2b = tfo.layoutInfo

    for info in [info1, info2, info2b] {
      #expect(info0.lineCount == info.lineCount)
      #expect(info0.flags == info.flags)
      #expect(info0.layoutMode == info.layoutMode)
      #expect(info0.consistentAlignment == info.consistentAlignment)
      #expect(info0.textScaleFactor == info.textScaleFactor)
      #expect(info0.size == info.size)
      #expect(info0.minX == info.minX)
      #expect(info0.maxX == info.maxX)
      #expect(info0.firstLineHeight == info.firstLineHeight)
      #expect(info0.firstLineHeightAboveBaseline == info.firstLineHeightAboveBaseline)
      #expect(info0.lastLineHeight == info.lastLineHeight)
      #expect(info0.lastLineHeightBelowBaseline == info.lastLineHeightBelowBaseline)
      #expect(info0.lastLineHeightBelowBaselineWithoutSpacing == info.lastLineHeightBelowBaselineWithoutSpacing)
      #expect(info0.lastLineHeightBelowBaselineWithMinimalSpacing == info.lastLineHeightBelowBaselineWithMinimalSpacing)
    }

    #expect(Int(info0.lineCount) == tf.lines.count)
    #expect(info0.flags == tf.flags)
    #expect(info0.layoutMode == tf.layoutMode)
    #expect(info0.consistentAlignment == tf.consistentAlignment)
    #expect(info0.textScaleFactor == tf.textScaleFactor)
    #expect(info0.size == tf.size)
    #expect(Double(info0.firstLineHeight) == tf.firstLineHeight)
    #expect(Double(info0.firstLineHeightAboveBaseline) == tf.firstLineHeightAboveBaseline)
    #expect(Double(info0.lastLineHeight) == tf.lastLineHeight)
    #expect(Double(info0.lastLineHeightBelowBaseline) == tf.lastLineHeightBelowBaseline)
    #expect(Double(info0.lastLineHeightBelowBaselineWithoutSpacing) == tf.lastLineHeightBelowBaselineWithoutSpacing)
    #expect(Double(info0.lastLineHeightBelowBaselineWithMinimalSpacing) == tf.lastLineHeightBelowBaselineWithMinimalSpacing)

    #expect(Int(info0.lineCount) == tfo.lines.count)
    #expect(info0.flags == tfo.flags)
    #expect(info0.layoutMode == tfo.layoutMode)
    #expect(info0.consistentAlignment == tfo.consistentAlignment)
    #expect(info0.textScaleFactor == tfo.textScaleFactor)
    #expect(info0.size == tf.size)
    #expect(CGFloat(info0.firstLineHeight) == tfo.firstLineHeight)
    #expect(CGFloat(info0.firstLineHeightAboveBaseline) == tfo.firstLineHeightAboveBaseline)
    #expect(CGFloat(info0.lastLineHeight) == tfo.lastLineHeight)
    #expect(CGFloat(info0.lastLineHeightBelowBaseline) == tfo.lastLineHeightBelowBaseline)
    #expect(CGFloat(info0.lastLineHeightBelowBaselineWithoutSpacing) == tfo.lastLineHeightBelowBaselineWithoutSpacing)
    #expect(CGFloat(info0.lastLineHeightBelowBaselineWithMinimalSpacing) == tfo.lastLineHeightBelowBaselineWithMinimalSpacing)

    #expect(CGFloat(info0.firstBaseline) ==
                   tf.firstBaseline(frameOriginY: origin.y, displayScale: nil))
    #expect(CGFloat(info0.lastBaseline) ==
                   tf.lastBaseline(frameOriginY: origin.y, displayScale: nil))
    #expect(CGFloat(info1.firstBaseline) ==
                   tf.firstBaseline(frameOriginY: origin.y))
    #expect(CGFloat(info1.lastBaseline) ==
                   tf.lastBaseline(frameOriginY: origin.y))
    #expect(CGFloat(info2.firstBaseline) ==
                   tf.firstBaseline(frameOriginY: origin.y, displayScale: s))
    #expect(CGFloat(info2.lastBaseline) ==
                   tf.lastBaseline(frameOriginY: origin.y, displayScale: s))

    if !tf.lines.isEmpty {
      let firstLine = tf.lines.first!
      let lastLine = tf.lines.last!
      #expect(tf.firstBaseline(frameOriginY: origin.y, displayScale: nil) ==
                     firstLine.baselineOrigin(textFrameOrigin: origin, displayScale: nil).y)
      #expect(tf.firstBaseline(frameOriginY: origin.y, displayScale: s) ==
                     firstLine.baselineOrigin(textFrameOrigin: origin, displayScale: s).y)

      #expect(tf.lastBaseline(frameOriginY: origin.y, displayScale: nil) ==
                     lastLine.baselineOrigin(textFrameOrigin: origin, displayScale: nil).y)
      #expect(tf.lastBaseline(frameOriginY: origin.y, displayScale: s) ==
                     lastLine.baselineOrigin(textFrameOrigin: origin, displayScale: s).y)

      if tf.lines.count == 1 {
        #expect(tf.firstBaseline == tf.lastBaseline)
        #expect(tf.firstLineHeight == tf.lastLineHeight)
      }
    }

    #expect(tf.firstBaseline == tf.firstBaseline(frameOriginY: 0, displayScale: nil))
    #expect(tf.lastBaseline == tf.lastBaseline(frameOriginY: 0, displayScale: nil))

    for line in tf.lines {
      #expect(line.baselineOrigin ==
                    line.baselineOrigin(textFrameOrigin: .zero, displayScale: nil))

      #expect(line.typographicBounds ==
                     line.typographicBounds(textFrameOrigin: .zero, displayScale: nil))


      let bo = line.baselineOrigin(textFrameOrigin: .zero, displayScale: nil)
      let width = line.width
      let ascent = line.ascent
      let descent = line.descent
      let leading = line.leading

      let bounds0 = line.typographicBounds(textFrameOrigin: origin, displayScale: nil)
      let bounds2 = line.typographicBounds(textFrameOrigin: origin, displayScale: s)

      let minX = origin.x + bo.x
      expectEqual(minX, bounds0.origin.x, accuracy: minX.ulp)
      let minY = origin.y + bo.y - CGFloat((Float32(ascent) + Float32(leading)/2))
      expectEqual(minY, bounds0.origin.y, accuracy: 8*minY.ulp)

      expectEqual(width,  bounds0.size.width, accuracy: width.ulp)
      let height = CGFloat(Float32(ascent) + Float32(descent) + Float32(leading))
      expectEqual(height, bounds0.size.height, accuracy: height.ulp)

      expectEqual(minX,   bounds2.origin.x,    accuracy: minX.ulp)
      expectEqual(width,  bounds2.size.width,  accuracy: width.ulp)
      expectEqual(height, bounds2.size.height, accuracy: height.ulp)

      let minY2 = ceilToScale(origin.y + bo.y, s) - CGFloat((Float32(ascent) + Float32(leading)/2))
      expectEqual(minY2, bounds2.origin.y, accuracy: minY2.ulp)
    }

    #expect(tfo.firstBaseline == tf.firstBaseline(frameOriginY: origin.y, displayScale: s))
    #expect(tfo.lastBaseline == tf.lastBaseline(frameOriginY: origin.y, displayScale: s))
    #expect(tfo.layoutBounds == tf.layoutBounds(frameOrigin: origin, displayScale: s))

    #expect(tf.firstBaseline(frameOriginY: origin.y, displayScale: s) ==
                   ceilToScale(origin.y + tf.firstBaseline(frameOriginY: 0, displayScale: nil), s))

    #expect(tf.lastBaseline(frameOriginY: origin.y, displayScale: s) ==
                   ceilToScale(origin.y + tf.lastBaseline(frameOriginY: 0, displayScale: nil), s))

    if let ts = tf.displayScale {
      #expect(tf.firstBaseline(frameOriginY: origin.y) ==
                     ceilToScale(origin.y + tf.firstBaseline(frameOriginY: 0, displayScale: nil),
                                 ts))
      #expect(tf.lastBaseline(frameOriginY: origin.y) ==
                     ceilToScale(origin.y + tf.lastBaseline(frameOriginY: 0, displayScale: nil),
                                 ts))
    }

    for i in tf.lines.indices {
      let a = tf.lines[i]
      let b = tfo.lines[i]

      #expect(a.lineIndex == b.lineIndex)
      #expect(a.isFirstLine == b.isFirstLine)
      #expect(a.isLastLine == b.isLastLine)
      #expect(a.isFirstLineInParagraph == b.isFirstLineInParagraph)
      #expect(a.isLastLineInParagraph == b.isLastLineInParagraph)
      #expect(a.paragraphIndex == b.paragraphIndex)
      #expect(a.range == b.range)
      #expect(a.rangeInTruncatedString == b.rangeInTruncatedString)
      #expect(a.trailingWhitespaceInTruncatedStringUTF16Length == b.trailingWhitespaceInTruncatedStringUTF16Length)
      #expect(a.rangeInOriginalString == b.rangeInOriginalString)
      #expect(a.excisedRangeInOriginalString == b.excisedRangeInOriginalString)
      #expect(a.isFollowedByTerminatorInOriginalString == b.isFollowedByTerminatorInOriginalString)
      #expect(a.baselineOrigin(textFrameOrigin: origin, displayScale: s) ==
                     b.baselineOrigin)
      #expect(a.width == b.width)
      #expect(a.ascent == b.ascent)
      #expect(a.descent == b.descent)
      #expect(a.leading == b.leading)
      #expect(a.typographicBounds(textFrameOrigin: origin, displayScale: s) ==
                     b.typographicBounds)
      #expect(a.hasTruncationToken == b.hasTruncationToken)
      #expect(a.isTruncatedAsRightToLeftLine == b.isTruncatedAsRightToLeftLine)
      #expect(a.hasInsertedHyphen == b.hasInsertedHyphen)
      #expect(a.paragraphBaseWritingDirection == b.paragraphBaseWritingDirection)
      #expect(a.textFlags == b.textFlags)
      #expect(a.nonTokenTextFlags == b.nonTokenTextFlags)
      #expect(a.tokenTextFlags == b.tokenTextFlags)
      #expect(a.leftPartWidth == b.leftPartWidth)
      #expect(a.tokenWidth == b.tokenWidth)
    }

  }

  private func assertLayoutInfoConsistency(_ tf: STUTextFrame) {
    assertLayoutInfoConsistency(tf, origin: .zero)
    assertLayoutInfoConsistency(tf, origin: CGPoint(x: 100.25, y: 200))
    assertLayoutInfoConsistency(tf, origin: CGPoint(x: 100.25, y: 201.75))
  }

  @Test
  func `Empty text frame`() {
    let tf = STUTextFrame(STUShapedString.empty(withDefaultBaseWritingDirection: .leftToRight),
                          size: CGSize(width: 12, height: 34), displayScale: 5)
    let origin = CGPoint(x: 5, y: 6)
    let info = tf.layoutInfo(frameOrigin: CGPoint(x: 5, y: 6))
    #expect(info.lineCount == 0)
    #expect(tf.lines.count == 0)
    #expect(tf.paragraphs.count == 0)
    #expect(info.flags == [.hasMaxTypographicWidth])
    #expect(tf.flags == [.hasMaxTypographicWidth])
    #expect(info.layoutMode == .default)
    #expect(tf.layoutMode == .default)
    #expect(info.consistentAlignment == .left)
    #expect(tf.consistentAlignment == .left)
    #expect(info.textScaleFactor == 1)
    #expect(tf.textScaleFactor == 1)
    #expect(info.size == CGSize(width: 12, height: 34))
    #expect(tf.size == CGSize(width: 12, height: 34))
    #expect(info.minX == 5)
    #expect(info.maxX == 5)
    #expect(info.firstBaseline == 6)
    #expect(tf.firstBaseline(frameOriginY: origin.y) == 6)
    #expect(info.lastBaseline == 6)
    #expect(tf.lastBaseline(frameOriginY: origin.y) == 6)
    #expect(info.firstLineHeight == 0)
    #expect(tf.firstLineHeight == 0)
    #expect(info.firstLineHeightAboveBaseline == 0)
    #expect(tf.firstLineHeightAboveBaseline == 0)
    #expect(info.lastLineHeight == 0)
    #expect(tf.lastLineHeight == 0)
    #expect(info.lastLineHeightBelowBaseline == 0)
    #expect(tf.lastLineHeightBelowBaseline == 0)
    #expect(info.lastLineHeightBelowBaselineWithoutSpacing == 0)
    #expect(tf.lastLineHeightBelowBaselineWithoutSpacing == 0)
    #expect(info.lastLineHeightBelowBaselineWithMinimalSpacing == 0)
    #expect(tf.lastLineHeightBelowBaselineWithMinimalSpacing == 0)
    let bounds = tf.layoutBounds(frameOrigin: origin)
    #expect(bounds == info.layoutBounds)
  }


  @Test
  func `Layout info`() {
    let font1  = UIFont(name: "HelveticaNeue", size: 20)!
    let font2  = UIFont(name: "HelveticaNeue", size: 16)!
    let font1b = UIFont(name: "GeezaPro", size: 20)!
    let font2b = UIFont(name: "GeezaPro", size: 16)!

    let g: CGFloat = 3
    assert(g > font1.leading)

    let paraStyle = NSMutableParagraphStyle()
    paraStyle.lineSpacing = g

    let font1LineHeight = font1.ascender - font1.descender + g
    let font2LineHeight = font2.ascender - font2.descender + g


    ({
      let text = NSAttributedString(string: "الاختبار 1",
                                    attributes: [.font: font1, .paragraphStyle: paraStyle])
      let width = STUTextFrame(STUShapedString(text), size: CGSize(width: 200, height: 100),
                               displayScale: 0, options: nil).layoutBounds.size.width/2
      let tf = STUTextFrame(STUShapedString(text), size: CGSize(width: width, height: 100),
                            displayScale: 3,
                            options: STUTextFrameOptions { (b) in b.textLayoutMode = .textKit
                                                                  b.minimumTextScaleFactor = 0.1
                                                                  b.maximumNumberOfLines = 1 })
      let s: CGFloat = 0.5
      #expect(tf.textScaleFactor == s)
      #expect(tf.lines.count == 1)

      expectEqual(tf.firstLineHeight, s*font1LineHeight, accuracyInFloat32ULP: 2)

      expectEqual(tf.firstLineHeightAboveBaseline, s*font1.ascender,
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lastLineHeightBelowBaseline, s*(-font1.descender + g),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lastLineHeightBelowBaselineWithMinimalSpacing,
                     s*(-font1.descender + font1.leading),
                     accuracyInFloat32ULP: 3)

      expectEqual(tf.lastLineHeightBelowBaselineWithoutSpacing, s*(-font1.descender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.firstBaseline, ceilToScale(s*font1.ascender, 3), accuracyInULP: 1)

      expectEqual(tf.lines.first!.ascent, s*max(font1.ascender, font1b.ascender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lines.first!.descent, s*max(-font1.descender, -font1b.descender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lines.first!.leading, s*max(font1.leading, font1b.leading),
                     accuracyInFloat32ULP: 1)

      assertLayoutInfoConsistency(tf)
    })()


    ({
      let text = NSAttributedString([("الاختبار 1\n", [.font: font1]), ("الاختبار 2", [.font: font2])],
                                    [.paragraphStyle: paraStyle])

      let width = STUTextFrame(STUShapedString(text), size: CGSize(width: 200, height: 100),
                               displayScale: 0, options: nil).layoutBounds.size.width/2
      let tf = STUTextFrame(STUShapedString(text), size: CGSize(width: width, height: 100),
                            displayScale: 3,
                            options: STUTextFrameOptions { (b) in b.textLayoutMode = .textKit
                                                                  b.minimumTextScaleFactor = 0.1
                                                                  b.maximumNumberOfLines = 2 })
      let s: CGFloat = 0.5
      #expect(tf.textScaleFactor == s)
      #expect(tf.lines.count == 2)

      expectEqual(tf.firstLineHeight, s*font1LineHeight, accuracyInFloat32ULP: 2)
      expectEqual(tf.lastLineHeight, s*font2LineHeight, accuracyInFloat32ULP: 2)

      expectEqual(tf.firstLineHeightAboveBaseline, s*font1.ascender,
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lastLineHeightBelowBaseline, s*(-font2.descender + g),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lastLineHeightBelowBaselineWithMinimalSpacing,
                     s*(-font2.descender + font2.leading),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lastLineHeightBelowBaselineWithoutSpacing, s*(-font2.descender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.firstBaseline, ceilToScale(s*font1.ascender, 3), accuracyInULP: 1)

      expectEqual(tf.lastBaseline, ceilToScale(s*(font1LineHeight + font2.ascender), 3),
                     accuracyInULP: 1)

      expectEqual(tf.lines.first!.ascent, s*max(font1.ascender, font1b.ascender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lines.first!.descent, s*max(-font1.descender, -font1b.descender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lines.first!.leading, s*max(font1.leading, font1b.leading),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lines.last!.ascent, s*max(font2.ascender, font2b.ascender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lines.last!.descent, s*max(-font2.descender, -font2b.descender),
                     accuracyInFloat32ULP: 1)

      expectEqual(tf.lines.last!.leading, s*max(font2.leading, font2b.leading),
                     accuracyInFloat32ULP: 1)

      assertLayoutInfoConsistency(tf)
    })()
  }

}
