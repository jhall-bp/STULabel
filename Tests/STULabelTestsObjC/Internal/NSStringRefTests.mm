// Copyright 2018 Stephan Tolksdorf

#import "NSStringRef.hpp"

#import "TestUtils.h"

#include <vector>

using namespace stu_label;

@interface StringWrapper : NSString {
  NSString *_string;
}
@end
@implementation StringWrapper
- (instancetype)initWithString:(NSString *)string
{
  if ((self = [super init])) {
    _string = string;
  }
  return self;
}
- (NSUInteger)length
{
  return _string.length;
}
- (unichar)characterAtIndex:(NSUInteger)index
{
  return [_string characterAtIndex:index];
}
@end

@interface MutableStringRef : NSString {
@public
  const Char16 *utf16;
  UInt length;
  bool doNotReturnPointer;
}
@end
@implementation MutableStringRef

- (NSUInteger)length
{
  return self->length;
}

- (const Char16 *)_fastCharacterContents
{
  if (doNotReturnPointer)
    return nullptr;
  return utf16;
}

- (unichar)characterAtIndex:(NSUInteger)index
{
  STU_CHECK(index < length);
  return utf16[index];
}

- (void)getCharacters:(UTF16Char *)buffer range:(NSRange)range
{
  STU_CHECK(range.location <= length && range.length <= length - range.location);
  memcpy(buffer, utf16 + range.location, range.length * sizeof(UTF16Char));
}
@end

@interface NSStringRefTests : XCTestCase
@end

@implementation NSStringRefTests

- (void)setUp
{
  [super setUp];
  self.continueAfterFailure = false;
}

- (void)testConstructorAndIndexingOperator
{
  const auto test = [&](NSString *nsString) {
    const NSStringRef string{nsString};
    XCTAssertEqual((size_t)string.count(), nsString.length);
    if (string.count() != 0) {
      XCTAssertEqual(string[0], [nsString characterAtIndex:0]);
      XCTAssertEqual(string[string.count() - 1], [nsString characterAtIndex:nsString.length - 1]);
    }
#if STU_ASSERT_MAY_THROW
    CHECK_FAILS_ASSERT(string[-1]);
    CHECK_FAILS_ASSERT(string[string.count()]);
    CHECK_FAILS_ASSERT(string[string.count() + 1]);
    CHECK_FAILS_ASSERT(string[maxValue<Int>]);
#endif
  };
  const auto test3 = [&](NSString *nsString) {
    test(nsString);
    test([[NSMutableString alloc] initWithString:nsString]);
    test([[StringWrapper alloc] initWithString:nsString]);
  };
  test3(@"");
  test3(@"x");
  test3(@"abc");
  test3(@"äöüß");
}

static Int indexOf(const NSStringRef &string, Range<Int> range, Char16 ch)
{
  STU_CHECK(0 <= range.start && range.end <= string.count());
  if (range.isEmpty())
    return range.start;
  for (Int index = range.start; index < range.end; ++index) {
    if (string[index] == ch)
      return index;
  }
  return range.end;
}

static Int indexOf(const NSStringRef &string, Range<Int> range, Char32 cp)
{
  STU_CHECK(0 <= range.start && range.end <= string.count());
  if (range.isEmpty())
    return range.start;
  Char32 cp2;
  for (Int index = range.start; index < range.end; index += cp2 <= 0xffff ? 1 : 2) {
    const Char16 ch0 = string[index];
    if (isHighSurrogate(ch0) && index + 1 < range.end && isLowSurrogate(string[index + 1])) {
      cp2 = codePointFromSurrogatePair(ch0, string[index + 1]);
    } else {
      cp2 = ch0;
    }
    if (cp2 == cp)
      return index;
  }
  return range.end;
}

static Int lastEndIndexOf(const NSStringRef &string, Range<Int> range, Char32 cp)
{
  STU_CHECK(0 <= range.start && range.end <= string.count());
  if (range.isEmpty())
    return range.start;
  Char32 cp2;
  for (Int index = range.end; index > range.start; index -= cp2 <= 0xffff ? 1 : 2) {
    const Char16 ch1 = string[index - 1];
    if (isLowSurrogate(ch1) && index - 2 >= range.start && isHighSurrogate(string[index - 2])) {
      cp2 = codePointFromSurrogatePair(string[index - 2], ch1);
    } else {
      cp2 = ch1;
    }
    if (cp2 == cp)
      return index;
  }
  return range.start;
}

