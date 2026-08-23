// Copyright 2017–2018 Stephan Tolksdorf

#import "DisplayScaleRounding.hpp"

namespace stu_label {

STU_NO_INLINE
Optional<DisplayScale> DisplayScale::create_slowPath(CGFloat scale)
{
  const Float64 scale_f64 = scale;
  const Float32 scale_f32 = narrow_cast<Float32>(scale);
  if (STU_LIKELY(0 < scale_f32)) {
    const Float64 inverseScale_f64 = 1 / scale_f64;
    const Float32 inverseScale_f32 = isSame<CGFloat, Float32>
                                         ? 1 / scale_f32
                                         // https://twitter.com/stephentyrone/status/1016712001492434944
                                         : narrow_cast<Float32>(inverseScale_f64);
    if (STU_LIKELY(0 < inverseScale_f32 && inverseScale_f32 < infinity<Float32>)) {
      DisplayScale result;
      result.scale_f64_ = scale_f64;
      result.inverseScale_f64_ = inverseScale_f64;
      result.scale_f32_ = scale_f32;
      result.inverseScale_f32_ = inverseScale_f32;
      return result;
    }
  }
  return none;
}

} // namespace stu_label
