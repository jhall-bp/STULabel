import Foundation
import STULabelSwift
import Testing

@MainActor
struct TextFrameOptionsTests {
  @Test
  func initializers() {
    let opts0 = STUTextFrameOptions()
    #expect(opts0.textLayoutMode == .default)
    #expect(
      opts0.defaultTextAlignment == STUDefaultTextAlignment(
        rawValue: stu_defaultBaseWritingDirection().rawValue)!)
    #expect(opts0.maximumNumberOfLines == 0)
    #expect(opts0.lastLineTruncationMode == .end)
    #expect(opts0.truncationToken == nil)
    #expect(opts0.truncationRangeAdjuster == nil)
    #expect(opts0.minimumTextScaleFactor == 1)
    #expect(opts0.textScalingBaselineAdjustment == .none)
    #expect(opts0.lastHyphenationLocationInRangeFinder == nil)

    let opts0b = STUTextFrameOptions { builder in }
    #expect(opts0b.textLayoutMode == .default)
    #expect(
      opts0b.defaultTextAlignment == STUDefaultTextAlignment(
        rawValue: stu_defaultBaseWritingDirection().rawValue)!)
    #expect(opts0b.maximumNumberOfLines == 0)
    #expect(opts0b.lastLineTruncationMode == .end)
    #expect(opts0b.truncationToken == nil)
    #expect(opts0b.truncationRangeAdjuster == nil)
    #expect(opts0b.minimumTextScaleFactor == 1)
    #expect(opts0b.textScalingBaselineAdjustment == .none)
    #expect(opts0b.lastHyphenationLocationInRangeFinder == nil)

    let nonDefaultTruncationToken = NSAttributedString(string: "test")
    let nonDefaultTextAlignment =
      STUDefaultTextAlignment(rawValue: stu_defaultBaseWritingDirection().rawValue ^ 1)!

    let dummyTruncationRangeAdjuster: STUTruncationRangeAdjuster = { (_, _, r) in r }
    let dummyHyphenationLocationFinder: STULastHyphenationLocationInRangeFinder = { (_, _) in
      STUHyphenationLocation(index: 0, hyphen: UnicodeScalar("-").value, options: [])
    }
    let opts1 = STUTextFrameOptions { builder in
      builder.textLayoutMode = .textKit
      builder.defaultTextAlignment = nonDefaultTextAlignment
      builder.maximumNumberOfLines = 3
      builder.lastLineTruncationMode = .middle
      builder.truncationToken = nonDefaultTruncationToken
      builder.truncationRangeAdjuster = dummyTruncationRangeAdjuster
      builder.minimumTextScaleFactor = 0.25
      builder.textScalingBaselineAdjustment = .alignFirstLineXHeightCenter
      builder.lastHyphenationLocationInRangeFinder = dummyHyphenationLocationFinder
    }
    #expect(opts1.textLayoutMode == .textKit)
    #expect(opts1.defaultTextAlignment == nonDefaultTextAlignment)
    #expect(opts1.maximumNumberOfLines == 3)
    #expect(opts1.lastLineTruncationMode == .middle)
    #expect(opts1.truncationToken == nonDefaultTruncationToken)
    #expect(opts1.truncationRangeAdjuster != nil)
    #expect(opts1.minimumTextScaleFactor == 0.25)
    #expect(opts1.textScalingBaselineAdjustment == .alignFirstLineXHeightCenter)
    #expect(opts1.lastHyphenationLocationInRangeFinder != nil)

    let opts1b = opts1.copy(updates: { (_: STUTextFrameOptionsBuilder) in })
    #expect(opts1b.textLayoutMode == .textKit)
    #expect(opts1b.defaultTextAlignment == nonDefaultTextAlignment)
    #expect(opts1b.maximumNumberOfLines == 3)
    #expect(opts1b.lastLineTruncationMode == .middle)
    #expect(opts1b.truncationToken == nonDefaultTruncationToken)
    #expect(opts1b.truncationRangeAdjuster != nil)
    #expect(opts1b.minimumTextScaleFactor == 0.25)
    #expect(opts1b.textScalingBaselineAdjustment == .alignFirstLineXHeightCenter)
    #expect(opts1b.lastHyphenationLocationInRangeFinder != nil)

    let opts2 = opts1b.copy { (builder) in builder.maximumNumberOfLines += 1 }
    #expect(opts2.textLayoutMode == .textKit)
    #expect(opts2.defaultTextAlignment == nonDefaultTextAlignment)
    #expect(opts2.maximumNumberOfLines == 4)
    #expect(opts2.lastLineTruncationMode == .middle)
    #expect(opts2.truncationToken == nonDefaultTruncationToken)
    #expect(opts2.truncationRangeAdjuster != nil)
    #expect(opts2.minimumTextScaleFactor == 0.25)
    #expect(opts2.textScalingBaselineAdjustment == .alignFirstLineXHeightCenter)
    #expect(opts2.lastHyphenationLocationInRangeFinder != nil)
  }

  @Test
  func `Parameter clamping`() {
    let builder = STUTextFrameOptionsBuilder()
    builder.textLayoutMode = unsafeBitCast(UInt8(255), to: STUTextLayoutMode.self)
    #expect(builder.textLayoutMode == .default)

    builder.defaultTextAlignment = unsafeBitCast(UInt8(255), to: STUDefaultTextAlignment.self)
    #expect(builder.defaultTextAlignment == .left)

    builder.maximumNumberOfLines = .min
    #expect(builder.maximumNumberOfLines == 0)

    builder.maximumNumberOfLines = .max
    #expect(builder.maximumNumberOfLines == .max)

    builder.lastLineTruncationMode = unsafeBitCast(UInt8(255), to: STULastLineTruncationMode.self)
    #expect(builder.lastLineTruncationMode == .end)

    builder.minimumTextScaleFactor = 0
    #expect(builder.minimumTextScaleFactor == 1)
    builder.minimumTextScaleFactor = -1
    #expect(builder.minimumTextScaleFactor == 1)
    builder.minimumTextScaleFactor = 2
    #expect(builder.minimumTextScaleFactor == 1)
    builder.minimumTextScaleFactor = 0.5
    #expect(builder.minimumTextScaleFactor == 0.5)

    builder.textScalingBaselineAdjustment = unsafeBitCast(
      UInt8(255), to: STUBaselineAdjustment.self)
    #expect(builder.textScalingBaselineAdjustment == .none)

    builder.textScaleFactorStepSize = 0
    #expect(builder.textScaleFactorStepSize == 0)
    builder.textScaleFactorStepSize = -1
    #expect(builder.textScaleFactorStepSize == 0)
    builder.textScaleFactorStepSize = 2
    #expect(builder.textScaleFactorStepSize == 1)
  }

  @Test
  func `Truncation token is copied`() {
    let string = NSMutableAttributedString(string: "test")
    let builder = STUTextFrameOptionsBuilder()
    builder.truncationToken = string
    #expect(builder.truncationToken !== string)
    #expect(builder.truncationToken == string)
    #expect(!builder.truncationToken!.isKind(of: NSMutableAttributedString.self))
  }
}
