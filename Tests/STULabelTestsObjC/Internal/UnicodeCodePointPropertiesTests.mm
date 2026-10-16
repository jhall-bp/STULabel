// Copyright 2017–2018 Stephan Tolksdorf

#import "TestUtils.h"
#import "UnicodeCodePointProperties.hpp"

#include <vector>

using namespace stu_label;

namespace {
#include "Unicode17PropertyData.inc"

constexpr UInt32 unicodeLimit = 0x110000;

template <typename Callback>
void forEachUnicodeRecord(const char *source, Callback callback)
{
  NSString *text = [[NSString alloc] initWithUTF8String:source];
  for (NSString *rawLine in [text componentsSeparatedByString:@"\n"]) {
    NSString *line = rawLine;
    if ([line hasPrefix:@"# @missing: "]) line = [line substringFromIndex:12];
    NSArray<NSString *> *fields = [line componentsSeparatedByString:@";"];
    if (fields.count < 2) continue;
    NSScanner *scanner = [NSScanner scannerWithString:fields[0]];
    unsigned int start = 0, end = 0;
    STU_CHECK([scanner scanHexInt:&start]);
    if ([scanner scanString:@".." intoString:nil]) STU_CHECK([scanner scanHexInt:&end]);
    else end = start;
    NSString *value = [fields.lastObject stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceCharacterSet]];
    callback(start, end, value);
  }
}

struct Unicode17Properties {
  std::vector<UInt8> bidi = std::vector<UInt8>(unicodeLimit);
  std::vector<UInt8> whitespace = std::vector<UInt8>(unicodeLimit);
  std::vector<UInt8> ignorable = std::vector<UInt8>(unicodeLimit);
  std::vector<UInt8> grapheme = std::vector<UInt8>(unicodeLimit);
  std::vector<UInt8> indic = std::vector<UInt8>(unicodeLimit);

  Unicode17Properties()
  {
    NSDictionary<NSString *, NSNumber *> *bidiValues = @{
      @"L": @1, @"Left_To_Right": @1, @"R": @2, @"Right_To_Left": @2,
      @"AL": @2, @"Arabic_Letter": @2, @"LRI": @3, @"RLI": @3, @"FSI": @3, @"PDI": @3
    };
    forEachUnicodeRecord(unicode17BidiClass, [&](UInt32 start, UInt32 end, NSString *value) {
      const UInt8 type = bidiValues[value].unsignedCharValue;
      for (UInt32 cp = start; cp <= end; ++cp) bidi[cp] = type;
    });
    forEachUnicodeRecord(unicode17WhiteSpace, [&](UInt32 start, UInt32 end, NSString *) {
      for (UInt32 cp = start; cp <= end; ++cp) whitespace[cp] = true;
    });
    forEachUnicodeRecord(unicode17DefaultIgnorable, [&](UInt32 start, UInt32 end, NSString *) {
      for (UInt32 cp = start; cp <= end; ++cp) ignorable[cp] = true;
    });
    // STULabel also ignores ISO controls other than whitespace and interlinear annotation controls.
    for (UInt32 cp = 0; cp < unicodeLimit; ++cp) {
      if (((cp <= 0x1f || (0x7f <= cp && cp <= 0x9f)) && !whitespace[cp])
          || (0xfff9 <= cp && cp <= 0xfffb)) ignorable[cp] = true;
    }
    NSDictionary<NSString *, NSNumber *> *graphemeValues = @{
      @"Other": @0, @"CR": @1, @"LF": @2, @"Control": @3, @"Prepend": @4,
      @"SpacingMark": @5, @"Extend": @6, @"ZWJ": @7, @"Regional_Indicator": @8,
      @"LVT": @10, @"LV": @11, @"L": @12, @"V": @13, @"T": @14
    };
    forEachUnicodeRecord(unicode17GraphemeBreak, [&](UInt32 start, UInt32 end, NSString *value) {
      STU_CHECK(graphemeValues[value] != nil);
      for (UInt32 cp = start; cp <= end; ++cp) grapheme[cp] = graphemeValues[value].unsignedCharValue;
    });
    forEachUnicodeRecord(unicode17ExtendedPictographic, [&](UInt32 start, UInt32 end, NSString *) {
      for (UInt32 cp = start; cp <= end; ++cp) {
        STU_CHECK(grapheme[cp] == 0);
        grapheme[cp] = 9;
      }
    });
    NSDictionary<NSString *, NSNumber *> *indicValues = @{@"Consonant": @1, @"Extend": @2, @"Linker": @3};
    forEachUnicodeRecord(unicode17IndicConjunctBreak, [&](UInt32 start, UInt32 end, NSString *value) {
      STU_CHECK(indicValues[value] != nil);
      for (UInt32 cp = start; cp <= end; ++cp) {
        indic[cp] = indicValues[value].unsignedCharValue;
        if (indic[cp] == 1) {
          STU_CHECK(grapheme[cp] == 0);
          grapheme[cp] = 15;
        }
      }
    });
    // Compatibility contract: preserve STULabel's historical Apple private-use assignments.
    // The public UCD intentionally does not assign these platform-specific properties.
    const UInt32 applePUA[][3] = {
      {0xF7F0, 0xF86F, 0x00}, {0xF870, 0xF87F, 0x60}, {0xF880, 0xF881, 0x01},
      {0xF882, 0xF883, 0x02}, {0xF884, 0xF899, 0x60}, {0xF89A, 0xF89E, 0x02},
      {0xF89F, 0xF89F, 0x60}, {0xF8A0, 0xF8A1, 0x00}, {0xF8A2, 0xF8AC, 0x01},
      {0xF8AD, 0xF8B1, 0x00}, {0xF8B2, 0xF8B3, 0x01}, {0xF8B4, 0xF8B7, 0x00},
      {0xF8B8, 0xF8B8, 0x01}, {0xF8B9, 0xF8C0, 0x00}, {0xF8C1, 0xF8D6, 0x01},
      {0xF8D7, 0xF8FF, 0x00}
    };
    for (const auto &range : applePUA) {
      for (UInt32 cp = range[0]; cp <= range[1]; ++cp) {
        bidi[cp] = range[2] & 3;
        grapheme[cp] = range[2] >> 4;
      }
    }
  }
};

