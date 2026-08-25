// Copyright 2018 Stephan Tolksdorf

import CoreText
import Foundation
import STULabelSwift
import Testing

private func createTypesetter(_ string: NSAttributedString) -> CTTypesetter {
  let ts = CTTypesetterCreateWithAttributedStringAndOptions(
    string, [kCTTypesetterOptionAllowUnboundedLayout: true] as CFDictionary)
  return ts!
}

struct ShapedStringTests {
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