- (void)testIndexWhereMethods
{
  {
    const auto alwaysTrue = [](auto) { return true; };
#if STU_ASSERT_MAY_THROW
    CHECK_FAILS_ASSERT((NSStringRef{@""}.indexOfFirstUTF16CharWhere({-1, 0}, alwaysTrue)));
    CHECK_FAILS_ASSERT((NSStringRef{@"1"}.indexOfFirstUTF16CharWhere({0, -1}, alwaysTrue)));
    CHECK_FAILS_ASSERT((NSStringRef{@""}.indexOfFirstCodePointWhere({-1, 0}, alwaysTrue)));
    CHECK_FAILS_ASSERT((NSStringRef{@"1"}.indexOfFirstCodePointWhere({0, -1}, alwaysTrue)));
    CHECK_FAILS_ASSERT((NSStringRef{@""}.indexOfEndOfLastCodePointWhere({-1, 0}, alwaysTrue)));
    CHECK_FAILS_ASSERT((NSStringRef{@"1"}.indexOfEndOfLastCodePointWhere({0, -1}, alwaysTrue)));
#endif
    XCTAssertEqual((NSStringRef{@"1"}.indexOfFirstUTF16CharWhere({1, 0}, alwaysTrue)), 1);
    XCTAssertEqual((NSStringRef{@"1"}.indexOfFirstCodePointWhere({1, 0}, alwaysTrue)), 1);
    XCTAssertEqual((NSStringRef{@"1"}.indexOfEndOfLastCodePointWhere({1, 0}, alwaysTrue)), 1);
  }
  const auto test = [&](const NSStringRef &str, Range<Int> range, Char32 cp) {
    const auto isEqual = [&](auto cp2) { return cp == cp2; };
    {
      const Char16 ch = narrow_cast<Char16>(cp);
      const Int index = indexOf(str, range, ch);
      XCTAssertEqual(str.indexOfFirstUTF16CharWhere(range, isEqual), index);
    }
    {
      const Int index = indexOf(str, range, cp);
      if (str.indexOfFirstCodePointWhere(range, isEqual) != index) {
        XCTAssertEqual(str.indexOfFirstCodePointWhere(range, isEqual), index);
      }
    }
    {
      const Int index = lastEndIndexOf(str, range, cp);
      XCTAssertEqual(str.indexOfEndOfLastCodePointWhere(range, isEqual), index);
    }
  };
  const auto test2 = [&](NSString *string, uint32_t cp) {
    NSMutableString *const mutableString = [[NSMutableString alloc] initWithString:string];
    StringWrapper *const stringWrapper = [[StringWrapper alloc] initWithString:string];

    NSMutableString *const longString1 = [[NSMutableString alloc] init];
    NSMutableString *const longString2 = [[NSMutableString alloc] init];
    // The internal buffer in NSStringRefBuffer has a capacity of 64 chars.
    [longString1 appendString:@"0123456789012345678901234567890123456789012345678901234567890123"];
    [longString2 appendString:@"0123456789012345678901234567890123456789012345678901234567890123"];
    [longString2 appendString:@"0123456789012345678901234567890123456789012345678901234567890123"];
    [longString1 appendString:string];
    [longString2 appendString:string];
    StringWrapper *const longString1Wrapper = [[StringWrapper alloc] initWithString:longString1];
    StringWrapper *const longString2Wrapper = [[StringWrapper alloc] initWithString:longString2];

    const NSStringRef ref1{string};
    const NSStringRef ref2{mutableString};
    const NSStringRef ref3{stringWrapper};

    const NSStringRef longRef1{longString1Wrapper};
    const NSStringRef longRef2{longString2Wrapper};

    const Int length = ref1.count();
    for (Int i = 0; i <= length; ++i) {
      for (Int j = 0; j <= length; ++j) {
        test(ref1, {i, j}, cp);
        test(ref2, {i, j}, cp);
        test(ref3, {i, j}, cp);
      }
      test(longRef1, {0, 64 + i}, cp);
      test(longRef2, {0, 128 + i}, cp);
      test(longRef1, {i, 64 + length}, cp);
      test(longRef2, {i, 128 + length}, cp);
    }
  };
  test2(@"", '\0');
  test2(@"t", 't');
  test2(@"t", 's');
  test2(@"tt", 't');
  test2(@"tet", 't');
  test2(@"😀", '3');
  test2(@"😀", U'😀');
  test2(@"😁😀😁", U'😀');
  test2(@"😁😀😁", U'😁');
  test2(@"😁😀😁", 0xD83D);
  test2(@"😁😀😁", 0xDE00);
  test2(@"4😀5", U'😀');
  test2(@"4😀5", U'😁');
  test2(@"4😀5", 0xD83D);
  test2(@"4😀5", 0xDE00);
  test2(@"4😀5", 4);
  test2(@"4😀5", 4);

  // Test the handling of unpaired surrogate code units.
  {
    unichar array[] = {0xD83D};
    NSString *string = [[NSString alloc] initWithCharactersNoCopy:array length:arrayLength(array) freeWhenDone:false];
    test2(string, '3');
    test2(string, 0xD83D);
    test2(string, 0xD83F);
  }
  {
    unichar array[] = {'x', 0xD83D, 'y'};
    NSString *string = [[NSString alloc] initWithCharactersNoCopy:array length:arrayLength(array) freeWhenDone:false];
    test2(string, 'x');
    test2(string, 'y');
    test2(string, 0xD83D);
    test2(string, 0xD83f);
  }
  {
    unichar array[] = {0xD83D, 0xD83D, 0xDE01};
    NSString *string = [[NSString alloc] initWithCharactersNoCopy:array length:arrayLength(array) freeWhenDone:false];
    test2(string, 0xD83D);
  }
  {
    unichar array[] = {0xDE01};
    NSString *string = [[NSString alloc] initWithCharactersNoCopy:array length:arrayLength(array) freeWhenDone:false];
    test2(string, '3');
    test2(string, 0xDE01);
    test2(string, 0xDE00);
  }
  {
    unichar array[] = {'x', 0xDE01, 'y'};
    NSString *string = [[NSString alloc] initWithCharactersNoCopy:array length:arrayLength(array) freeWhenDone:false];
    test2(string, 'x');
    test2(string, 'y');
    test2(string, 0xDE01);
    test2(string, 0xDE00);
  }
}

