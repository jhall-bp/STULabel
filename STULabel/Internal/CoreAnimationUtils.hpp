// Copyright 2018 Stephan Tolksdorf

#import "STULabel/STUImageUtils.h"

#import "Common.hpp"

#import <QuartzCore/QuartzCore.h>

#import <pthread.h>

namespace stu_label {

STU_INLINE bool is_main_thread() { return pthread_main_np(); }

STU_INLINE bool inUIViewAnimation() { return [UIView inheritedAnimationDuration] > 0; }

UIWindow* window(CALayer* layer);

STUPredefinedCGImageFormat contentsImageFormat(NSString* caLayerContentsFormat,
                                               STUPredefinedCGImageFormat fallbackFormat);

void setContentsImageFormat(CALayer* layer, STUPredefinedCGImageFormat format);

} // namespace stu_label
