// Copyright 2017–2018 Stephan Tolksdorf

#import "STULabelPrerenderer.h"

namespace stu_label {
  class LabelPrerenderer;

  namespace detail { void labelPrerendererObjCObjectWasDestroyed(LabelPrerenderer&); }
}

STU_EXTERN_C_BEGIN

@interface STULabelPrerenderer () {
@public
  // This ivar is implemented by the non-ARC package target but accessed by the ARC target.
  // It must therefore remain externally visible when SwiftPM links the two object targets.
  stu_label::LabelPrerenderer* prerenderer __attribute__((visibility("default")));
}
@end

STULabelPrerenderer* STULabelPrerendererAlloc(Class prerendererClass) NS_RETURNS_RETAINED;

STU_EXTERN_C_END
