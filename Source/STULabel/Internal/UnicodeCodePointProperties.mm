// Copyright 2017–2018 Stephan Tolksdorf

#import "UnicodeCodePointProperties.hpp"

#include "DefineUIntOnCatalystToWorkAroundGlobalNamespacePollution.h"

namespace stu_label {

STU_NO_INLINE
UInt8 CodePointProperties::lookupCodePointGreaterThanD7FF(Char32 cp) noexcept
{
  if (STU_LIKELY(cp <= 0x1FFFF)) {
    cp -= 0xD800;
    const UInt i0 = cp >> 7;
    const UInt i1 = ((cp >> 3) & 15) + ((UInt)indices1[i0] << 4);
    const UInt i2 = (cp & 7) + ((UInt)indices2[i1] << 3);
    return data2[i2];
  }
  if (cp <= 0x10FFFF) {
    if (0xE0000 <= cp && cp <= 0xE0FFF) {
      return (0xE0020 <= cp && cp <= 0xE007F) || (0xE0100 <= cp && cp <= 0xE01EF) ? 0x64 : 0x34;
    }
    return static_cast<UInt8>((cp & 0xFFFF) <= 0xFFFD);
  }
  return 0;
}

// MARK: - Data tables

// Regenerate this file with `just generate-unicode-code-point-properties`.
#include "UnicodeCodePointProperties.generated.inc"

IndicConjunctBreak indicConjunctBreak(Char32 cp) noexcept
{
  if (cp < 0x20000) {
    const UInt block = indicConjunctBreakIndices[cp >> 8];
    const UInt leaf = indicConjunctBreakMiddle[(block << 4) + ((cp >> 4) & 15)];
    const UInt byte = indicConjunctBreakData[(leaf << 2) + ((cp >> 2) & 3)];
    return IndicConjunctBreak((byte >> ((cp & 3) << 1)) & 3);
  }
  return (0xE0020 <= cp && cp <= 0xE007F) || (0xE0100 <= cp && cp <= 0xE01EF)
       ? IndicConjunctBreak::extend : IndicConjunctBreak::none;
}

} // namespace stu_label