const Unicode17Properties &unicode17Properties()
{
  static const Unicode17Properties properties;
  return properties;
}
} // namespace

@interface UnicodeCodePointPropertiesTests : XCTestCase
@end
@implementation UnicodeCodePointPropertiesTests

- (void)setUp
{
  [super setUp];
  self.continueAfterFailure = false;
  XCTAssertEqual(CodePointProperties::unicodeDataVersionMajor, 17);
}

- (void)testIsSurrogate
{
  for (uint32_t cp = 0; cp <= unicodeLimit + 3; ++cp) {
    XCTAssertEqual(isHighSurrogate(cp), cp <= 0xffff && CFStringIsSurrogateHighCharacter((UInt16)cp));
    XCTAssertEqual(isLowSurrogate(cp), cp <= 0xffff && CFStringIsSurrogateLowCharacter((UInt16)cp));
    XCTAssertEqual(isSurrogate(cp), isHighSurrogate(cp) || isLowSurrogate(cp));
  }
  XCTAssertFalse(isHighSurrogate(UINT32_MAX));
  XCTAssertFalse(isLowSurrogate(UINT32_MAX));
  XCTAssertFalse(isSurrogate(UINT32_MAX));
}

- (void)testCodePointFromSurrogatePair
{
  XCTAssertEqual(codePointFromSurrogatePair(0xD800, 0xDC00), CFStringGetLongCharacterForSurrogatePair(0xD800, 0xDC00));
  XCTAssertEqual(codePointFromSurrogatePair(0xD800, 0xDFFF), CFStringGetLongCharacterForSurrogatePair(0xD800, 0xDFFF));
  XCTAssertEqual(codePointFromSurrogatePair(0xDBFF, 0xDC00), CFStringGetLongCharacterForSurrogatePair(0xDBFF, 0xDC00));
  XCTAssertEqual(codePointFromSurrogatePair(0xDBFF, 0xDFFF), CFStringGetLongCharacterForSurrogatePair(0xDBFF, 0xDFFF));
}

- (void)testIsLineTerminator
{
  const CFCharacterSetRef set = CFCharacterSetGetPredefined(kCFCharacterSetNewline);
  for (uint32_t cp = 0; cp <= UINT16_MAX; ++cp) {
    XCTAssertEqual(isLineTerminator((uint16_t)cp), CFCharacterSetIsCharacterMember(set, (uint16_t)cp));
  }
}

- (void)testIsRegionalIndicator
{
  const auto &expected = unicode17Properties().grapheme;
  for (UInt32 cp = 0; cp < unicodeLimit; ++cp) {
    XCTAssertEqual(isRegionalIndicator(cp), expected[cp] == 8, @"code point 0x%x", cp);
  }
  XCTAssertFalse(isRegionalIndicator(UINT32_MAX));
}

- (void)testIsUnicodeWhitespace
{
  const auto &expected = unicode17Properties().whitespace;
  for (UInt32 cp = 0; cp < unicodeLimit; ++cp) {
    XCTAssertEqual(isUnicodeWhitespace(cp), bool(expected[cp]), @"code point 0x%x", cp);
  }
  XCTAssertFalse(isUnicodeWhitespace(UINT32_MAX));
}

- (void)testIsNotIgnorableAndNotWhitespaceWithCodePoint
{
  const auto &expected = unicode17Properties();
  for (UInt32 cp = 0; cp < unicodeLimit; ++cp) {
    XCTAssertEqual(isNotIgnorable(cp), !expected.ignorable[cp], @"code point 0x%x", cp);
    XCTAssertEqual(isNotIgnorableAndNotWhitespace(cp),
                   !(expected.ignorable[cp] || expected.whitespace[cp]), @"code point 0x%x", cp);
  }
  XCTAssertTrue(isNotIgnorable(UINT32_MAX));
  XCTAssertTrue(isNotIgnorableAndNotWhitespace(UINT32_MAX));
}

- (void)testBidiStrongType
{
  const auto &expected = unicode17Properties().bidi;
  for (UInt32 cp = 0; cp < unicodeLimit; ++cp) {
    XCTAssertEqual(bidiStrongType(cp), BidiStrongType(expected[cp]), @"code point 0x%x", cp);
  }
  XCTAssertEqual(bidiStrongType(UINT32_MAX), BidiStrongType::none);
}

- (void)testGraphemeClusterCategory
{
  const auto &expected = unicode17Properties();
  for (UInt32 cp = 0; cp < unicodeLimit; ++cp) {
    XCTAssertEqual(graphemeClusterCategory(cp), GraphemeClusterCategory(expected.grapheme[cp]),
                   @"code point 0x%x", cp);
    XCTAssertEqual(indicConjunctBreak(cp), IndicConjunctBreak(expected.indic[cp]), @"code point 0x%x", cp);
  }
  XCTAssertEqual(graphemeClusterCategory(UINT32_MAX), GraphemeClusterCategory::other);
  XCTAssertEqual(indicConjunctBreak(UINT32_MAX), IndicConjunctBreak::none);
}
@end
