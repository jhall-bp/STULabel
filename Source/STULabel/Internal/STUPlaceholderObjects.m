// Copyright 2017–2018 Stephan Tolksdorf

#import "STUPlaceholderObjects.h"

#import "STULabel/STUShapedString.h"

// We use forward declarations here to avoid importing the corresponding implementation headers.

STU_EXTERN_C_BEGIN

STUShapedString *__nullable STUShapedStringCreate(__nullable Class cls,
                                                  NSAttributedString *__nonnull,
                                                  STUWritingDirection,
                                                  const STUCancellationFlag *) NS_RETURNS_RETAINED;

STUTextFrame *__nonnull STUTextFrameCreateWithShapedString(__nullable Class cls,
                                                           STUShapedString *__nonnull shapedString,
                                                           CGSize size,
                                                           CGFloat displayScale,
                                                           STUTextFrameOptions *__nullable options) NS_RETURNS_RETAINED;

STUTextFrame *__nonnull STUTextFrameCreateWithShapedStringRange(__nullable Class cls,
                                                                STUShapedString *__nonnull shapedString,
                                                                NSRange stringRange,
                                                                CGSize size,
                                                                CGFloat displayScale,
                                                                STUTextFrameOptions *__nullable options,
                                                                const STUCancellationFlag *) NS_RETURNS_RETAINED;

STU_EXTERN_C_END

STU_DISABLE_CLANG_WARNING("-Wobjc-designated-initializers")

@implementation STUUninitializedShapedString

- (STUShapedString *)initWithAttributedString:(NSAttributedString *)attributedString
{
  return (id)STUShapedStringCreate(nil, attributedString, stu_defaultBaseWritingDirection(), nil);
}

- (STUShapedString *)initWithAttributedString:(NSAttributedString *)attributedString
                  defaultBaseWritingDirection:(STUWritingDirection)baseWritingDirection
{
  return (id)STUShapedStringCreate(nil, attributedString, baseWritingDirection, nil);
}

- (nullable STUShapedString *)initWithAttributedString:(NSAttributedString *)attributedString
                           defaultBaseWritingDirection:(STUWritingDirection)baseWritingDirection
                                      cancellationFlag:(nullable const STUCancellationFlag *)cancellationFlag
{
  return (id)STUShapedStringCreate(nil, attributedString, baseWritingDirection, cancellationFlag);
}

@end

@implementation STUUninitializedTextFrame

- (nonnull STUTextFrame *)initWithShapedString:(nonnull STUShapedString *)shapedString
                                          size:(CGSize)size
                                  displayScale:(CGFloat)displayScale
                                       options:(STUTextFrameOptions *__nullable)options
{
  return (id)STUTextFrameCreateWithShapedString(nil, shapedString, size, displayScale, options);
}

- (nullable STUTextFrame *)initWithShapedString:(nonnull STUShapedString *)shapedString
                                    stringRange:(NSRange)stringRange
                                           size:(CGSize)size
                                   displayScale:(CGFloat)displayScale
                                        options:(STUTextFrameOptions *__nullable)options
                               cancellationFlag:(nullable const STUCancellationFlag *)cancellationFlag
{
  return (id)STUTextFrameCreateWithShapedStringRange(
      nil, shapedString, stringRange, size, displayScale, options, cancellationFlag);
}

@end

STU_REENABLE_CLANG_WARNING
