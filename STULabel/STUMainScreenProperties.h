// Copyright 2016–2018 Stephan Tolksdorf

#import "STUDefines.h"

#import <UIKit/UIKit.h>

STU_EXTERN_C_BEGIN

typedef NS_ENUM(NSInteger, STUDisplayGamut)  {
STU_DISABLE_CLANG_WARNING("-Wunguarded-availability")
  STUDisplayGamutUnspecified = UIDisplayGamutUnspecified,
  STUDisplayGamutSRGB = UIDisplayGamutSRGB,
  STUDisplayGamutP3 = UIDisplayGamutP3
STU_REENABLE_CLANG_WARNING
};

/// This function is normally executed automatically when the library is loaded from an Objective C @c load initialization method.
/// If this leads to issues, you can define an @c STULabel_NoMainScreenPropertiesInitializationOnLoad environment variable
/// and then call this function explicity from the main thread before using any of the STULabel functionality.
void stu_initializeMainScreenProperties(void);

/// Returns the size in points of @c screen in its fixed coordinate space.
CGSize stu_screenPortraitSize(UIScreen *screen);

/// Returns the display scale of @c traitCollection.
CGFloat stu_displayScaleForTraitCollection(UITraitCollection *traitCollection);

/// Returns the display gamut of @c traitCollection.
STUDisplayGamut stu_displayGamutForTraitCollection(UITraitCollection *traitCollection);

/// Legacy process-wide main-screen value. Prefer @c stu_screenPortraitSize with the screen of a
/// window scene.
CGSize stu_mainScreenPortraitSize(void)
    __attribute__((deprecated("Use stu_screenPortraitSize with the screen of the window scene.")));

/// Legacy process-wide main-screen value. Prefer @c stu_displayScaleForTraitCollection with the
/// relevant view or window trait collection.
CGFloat stu_mainScreenScale(void)
    __attribute__((deprecated("Use stu_displayScaleForTraitCollection with a view or window trait collection.")));

/// Legacy process-wide main-screen value. Prefer @c stu_displayGamutForTraitCollection with the
/// relevant view or window trait collection.
STUDisplayGamut stu_mainScreenDisplayGamut(void)
    __attribute__((deprecated("Use stu_displayGamutForTraitCollection with a view or window trait collection.")));

STU_EXTERN_C_END