- (void)testIndexOfTrailingWhitespace
{
  XCTAssertEqual(NSStringRef(@"").indexOfTrailingWhitespaceIn({}), 0);
  XCTAssertEqual(NSStringRef(@" ").indexOfTrailingWhitespaceIn({0, 1}), 0);
  XCTAssertEqual(NSStringRef(@"x").indexOfTrailingWhitespaceIn({0, 1}), 1);
  XCTAssertEqual(NSStringRef(@"x ").indexOfTrailingWhitespaceIn({0, 2}), 1);
  XCTAssertEqual(NSStringRef(@"x \t").indexOfTrailingWhitespaceIn({0, 3}), 1);
  // \u00ad is "ignorable"
  XCTAssertEqual(NSStringRef(@"x \u00ad").indexOfTrailingWhitespaceIn({0, 3}), 1);
  XCTAssertEqual(NSStringRef(@"x \u00ad ").indexOfTrailingWhitespaceIn({0, 4}), 1);
  XCTAssertEqual(NSStringRef(@"x\u00ad").indexOfTrailingWhitespaceIn({0, 2}), 2);
  XCTAssertEqual(NSStringRef(@"x\u00ad ").indexOfTrailingWhitespaceIn({0, 3}), 2);
}

- (void)testGraphemeClusterSearchDoesNotPairSurrogatesOutsideTheString
{
  // The neighboring units deliberately form an emoji with either unpaired boundary surrogate.
  const Char16 storage[] = {0xD83D, 0xDE00, 0x200D, 0xD83D, 0xDE00};
  MutableStringRef *nsString = [[MutableStringRef alloc] init];
  nsString->utf16 = storage;
  nsString->length = 4;
  const NSStringRef trailingHighSurrogate{nsString};
  XCTAssertEqual(trailingHighSurrogate.startIndexOfGraphemeClusterAt(3), 3);

  nsString->utf16 = storage + 1;
  const NSStringRef leadingLowSurrogate{nsString};
  XCTAssertNoThrow(XCTAssertEqual(leadingLowSurrogate.indexOfFirstGraphemeClusterBreakNotBefore(1), 2));
}

