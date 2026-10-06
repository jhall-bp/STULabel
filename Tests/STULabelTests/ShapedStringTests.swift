// Copyright 2018 Stephan Tolksdorf

@preconcurrency import CoreText
import Foundation
import STULabelSwift
import Testing

private func createTypesetter(_ string: NSAttributedString) -> CTTypesetter {
  let ts = CTTypesetterCreateWithAttributedStringAndOptions(
    string, [kCTTypesetterOptionAllowUnboundedLayout: true] as CFDictionary)
  return ts!
}

struct ShapedStringTests {
  @MainActor
  @Test(arguments: ["A\nB", "\nB"], [CGFloat(20), 100])
  func scalingTextWithForcedLineBreakRespectsMaximumLineCount(_ text: String, height: CGFloat) {
    let font = UIFont.systemFont(ofSize: 18)
    let options = STUTextFrameOptions { builder in
      builder.maximumNumberOfLines = 1
      builder.minimumTextScaleFactor = 0.5
    }
    func frame(_ text: String) -> STUTextFrame {
      STUTextFrame(
        STUShapedString(NSAttributedString(string: text, attributes: [.font: font]),
                        defaultBaseWritingDirection: .leftToRight),
        size: CGSize(width: 200, height: height), displayScale: 0, options: options)
    }
    let truncated = frame(text)
    let visibleText = text.prefix(while: { $0 != "\n" }) + "…"
    let reference = frame(String(visibleText))
    #expect(truncated.lines.count == 1)
    #expect(truncated.flags.contains(.isTruncated))
    #expect(truncated.truncatedAttributedString.string == visibleText)
    #expect(abs(truncated.textScaleFactor - reference.textScaleFactor) < 0.0001)
  }

  @MainActor
  @Test
  func scalingSoftWrappedParagraphsFitsBeforeTruncating() {
    let text = "AAAA AAAA\nAAAA AAAA"
    let frame = STUTextFrame(
      STUShapedString(NSAttributedString(
        string: text, attributes: [.font: UIFont.monospacedSystemFont(ofSize: 18, weight: .regular)]),
        defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 70, height: 100), displayScale: 0,
      options: STUTextFrameOptions { builder in
        builder.maximumNumberOfLines = 2
        builder.minimumTextScaleFactor = 0.5
      })
    #expect(frame.lines.count == 2)
    #expect(!frame.flags.contains(.isTruncated))
    #expect(frame.truncatedAttributedString.string == text)
    #expect(frame.textScaleFactor > 0.5 && frame.textScaleFactor < 1)
  }

  @MainActor
  @Test
  func baselineOffsetDoesNotCarryIntoFollowingFallbackFontRun() throws {
    let font = try #require(UIFont(name: "Helvetica", size: 18))
    let raised = NSAttributedString(string: "A", attributes: [.font: font, .baselineOffset: 20])
    let normal = NSAttributedString(string: "界", attributes: [.font: font])
    let combined = NSMutableAttributedString(attributedString: raised)
    combined.append(normal)
    func frame(_ string: NSAttributedString) -> STUTextFrame {
      STUTextFrame(STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
                   size: CGSize(width: 1000, height: 100), displayScale: 0)
    }
    let raisedFrame = frame(raised)
    let normalFrame = frame(normal)
    let combinedFrame = frame(combined)
    let raisedLine = try #require(raisedFrame.lines.first)
    let normalLine = try #require(normalFrame.lines.first)
    let combinedLine = try #require(combinedFrame.lines.first)
    #expect(abs(combinedLine.ascent - max(raisedLine.ascent, normalLine.ascent)) < 0.0001)
    #expect(abs(combinedLine.descent - max(raisedLine.descent, normalLine.descent)) < 0.0001)
  }

  @MainActor
  @Test
  func discardedTruncationTokenDoesNotIncreaseLineStringRange() throws {
    let frame = STUTextFrame(
      STUShapedString(NSAttributedString(string: "A", attributes: [.font: UIFont.systemFont(ofSize: 18)]),
                      defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 1, height: 100), displayScale: 0,
      options: STUTextFrameOptions { builder in
        builder.maximumNumberOfLines = 1
        builder.truncationToken = NSAttributedString(string: "LONG TOKEN")
      })
    #expect(frame.truncatedAttributedString.string == "A")
    let line = try #require(frame.lines.first)
    #expect(line.rangeInTruncatedString == NSRange(location: 0, length: 1))
  }

