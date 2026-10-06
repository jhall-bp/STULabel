// Copyright 2017–2018 Stephan Tolksdorf

#import "STUTextRectArray.h"

#import "Internal/DisplayScaleRounding.hpp"
#import "Internal/TextFrame.hpp"
#import "Internal/TextLineSpan.hpp"

@interface STUTextRectArray (Internal)

// Transparent proxies forward equality to their underlying value. Subclasses whose own
// properties participate in equality return self.
- (const STUTextRectArray* __nonnull)stu_objectForEquality;
- (bool)stu_hasEqualTextRects:(const STUTextRectArray* __nonnull)other;

@end

STUTextRectArray* __nonnull STUTextRectArrayCreate(
                              __nullable Class cls,
                              stu::ArrayRef<const stu_label::TextLineSpan>,
                              stu::ArrayRef<const stu_label::TextFrameLine>,
                              stu_label::TextFrameOrigin,
                              const stu_label::TextFrameScaleAndDisplayScale&)
                            NS_RETURNS_RETAINED;

/// \pre `array` must have been created with `STUTextRectArrayCreate`
STUTextRectArray* __nonnull STUTextRectArrayCopyWithOffset(
                              __nonnull Class cls, const STUTextRectArray* array, CGPoint offset)
                            NS_RETURNS_RETAINED;

stu_label::Rect<CGFloat> STUTextRectArrayGetBounds(STUTextRectArray*);

STUIndexAndDistance STUTextRectArrayFindRectClosestToPoint(
                      const STUTextRectArray* self, CGPoint point, CGFloat maxDistance);

