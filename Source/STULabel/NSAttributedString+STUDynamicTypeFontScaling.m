// Copyright 2017–2018 Stephan Tolksdorf

#import "NSAttributedString+STUDynamicTypeFontScaling.h"

#import "UIFont+STUDynamicTypeFontScaling.h"
#import "Internal/DynamicTypeFontScaling.h"

typedef UIFont *(^FontAdjuster)(UIFont *);

static void adjustFontsInRange(NSMutableAttributedString *string, NSRange range, FontAdjuster adjustFont)
{
  UIFont *__unsafe_unretained __block previousFont = nil;
  UIFont *__unsafe_unretained __block previousScaledFont = nil;
  [string enumerateAttribute:NSFontAttributeName
                     inRange:range
                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                  usingBlock:^(id __unsafe_unretained value, NSRange attributeRange, BOOL *__unused stop) {
                    if (!value)
                      return;
                    UIFont *__unsafe_unretained const font = value;
                    if (font == previousFont) { // We use pointer equality here.
                      if (font != previousScaledFont) {
                        [string addAttribute:NSFontAttributeName value:previousScaledFont range:attributeRange];
                      }
                      return;
                    }
                    previousFont = font;
                    UIFont *const scaledFont = adjustFont(font);
                    previousScaledFont = scaledFont;
                    if (font != scaledFont) {
                      [string addAttribute:NSFontAttributeName value:scaledFont range:attributeRange];
                    }
                  }];
}

static NSAttributedString *copyWithAdjustedFonts(NSAttributedString *source, FontAdjuster adjustFont)
{
  __block NSUInteger start = NSNotFound;
  const NSUInteger length = source.length;
  UIFont *__unsafe_unretained __block previousFont = nil;
  [source enumerateAttribute:NSFontAttributeName
                     inRange:NSMakeRange(0, length)
                     options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                  usingBlock:^(id __unsafe_unretained value, NSRange range, BOOL *stop) {
                    if (!value || value == previousFont)
                      return;
                    UIFont *__unsafe_unretained const font = value;
                    previousFont = font;
                    if (font == adjustFont(font))
                      return;
                    start = range.location;
                    *stop = true;
                  }];
  if (start == NSNotFound)
    return [source copy];
  NSMutableAttributedString *const string = [source mutableCopy];
  adjustFontsInRange(string, NSMakeRange(start, length - start), adjustFont);
  return [string copy];
}

@implementation NSAttributedString (STUDynamicTypeScaling)

- (NSAttributedString *)stu_copyWithFontsAdjustedForContentSizeCategory:(UIContentSizeCategory)category
{
  return copyWithAdjustedFonts(self, ^UIFont *(UIFont *font) {
    return [font stu_fontAdjustedForContentSizeCategory:category];
  });
}
@end

@implementation NSAttributedString (STUDynamicTypeScalingInternal)

- (NSAttributedString *)stu_copyWithFontsAdjustedForTraitCollection:(UITraitCollection *)traits
{
  return copyWithAdjustedFonts(self, ^UIFont *(UIFont *font) {
    return [font stu_fontAdjustedForTraitCollection:traits];
  });
}
@end

@implementation NSMutableAttributedString (STUDynamicTypeScaling)

- (void)stu_adjustFontsInRange:(NSRange)range forContentSizeCategory:(UIContentSizeCategory)category
{
  adjustFontsInRange(self, range, ^UIFont *(UIFont *font) {
    return [font stu_fontAdjustedForContentSizeCategory:category];
  });
}
@end
