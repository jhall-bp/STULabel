// Copyright 2017–2018 Stephan Tolksdorf

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (STUDynamicTypeScaling)

- (UIFont *)stu_fontAdjustedForContentSizeCategory:(UIContentSizeCategory)category;

@end

NS_ASSUME_NONNULL_END
