// Copyright 2018 Stephan Tolksdorf

#include "stu/NSFoundationSupport.hpp"

#include "Localized.hpp"

#include "Equal.hpp"

#include "TestUtils.hpp"

@import STULabel;
@import STULabel.Unsafe;
@import STULabel.DynamicTypeFontScaling;
@import STULabel.ImageUtils;
@import STULabel.MainScreenProperties;
@import STULabel.Mutex;
@import STULabel.ObjCRuntimeWrappers;
@import STULabel.SwiftExtensions;

using namespace stu;

TEST_CASE_START(NSFoundationSupportTests)

TEST(TypeTraits)
{
  static_assert(isBridgableToId<CFStringRef>);
  static_assert(!isBridgableToId<NSString *>);
  static_assert(isConvertible<NSString *, id>);
  static_assert(isBlock<void (^)()>);
  static_assert(isConvertible<void (^)(), id>);
}

TEST(RefCountTraits)
{
  static_assert(isRefCountable<RemovePointer<CFArrayRef>>);
  static_assert(isRefCountable<NSArray>);
  const CFArrayRef obj = CFArrayCreateMutable(nullptr, 1, nullptr);
  XCTAssertEqual(CFGetRetainCount(obj), 1);
  incrementRefCount(obj);
  XCTAssertEqual(CFGetRetainCount(obj), 2);
  decrementRefCount(obj);
  XCTAssertEqual(CFGetRetainCount(obj), 1);
  incrementRefCount((__bridge NSArray *)obj);
  XCTAssertEqual(CFGetRetainCount(obj), 2);
  decrementRefCount((__bridge NSArray *)obj);
  XCTAssertEqual(CFGetRetainCount(obj), 1);
  decrementRefCount(obj);
}

TEST(RangeConversion)
{
  XCTAssertEqual(Range<UInt>(NSRange{.location = 1, .length = 2}), Range<UInt>(1, 3));
  {
    const auto range = NSRange(Range<UInt>(1, 3));
    XCTAssertEqual(range.location, 1);
    XCTAssertEqual(range.length, 2);
  }
  XCTAssertEqual(Range<UInt>(CFRange{.location = 1, .length = 2}), Range<UInt>(1, 3));
  {
    const auto range = CFRange(Range<Int>(1, 3));
    XCTAssertEqual(range.location, 1);
    XCTAssertEqual(range.length, 2);
  }
}

TEST(PackageResourcesAndNoARCPrerenderer)
{
  // The package target implements this using SwiftPM's generated resource bundle. The language
  // varies with the test host, so assert only that the default link-action string is available.
  NSString *const openAction = stu_label::localized(@"Open");
  XCTAssertNotNil(openAction);
  XCTAssertGreaterThan(openAction.length, 0u);

  // STULabelPrerenderer owns the implementation object compiled by STULabelNoARC.
  STULabelPrerenderer *const prerenderer = [STULabelPrerenderer new];
  prerenderer.attributedText = [[NSAttributedString alloc] initWithString:@"SwiftPM"];
  XCTAssertNotNil(prerenderer.shapedText);
}

TEST_CASE_END
