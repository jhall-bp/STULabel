// Copyright 2026 Stephan Tolksdorf

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (STUDynamicTypeScalingInternal)
- (UIFont *)stu_fontAdjustedForTraitCollection:(UITraitCollection *)traits;
@end

@interface NSAttributedString (STUDynamicTypeScalingInternal)
- (NSAttributedString *)stu_copyWithFontsAdjustedForTraitCollection:(UITraitCollection *)traits
    NS_RETURNS_RETAINED;
@end


NS_ASSUME_NONNULL_END