- (void)testUnicode17GraphemeClusterBreakFinding
{
  // The conformance fixture owns the expected boundaries. System ICU may use an older UCD.
  static const char corpus[] =
#include "Unicode17GraphemeBreakTest.inc"
  ;
  NSString *text = [[NSString alloc] initWithUTF8String:corpus];
  NSUInteger caseCount = 0;
  for (NSString *line in [text componentsSeparatedByString:@"\n"]) {
    NSString *data = [[line componentsSeparatedByString:@"#"] firstObject];
    NSArray<NSString *> *tokens = [data componentsSeparatedByCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]];
    NSMutableString *input = [NSMutableString string];
    NSMutableArray<NSNumber *> *breaks = [NSMutableArray array];
    for (NSString *token in tokens) {
      if ([token isEqualToString:@"÷"]) {
        [breaks addObject:@(input.length)];
      } else if (token.length != 0 && ![token isEqualToString:@"×"]) {
        unsigned int scalar = 0;
        XCTAssertTrue([[NSScanner scannerWithString:token] scanHexInt:&scalar]);
        UTF16Char units[2];
        if (scalar <= 0xffff) {
          units[0] = static_cast<UTF16Char>(scalar);
          [input appendString:[NSString stringWithCharacters:units length:1]];
        } else {
          CFStringGetSurrogatePairForLongCharacter(scalar, units);
          [input appendString:[NSString stringWithCharacters:units length:2]];
        }
      }
    }
    if (input.length == 0) continue;
    ++caseCount;
    const Int count = sign_cast(input.length);
    std::vector<Char16> units(input.length);
    [input getCharacters:reinterpret_cast<UTF16Char *>(units.data()) range:NSMakeRange(0, input.length)];
    MutableStringRef *wrapper = [[MutableStringRef alloc] init];
    wrapper->utf16 = units.data();
    wrapper->length = input.length;
    wrapper->doNotReturnPointer = true;
    NSStringRef string{wrapper};
    const auto method = string._private_guts().method;
    for (const bool buffered : {false, true}) {
      if (buffered) string._private_setGuts({.count = count, .method = method});
      else string._private_setGuts({.count = count, .utf16 = units.data()});
      for (NSUInteger cluster = 0; cluster + 1 < breaks.count; ++cluster) {
        const Int start = breaks[cluster].integerValue;
        const Int end = breaks[cluster + 1].integerValue;
        for (Int index = start; index < end; index += 1 + (string.codePointAtUTF16Index(index) > 0xffff)) {
          XCTAssertEqual(string.startIndexOfGraphemeClusterAt(index), start, @"%@ (%d)", line, buffered);
          XCTAssertEqual(string.endIndexOfGraphemeClusterAt(index), end, @"%@ (%d)", line, buffered);
          XCTAssertEqual(string.indexOfFirstGraphemeClusterBreakNotBefore(index),
                         index == start ? start : end, @"%@ (%d)", line, buffered);
          if (index > start) {
            XCTAssertEqual(string.indexOfLastGraphemeClusterBreakBefore(index), start, @"%@ (%d)", line, buffered);
          }
        }
        XCTAssertEqual(string.indexOfLastGraphemeClusterBreakBefore(end), start, @"%@ (%d)", line, buffered);
      }
    }
  }
  XCTAssertEqual(caseCount, 766U);
}

