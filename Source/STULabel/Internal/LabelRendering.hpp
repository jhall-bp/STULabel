// Copyright 2017–2018 Stephan Tolksdorf

#import "STULabel/STUTextFrame-Unsafe.h"

#import "STULabel/STUImageUtils.h"

#import "STULabel/STULabelDrawingBlock.h"
#import "STULabel/STULabelLayoutInfo-Internal.hpp"


#import "PurgeableImage.hpp"

#import <UIKit/UITraitCollection.h>

namespace stu_label {

enum class LabelRenderMode : UInt8 {
  drawInCAContext,
  image,
  imageInSublayer,
  tiledSublayer
};
constexpr int LabelRenderModeBitSize = 2;

struct LabelTextFrameRenderInfo {
  CGRect bounds;
  LabelRenderMode mode;
  STUPredefinedCGImageFormat imageFormat;
  bool shouldDrawBackgroundColor;
  bool isOpaque;
  bool mayBeClipped;
};

LabelTextFrameRenderInfo labelTextFrameRenderInfo(const STUTextFrame*,
                                                  const LabelTextFrameInfo&,
                                                  const CGPoint&,
                                                  const LabelParameters&,
                                                  bool allowExtendedRGBBitmapFormat,
                                                  bool preferImageMode,
                                                  const STUCancellationFlag* __nullable);

void drawLabelTextFrame(
       const STUTextFrame* textFrame, STUTextFrameRange range, CGPoint origin,
       __nullable CGContextRef context, ContextBaseCTM_d, PixelAlignBaselines,
       const STUTextFrameDrawingOptions* __nullable,
       __nullable STULabelDrawingBlock, const STUCancellationFlag* __nullable);

using LabelTextFrameDrawingBlock =
    void (^)(CGContext*, CGRect, const STUCancellationFlag* __nullable);

// Retains the text and its environment for drawing after the current trait scope ends.
LabelTextFrameDrawingBlock createLabelTextFrameDrawingBlock(
    const STUTextFrame*, STUTextFrameRange, CGPoint origin, ContextBaseCTM_d,
    const STUTextFrameDrawingOptions* __nullable, __nullable STULabelDrawingBlock,
    UITraitCollection*);

PurgeableImage createLabelTextFrameImage(const STUTextFrame*,
                                         const LabelTextFrameRenderInfo&,
                                         const LabelParameters&,
                                         const STUCancellationFlag* __nullable);

} // namespace stu_label


