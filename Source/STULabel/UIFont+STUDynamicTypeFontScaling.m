// Copyright 2017–2018 Stephan Tolksdorf

#import "UIFont+STUDynamicTypeFontScaling.h"

#import "stu_mutex.h"

#import <dispatch/dispatch.h>

#import <objc/runtime.h>

#import <stdatomic.h>

// Keep the system-default category first because this order determines the pointer fast-path cost.
// clang-format off
#define STU_FOR_EACH_CONTENT_SIZE_CATEGORY(f) \
  f(Large) \
  f(ExtraSmall) \
  f(Small) \
  f(Medium) \
  f(ExtraLarge) \
  f(ExtraExtraLarge) \
  f(ExtraExtraExtraLarge) \
  f(AccessibilityMedium) \
  f(AccessibilityLarge) \
  f(AccessibilityExtraLarge) \
  f(AccessibilityExtraExtraLarge) \
  f(AccessibilityExtraExtraExtraLarge)
// clang-format on

typedef NS_ENUM(uint8_t, STUContentSizeCategory) {
  STUContentSizeCategoryUnspecified = 0,
#define STU_CONTENT_SIZE_CATEGORY_ENUM_CASE(name) STUContentSizeCategory##name,
  STU_FOR_EACH_CONTENT_SIZE_CATEGORY(STU_CONTENT_SIZE_CATEGORY_ENUM_CASE)
#undef STU_CONTENT_SIZE_CATEGORY_ENUM_CASE
};
const int STUContentSizeCategoryCount = STUContentSizeCategoryAccessibilityExtraExtraExtraLarge + 1;