- (void)testLongIndicConjunctSearch
{
  // GB9c applies across arbitrarily many linkers and extends, including NSString buffer refills.
  NSMutableString *chain = [NSMutableString string];
  for (int index = 0; index < 4096; ++index) [chain appendString:@"क्"];
  [chain appendString:@"ष"];
  NSMutableString *marks = [NSMutableString stringWithString:@"क"];
  for (int index = 0; index < 4096; ++index) [marks appendString:@"\u0300"];
  [marks appendString:@"्"];
  for (int index = 0; index < 4096; ++index) [marks appendString:@"\u0300"];
  [marks appendString:@"ष"];
  for (NSString *input in @[chain, marks]) {
    for (const bool buffered : {false, true}) {
      NSString *backing = buffered ? [[StringWrapper alloc] initWithString:input] : input;
      NSStringRef string{backing};
      for (const Int index : {Int(0), Int(1), Int(63), Int(64), Int(4096), string.count() - 1}) {
        XCTAssertEqual(string.startIndexOfGraphemeClusterAt(index), 0);
        XCTAssertEqual(string.endIndexOfGraphemeClusterAt(index), string.count());
      }
      XCTAssertEqual(string.countGraphemeClusters(), 1);
    }
  }
}

- (void)testLongIndicConjunctSearchPerformance
{
  for (const Int count : {Int(2048), Int(4096)}) {
    NSMutableString *input = [NSMutableString string];
    for (Int index = 0; index < count; ++index) [input appendString:@"क्"];
    [input appendString:@"ष"];
    NSStringRef string{input};
    NSMutableArray<NSNumber *> *samples = [NSMutableArray array];
    Int checksum = 0;
    for (int sample = 0; sample < 7; ++sample) {
      const CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
      for (int iteration = 0; iteration < 200; ++iteration) {
        // Each pass must read the string again; the search functions are declared pure.
        asm volatile("" : : "g"(&string) : "memory");
        checksum += string.endIndexOfGraphemeClusterAt(0);
        checksum += string.indexOfLastGraphemeClusterBreakBefore(string.count());
      }
      [samples addObject:@(CFAbsoluteTimeGetCurrent() - begin)];
    }
    [samples sortUsingSelector:@selector(compare:)];
    NSLog(@"Long Indic conjunct: median %.6f s / 200 forward+backward passes, %lu UTF-16 units",
          samples[3].doubleValue, input.length);
    XCTAssertGreaterThan(checksum, 0);
  }
}

- (void)testGraphemeClusterSearchPerformance
{
  // Repeat the same public string workloads before and after segmentation changes.
  // These measurements are informational: correctness is asserted by the UCD corpus.
  NSArray<NSString *> *patterns = @[@"The quick brown fox jumps over the lazy dog. ",
                                    @"Café e\u0301cole A\u0308pfel ",
                                    @"👩🏽‍🚀👨‍👩‍👦🇦🇺",
                                    @"क्षि क्\u200Dष त्र ज्ञ "];
  NSArray<NSString *> *names = @[@"ASCII", @"Latin combining", @"Emoji", @"Indic conjuncts"];
  for (NSUInteger workload = 0; workload < patterns.count; ++workload) {
    NSMutableString *input = [NSMutableString string];
    while (input.length < 4096) [input appendString:patterns[workload]];
    NSStringRef string{input};
    NSMutableArray<NSNumber *> *samples = [NSMutableArray array];
    Int checksum = 0;
    for (int sample = 0; sample < 7; ++sample) {
      const CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();
      for (int iteration = 0; iteration < 200; ++iteration) {
        // Each pass must read the string again; the search functions are declared pure.
        asm volatile("" : : "g"(&string) : "memory");
        for (Int index = 0; index < string.count();) {
          index = string.endIndexOfGraphemeClusterAt(index);
          checksum += index;
        }
        for (Int index = string.count(); index > 0;) {
          index = string.indexOfLastGraphemeClusterBreakBefore(index);
          checksum += index;
        }
      }
      [samples addObject:@(CFAbsoluteTimeGetCurrent() - begin)];
    }
    [samples sortUsingSelector:@selector(compare:)];
    NSLog(@"Grapheme search %@: median %.6f s / 200 forward+backward passes, %lu UTF-16 units",
          names[workload], samples[3].doubleValue, input.length);
    XCTAssertGreaterThan(checksum, 0);
  }
}

@end