  @MainActor
  @Test(arguments: [
    "\u{2069}אבג",
    "\u{2069}\u{2069}אבג",
    "\u{2069}\u{2066}abc\u{2069}אבג",
  ])
  func unmatchedDirectionalIsolatesDoNotHideParagraphDirection(_ text: String) {
    let string = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 18)])
    let frame = STUTextFrame(
      STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 1000, height: 100), displayScale: 0)
    #expect(frame.paragraphs[0].baseWritingDirection == .rightToLeft)
  }

  @MainActor
  @Test
  func hitTestingGlyphThatRepresentsManyGraphemeClusters() throws {
    let text = "abcdefghijklmnopq"
    let font = CTFontCreateWithName("Helvetica" as CFString, 18, nil)
    let glyph = CTFontGetGlyphWithName(font, "A" as CFString)
    let glyphInfo = try #require(CTGlyphInfoCreateWithGlyph(glyph, font, text as CFString))
    let string = NSAttributedString(
      string: text,
      attributes: [
        .font: font,
        NSAttributedString.Key(kCTGlyphInfoAttributeName as String): glyphInfo,
      ])
    // Require the platform to exercise the oversized glyph-to-string mapping.
    let line = CTLineCreateWithAttributedString(string)
    try #require(CTLineGetGlyphCount(line) == 1)
    let frame = STUTextFrame(
      STUShapedString(string, defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 1000, height: 100), displayScale: 0)
    let bounds = frame.layoutBounds
    let cluster = frame.rangeOfGraphemeCluster(
      closestTo: CGPoint(x: bounds.midX, y: bounds.midY),
      ignoringTrailingWhitespace: true, frameOrigin: .zero)
    #expect(cluster.range == frame.indices)
    #expect(!cluster.bounds.isEmpty)

    let firstCharacter = frame.range(forRangeInOriginalString: NSRange(location: 0, length: 1))
    let imageBounds = frame.imageBounds(frameOrigin: .zero)
    #expect(!imageBounds.isEmpty)
    #expect(frame.imageBounds(for: firstCharacter, frameOrigin: .zero) == imageBounds)
  }

  @MainActor
  @Test
  func untruncatedSubstringCacheIsReleasedWithTextFrame() {
    let shapedString = STUShapedString(
      NSAttributedString(string: "prefix retained substring suffix",
                         attributes: [.font: UIFont.systemFont(ofSize: 18)]),
      defaultBaseWritingDirection: .leftToRight)
    weak var cachedSubstring: NSAttributedString?
    autoreleasepool {
      let frame = STUTextFrame(
        shapedString, stringRange: NSRange(location: 7, length: 18),
        size: CGSize(width: 1000, height: 100), displayScale: 0)
      #expect(!frame.flags.contains(.isTruncated))
      cachedSubstring = frame.truncatedAttributedString
      #expect(cachedSubstring?.string == "retained substring")
      withExtendedLifetime(frame) {
        #expect(cachedSubstring != nil)
      }
    }
    withExtendedLifetime(shapedString) {
      #expect(cachedSubstring == nil)
    }
  }

  @Test
  func `CTTypesetter thread safety`() {
    seedRand(123)

    for translation in [
      udhr.translationsByLanguageCode["en"]!,
      udhr.translationsByLanguageCode["ar"]!,
      udhr.translationsByLanguageCode["hi"]!,
      udhr.translationsByLanguageCode["zh-Hant"]!,
    ] {
      let attributedString =
        translation.asAttributedString(
          titleAttributes: [.font: UIFont.systemFont(ofSize: 32)],
          bodyAttributes: [
            .font: UIFont(
              name: "HoeflerText-Regular",
              size: 16)!
          ],
          paragraphSeparator: " ")

      let string = attributedString.string
      let indices = Array(string.indices)
      let indicesCount = Int32(indices.count)

      struct TestCase {
        let index: Int
        let maxWidth: Double
        let length: Int
        let length2: Int
        let width: Double
        let width2: Double
      }

      let typesetter0 = createTypesetter(attributedString)

      func randomTestCase() -> TestCase {
        while true {
          let index = indices[rand(Int32(indices.count))].utf16Offset(in: string)
          let maxWidth = randU01() * 1000
          let length = CTTypesetterSuggestLineBreak(typesetter0, index, maxWidth)
          if length < 0 {
            fatalError()
          }
          let length2 = CTTypesetterSuggestClusterBreak(typesetter0, index, maxWidth)
          let line = CTTypesetterCreateLine(typesetter0, CFRangeMake(index, length))
          let width = CTLineGetTypographicBounds(line, nil, nil, nil)
          let line2 = CTTypesetterCreateLine(typesetter0, CFRangeMake(index, length2))
          let width2 = CTLineGetTypographicBounds(line2, nil, nil, nil)
          return TestCase(
            index: index, maxWidth: maxWidth, length: length, length2: length2,
            width: width, width2: width2)
        }

      }

      for j in 0..<10 {
        let testCases = Array(0..<1000).map({ _ in randomTestCase() })
        let typesetter = createTypesetter(attributedString)
        DispatchQueue.concurrentPerform(iterations: testCases.count) { @Sendable testCaseIndex in
          //for testCaseIndex in 0..<testCases.count {
          let tc = testCases[testCaseIndex]
          let c = (j + testCaseIndex) % 5
          switch c {
          case 0, 1:
            let length = CTTypesetterSuggestLineBreak(typesetter, tc.index, tc.maxWidth)
            #expect(length == tc.length)
            let line = CTTypesetterCreateLine(typesetter0, CFRangeMake(tc.index, tc.length))
            let width = CTLineGetTypographicBounds(line, nil, nil, nil)
            #expect(width == tc.width)
            if c == 0 { break }
            fallthrough
          case 2:
            let length2 = CTTypesetterSuggestClusterBreak(typesetter, tc.index, tc.maxWidth)
            #expect(length2 == tc.length2)
            let line = CTTypesetterCreateLine(typesetter0, CFRangeMake(tc.index, tc.length2))
            let width2 = CTLineGetTypographicBounds(line, nil, nil, nil)
            #expect(width2 == tc.width2)
          case 3:
            let line = CTTypesetterCreateLine(typesetter0, CFRangeMake(tc.index, tc.length))
            let width = CTLineGetTypographicBounds(line, nil, nil, nil)
            #expect(width == tc.width)
          case 4:
            let line = CTTypesetterCreateLine(typesetter0, CFRangeMake(tc.index, tc.length2))
            let width2 = CTLineGetTypographicBounds(line, nil, nil, nil)
            #expect(width2 == tc.width2)
          default: break
          }
        }
      }
    }
  }
}