static STUContentSizeCategory stuContentSizeCategory(UIContentSizeCategory __unsafe_unretained cat)
{
  if (!cat)
    return STUContentSizeCategoryUnspecified;

  // UIKit supplies these singleton constants. Handle that hot path without any Objective-C calls.
#define STU_RETURN_IF_IDENTICAL_CONTENT_SIZE_CATEGORY(name)                                                            \
  if (cat == UIContentSizeCategory##name)                                                                              \
    return STUContentSizeCategory##name;
  STU_FOR_EACH_CONTENT_SIZE_CATEGORY(STU_RETURN_IF_IDENTICAL_CONTENT_SIZE_CATEGORY)
#undef STU_RETURN_IF_IDENTICAL_CONTENT_SIZE_CATEGORY

  // Preserve support for callers that construct an equivalent category value themselves.
#define STU_RETURN_IF_EQUAL_CONTENT_SIZE_CATEGORY(name)                                                                \
  if ([cat isEqualToString:UIContentSizeCategory##name])                                                               \
    return STUContentSizeCategory##name;
  STU_FOR_EACH_CONTENT_SIZE_CATEGORY(STU_RETURN_IF_EQUAL_CONTENT_SIZE_CATEGORY)
#undef STU_RETURN_IF_EQUAL_CONTENT_SIZE_CATEGORY

  return STUContentSizeCategoryUnspecified;
}

#undef STU_FOR_EACH_CONTENT_SIZE_CATEGORY

static Class nsNumberClass;
static Class nsStringClass;

static atomic_bool canScaleNonPreferredFonts;

static id valueForFontKey(UIFont *__unsafe_unretained font, NSString *__unsafe_unretained key, Class valueClass)
{
  if (atomic_load_explicit(&canScaleNonPreferredFonts, memory_order_relaxed)) {
    @try {
      const id value = [font valueForKey:key];
      if (value && [value isKindOfClass:valueClass]) {
        return value;
      }
    } @catch (NSException *__unused e) {
      atomic_store_explicit(&canScaleNonPreferredFonts, false, memory_order_relaxed);
    }
  }
  return nil;
}

static id stringForFontKey(UIFont *__unsafe_unretained font, NSString *__unsafe_unretained key)
{
  return valueForFontKey(font, key, nsStringClass);
}

static bool floatForFontKey(UIFont *__unsafe_unretained font, NSString *__unsafe_unretained key, CGFloat *outValue)
{
  NSNumber *const number = valueForFontKey(font, key, nsNumberClass);
  if (number != nil) {
#if CGFLOAT_IS_DOUBLE
    *outValue = number.doubleValue;
#else
    *outValue = number.floatValue;
#endif
    return true;
  }
  return false;
}

@interface STUWeakFontReference : NSObject {
@package // fileprivate
  UIFont *__weak font;
}
@end
@implementation STUWeakFontReference
@end

@implementation UIFont (STUDynamicTypeScaling)

- (UIFont *)stu_fontAdjustedForContentSizeCategory:(__unsafe_unretained UIContentSizeCategory)category
{
  const STUContentSizeCategory stuCategory = stuContentSizeCategory(category);
  if (!stuCategory) { // Unknown or unspecified category.
    return self;
  }
  const size_t index = (size_t)stuCategory - 1;

  static Class weakFontReferenceClass;

  STU_DISABLE_CLANG_WARNING("-Wgnu-folding-constant")
  static dispatch_once_t onces[STUContentSizeCategoryCount - 1];
  static UITraitCollection *traitCollections[STUContentSizeCategoryCount - 1];
  STU_REENABLE_CLANG_WARNING

  static dispatch_once_t once;
  dispatch_once(&once, ^{
    nsNumberClass = NSNumber.class;
    nsStringClass = NSString.class;
    weakFontReferenceClass = STUWeakFontReference.class;
    atomic_store_explicit(&canScaleNonPreferredFonts, true, memory_order_relaxed);
  });
  dispatch_once(&onces[index], ^{
    traitCollections[index] = [UITraitCollection traitCollectionWithPreferredContentSizeCategory:category];
  });

  const void *const associatedObjectKey = &traitCollections[index];

  STUWeakFontReference *weakRef;
  {
    const id cached = objc_getAssociatedObject(self, associatedObjectKey);
    if (cached) {
      if ((__bridge CFTypeRef)cached == kCFNull) {
        return self;
      }
      weakRef = cached;
      UIFont *const font = weakRef->font;
      if (font)
        return font;
    }
  }

  UIFontTextStyle style = [self.fontDescriptor objectForKey:UIFontDescriptorTextStyleAttribute];
  const bool isPreferredFont = style && [style hasPrefix:@"UICTFontTextStyle"];
  CGFloat sizeForScaling = 0;
  if (!isPreferredFont) {
    if (!(style = stringForFontKey(self, @"textStyleForScaling")) // assignment
        || !floatForFontKey(self, @"pointSizeForScaling", &sizeForScaling) || !(sizeForScaling > 0)) {
    FontCanNotBeScaled:
      if (atomic_load_explicit(&canScaleNonPreferredFonts, memory_order_relaxed)) {
        objc_setAssociatedObject(self, associatedObjectKey, (__bridge id)kCFNull, OBJC_ASSOCIATION_ASSIGN);
      }
      return self;
    }
  }

  UIFont *font = !isPreferredFont
                     ? [self fontWithSize:sizeForScaling]
                     : [UIFont preferredFontForTextStyle:style compatibleWithTraitCollection:traitCollections[index]];
  if (!font)
    goto FontCanNotBeScaled;

  CGFloat maxSize = 0;
  if (!floatForFontKey(self, @"maximumPointSizeAfterScaling", &maxSize)) {
    if (!isPreferredFont)
      goto FontCanNotBeScaled;
  }
  if (!isPreferredFont || maxSize > 0) {
    UIFontMetrics *const metrics = [[UIFontMetrics alloc] initForTextStyle:style];
    font = [metrics scaledFontForFont:font
                     maximumPointSize:maxSize
        compatibleWithTraitCollection:traitCollections[index]];
  }

  if (!weakRef) {
    weakRef = class_createInstance(weakFontReferenceClass, 0);
  }
  weakRef->font = font;
  objc_setAssociatedObject(self, associatedObjectKey, weakRef, OBJC_ASSOCIATION_RETAIN); // atomic

  return font;
}

@end
