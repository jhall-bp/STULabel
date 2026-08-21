// Copyright 2016–2018 Stephan Tolksdorf

#import "STUDefines.h"

#import <UIKit/UIKit.h>

STU_EXTERN_C_BEGIN

typedef NS_ENUM(NSInteger, STUDisplayGamut) {
  STU_DISABLE_CLANG_WARNING("-Wunguarded-availability") STUDisplayGamutUnspecified = UIDisplayGamutUnspecified,
  STUDisplayGamutSRGB = UIDisplayGamutSRGB,
  STUDisplayGamutP3 = UIDisplayGamutP3 STU_REENABLE_CLANG_WARNING
};

/// Returns the display scale of @c traitCollection.
CGFloat stu_displayScaleForTraitCollection(UITraitCollection *traitCollection);

/// Returns the display gamut of @c traitCollection.
STUDisplayGamut stu_displayGamutForTraitCollection(UITraitCollection *traitCollection);

STU_EXTERN_C_END
