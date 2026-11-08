// Copyright 2017–2018 Stephan Tolksdorf

#pragma once

#import "STULabel/STUTextFrame-Internal.hpp"

#import "Font.hpp"
#import "NSArrayRef.hpp"
#import "NSStringRef.hpp"
#import "Rect.hpp"
#import "ThreadLocalAllocator.hpp"


#import <malloc/malloc.h>
#import "stu/Assert.h"

namespace stu_label {

using CFLocale = RemovePointer<CFLocaleRef>;
using CFDictionary = RemovePointer<CFDictionaryRef>;
using CGFont = RemovePointer<CGFontRef>;
using CTFont = RemovePointer<CTFontRef>;
using CTLine = RemovePointer<CTLineRef>;
using CTRun = RemovePointer<CTRunRef>;


STU_INLINE
NSArrayRef<CTRun*> glyphRuns(CTLine* __nullable line) {
#ifdef __clang_analyzer__
  if (!line) return {};
#endif
  return NSArrayRef<CTRun*>{CTLineGetGlyphRuns(line)};
}

STU_INLINE
Float64 typographicWidth(CTLine* __nullable line) {
#ifdef __clang_analyzer__
  if (!line) return 0;
#endif
  return max(0, CTLineGetTypographicBounds(line, nullptr, nullptr, nullptr));
}

// Grapheme ranges use logical string order; ligature caret offsets use increasing x.
STU_INLINE
Int logicalLigatureClusterIndex(Int visualIndex, Int clusterCount, bool isRightToLeft) {
  STU_DEBUG_ASSERT(0 <= visualIndex && visualIndex < clusterCount);
  return isRightToLeft ? clusterCount - 1 - visualIndex : visualIndex;
}

class GlyphSpan;

template <typename T>
class OptionallyAllocatedArray : public ArrayBase<OptionallyAllocatedArray<T>, const T&, const T&> {
  ArrayRef<const T> array_;
  Optional<ArenaAllocator<>&> allocator_;
public:
  STU_INLINE
  OptionallyAllocatedArray() = default;

  STU_INLINE
  OptionallyAllocatedArray(ArrayRef<const T> array, Optional<ArenaAllocator<>&> allocator)
  : array_{array}, allocator_{allocator} {}

  OptionallyAllocatedArray(const OptionallyAllocatedArray&) = delete;
  OptionallyAllocatedArray& operator=(const OptionallyAllocatedArray&) = delete;

  STU_INLINE
  OptionallyAllocatedArray(OptionallyAllocatedArray&& other)
  : array_{std::exchange(other.array_, ArrayRef<const T>())},
    allocator_{std::exchange(other.allocator_, none)}
  {}

  OptionallyAllocatedArray& operator=(OptionallyAllocatedArray&& other) {
    if (this != &other) {
      if (allocator_) {
        allocator_->deallocate(array_.begin(), array_.count());
      }
      array_ = std::exchange(other.array_, ArrayRef<const T>());
      allocator_ = std::exchange(other.allocator_, none);
    }
    return *this;
  }

  STU_INLINE_T
  const T* begin() const noexcept { return array_.begin(); }

  STU_INLINE_T
  Int count() const noexcept { return array_.count(); }

  ~OptionallyAllocatedArray() {
    if (allocator_) {
      allocator_->deallocate(array_.begin(), array_.count());
    }
  }
};

using StringIndicesArray = OptionallyAllocatedArray<Int>;

/// A non-owning CTRun reference.
class GlyphRunRef {
  CTRun* run_;
public:
  explicit STU_INLINE_T
  GlyphRunRef(Uninitialized) noexcept : run_{} {}

  /* implicit */ STU_INLINE_T
  GlyphRunRef(CTRun* __nonnull run) : run_{run} {}

  STU_INLINE STU_PURE
  Int count() const { return CTRunGetGlyphCount(run_); }

  STU_INLINE
  CTRun* ctRun() const { return run_; }

  STU_INLINE STU_PURE
  CGAffineTransform textMatrix() const { return CTRunGetTextMatrix(run_); }

  STU_INLINE STU_PURE
  CTRunStatus status() const { return CTRunGetStatus(run_); }

  STU_INLINE
  bool isRightToLeft() const { return status() & kCTRunStatusRightToLeft; }

  STU_INLINE
  STUWritingDirection writingDirection() const {
    return STUWritingDirection{isRightToLeft()};
  }

  STU_INLINE
  CTFont* font() const { return getFont(run_); }

  STU_INLINE STU_PURE
  Float64 typographicWidth() const {
    return CTRunGetTypographicBounds(run_, CFRange{}, nullptr, nullptr, nullptr);
  }

  STU_INLINE STU_PURE
  Range<Int> stringRange() const {
    return CTRunGetStringRange(run_);
  }

private:
  static CTFont* getFont(CTRun*) STU_PURE;

  STU_INLINE STU_PURE
  const CGGlyph* __nullable glyhsPointer() const {
    return CTRunGetGlyphsPtr(run_);
  }

  STU_INLINE STU_PURE
  const Int* __nullable stringIndicesPointer() const {
    return CTRunGetStringIndicesPtr(run_);
  }

  friend class GlyphSpan;
  friend class OptionalValueStorage<GlyphSpan>;
  friend class OptionalValueStorage<GlyphRunRef>;
};

class LocalGlyphBoundsCache;

/// A non-owning CTRun subrange.
///
/// @note
///  The CoreText CTRun API functions accepting a CFRange argument and a pointer output
///  argument are somewhat dangerous to use in high-level code, because if you pass in a zero-length
///  range, the functions will copy all elements from the range's start index to the end of the run,
///  potentially overflowing the output buffer. This class protects against that danger.
///
/// @note
///  Even const methods of this method are currently NOT thread-safe.
class GlyphSpan {
  GlyphRunRef run_;
  Int startIndex_;
  /// -1 means run_.count() - startIndex_
  // Using std::atomic<Int> for this variable with relaxed ops seems to hinder some of LLVM's
  // optimizations.
  mutable Int countOrMinus1_;

  STU_INLINE
  GlyphSpan(GlyphRunRef run, Int startIndex, Int count)
  : run_{run}, startIndex_{startIndex}, countOrMinus1_{count}
  {}

public:
  explicit STU_INLINE_T
  GlyphSpan(Uninitialized) noexcept : run_{uninitialized} {}

  STU_INLINE_T
  GlyphSpan(const GlyphSpan& other)
  : run_{other.run_}, startIndex_{other.startIndex_}, countOrMinus1_{other.countOrMinus1_} {}

  STU_INLINE
  GlyphSpan& operator=(const GlyphSpan& other) {
    run_ = other.run_;
    startIndex_ = other.startIndex_;
    countOrMinus1_ = other.countOrMinus1_;
    return *this;
  }

  /* implicit */ STU_INLINE
  GlyphSpan(CTRun* __nonnull run)
  : GlyphSpan{GlyphRunRef{run}}
  {}

  /* implicit */ STU_INLINE
  GlyphSpan(GlyphRunRef run)
  : run_{run}, startIndex_{0}, countOrMinus1_{-1} {}

  STU_INLINE
  GlyphSpan(GlyphRunRef run, IndexRange<Int, Dollar> range)
  : run_{run}, startIndex_{range.startIndex}, countOrMinus1_{-1} {}

  STU_INLINE
  GlyphSpan(GlyphRunRef run, Range<Int> glyphIndexRange)
  : GlyphSpan(run, glyphIndexRange.start, max(0, glyphIndexRange.count()))
  {
    STU_ASSERT(Range(0, run_.count()).contains(glyphIndexRange));
  }

  STU_INLINE
  GlyphSpan(GlyphRunRef run, Range<Int> glyphIndexRange, Unchecked)
  : GlyphSpan(run, glyphIndexRange.start, max(0, glyphIndexRange.count()))
  {
    STU_DEBUG_ASSERT(Range(0, run_.count()).contains(glyphIndexRange));
  }

  STU_INLINE
  CTFont* font() const { return run_.font(); }

  STU_INLINE
  bool isRightToLeft() const { return run_.isRightToLeft(); }

  STU_INLINE_T
  GlyphRunRef run() const { return run_; }

  STU_INLINE
  Optional<CFRange> ctRunGlyphRange() const {
    const Int n = countOrMinus1_;
    return STU_UNLIKELY(n == 0) ? none
         : Optional<CFRange>(CFRange{startIndex_, max(n, 0)});
  }

  STU_INLINE
  void assumeFullRunGlyphCountIs(Int runGlyphCount) const {
    if (countOrMinus1_ < 0) {
      const Int count = runGlyphCount - startIndex_;
      STU_ASSERT(count >= 0);
      STU_ASSUME(count >= 0);
      countOrMinus1_ = count;
    }
  }

  STU_INLINE
  void ensureCountIsCached() const {
    if (countOrMinus1_ < 0) {
      assumeFullRunGlyphCountIs(run_.count());
    }
  }

  STU_INLINE
  bool isEmpty() const {
    return count() == 0;
  }

  STU_INLINE
  Int count() const {
    ensureCountIsCached();
    const Int n = countOrMinus1_;
    STU_ASSUME(n >= 0);
    return n;
  }

  STU_INLINE
  Range<Int> glyphRange() const {
    ensureCountIsCached();
    return {startIndex_, Count{countOrMinus1_}};
  }

  // Negative advances can make a run's typographic width exceed their sum, particularly for RTL.
  // Ask Core Text for the bounds instead of summing glyph advances.
  STU_INLINE
  Float64 typographicWidth() const {
    if (const Optional<CFRange> range = ctRunGlyphRange()) {
      return CTRunGetTypographicBounds(run_.ctRun(), *range, nullptr, nullptr, nullptr);
    }
    return 0;
  }

  STU_INLINE
  Rect<CGFloat> imageBounds(LocalGlyphBoundsCache& glyphBoundsCache) const {
    const Int count = this->count();
    if (count > 0) {
      return imageBoundsImpl(run_, CFRange{startIndex_, count}, glyphBoundsCache);
    }
    return {};
  }

  STU_INLINE
  void draw(CGContextRef cgContext) const {
    if (const Optional<CFRange> range = ctRunGlyphRange()) {
      return CTRunDraw(run_.ctRun(), cgContext, *range);
    }
  }

  class GlyphsRef;
  STU_INLINE GlyphsRef glyphs() const { return {*this}; }

  STU_INLINE
  CGGlyph operator[](Int index) const {
    STU_ASSERT(0 <= index && index < count());
    CGGlyph glyph;
    CTRunGetGlyphs(run_.ctRun(), CFRange{startIndex_ + index, 1}, &glyph);
    return glyph;
  }
  STU_INLINE
  CGGlyph operator[](OffsetFromEnd<Int> offset) const {
    return operator[](count() + offset.value);
  }

  STU_INLINE
  GlyphSpan operator[](Range<Int> glyphIndexRange) const {
    STU_ASSERT(Range(0, count()).contains(glyphIndexRange));
    return {run(), startIndex_ + glyphIndexRange.start, max(glyphIndexRange.count(), 0)};
  }

  STU_INLINE
  void copyGlyphs(Range<Int> glyphIndexRange, ArrayRef<CGGlyph> out) const {
    STU_ASSERT(glyphIndexRange.count() == out.count());
    STU_ASSERT(Range(0, count()).contains(glyphIndexRange));
    if (glyphIndexRange.isEmpty()) return;
    CTRunGetGlyphs(run_.ctRun(), startIndex_ + glyphIndexRange, out.begin());
  }

  /// Positions are in line coordinates, with the run matrix applied. CTFont drawing and glyph
  /// bounds APIs apply the font matrix to glyph outlines themselves.
  STU_INLINE
  GlyphsWithPositions getGlyphsWithPositions() const {
    ensureCountIsCached();
    if (const Optional<CFRange> glyphRange = ctRunGlyphRange()) {
      return getGlyphsWithPositionsImpl(run_, *glyphRange);
    }
    return GlyphsWithPositions{};
  }

  STU_INLINE
  bool copyInnerCaretOffsetsForLigatureGlyphAtIndex(Int index, ArrayRef<CGFloat> outOffsets) const {
    STU_PRECONDITION(0 <= index && index < count());
    STU_PRECONDITION(!outOffsets.isEmpty());
    return copyInnerCaretOffsetsForLigatureGlyphAtIndexImpl(run_, startIndex_ + index, outOffsets);
  }

  class StringIndicesRef;
  STU_INLINE StringIndicesRef stringIndices() const { return {*this}; }

  STU_INLINE
  Int stringIndexForGlyphAtIndex(Int index) const {
    STU_PRECONDITION(0 <= index && index < count());
    Int stringIndex;
    CTRunGetStringIndices(run_.ctRun(), CFRange{.location = startIndex_ + index, .length = 1},
                          &stringIndex);
    return stringIndex;
  }
  STU_INLINE
  Int stringIndexForGlyphAtIndex(OffsetFromEnd<Int> offset) const {
    return stringIndexForGlyphAtIndex(count() + offset.value);
  }

  STU_INLINE
  Range<Int> stringRange() const {
    STU_PRECONDITION(!isEmpty());
    return stringRangeImpl(run_, glyphRange());
  }

  STU_INLINE
  void copyStringIndices(Range<Int> glyphIndexRange, ArrayRef<Int> out) const {
    STU_PRECONDITION(glyphIndexRange.count() == out.count());
    STU_PRECONDITION(Range(0, count()).contains(glyphIndexRange));
    if (glyphIndexRange.isEmpty()) return;
    CTRunGetStringIndices(run_.ctRun(), startIndex_ + glyphIndexRange, out.begin());
  }

  STU_INLINE
  StringIndicesArray stringIndicesArray() const {
    const Int count = this->count();
    if (STU_UNLIKELY(count == 0)) {
      return StringIndicesArray{{}, none};
    }
    if (const Int* const p = run_.stringIndicesPointer()) {
      return {{p + startIndex_, count}, none};
    }
    return stringIndicesArray_slowPath(run_, Range{startIndex_, Count{count}});
  }

  STU_INLINE
  StringIndicesArray copiedStringIndicesArray() const {
    return stringIndicesArray_slowPath(run_, Range{startIndex_, Count{count()}});
  }

  class GlyphsRef {
    const CGGlyph* array_;
    Int count_;
    Int startIndex_;
    CTRun* run_;
  public:
    /* implicit */ STU_INLINE
    GlyphsRef(const GlyphSpan& span)
    : array_{span.run_.glyhsPointer()}, count_{span.count()}, startIndex_{span.startIndex_},
      run_{span.run_.ctRun()}
    {}

    STU_INLINE
    CGGlyph operator[](Int index) const {
      STU_ASSERT(0 <= index && index < count_);
      if (array_) {
        return array_[startIndex_ + index];
      }
      CGGlyph glyph;
      CTRunGetGlyphs(run_, CFRange{startIndex_ + index, 1}, &glyph);
      return glyph;
    }
  };

  class StringIndicesRef {
    const Int* array_;
    Int count_;
    Int startIndex_;
    CTRun* run_;
  public:
    /* implicit */ STU_INLINE
    StringIndicesRef(const GlyphSpan& span)
    : array_{span.run_.stringIndicesPointer()}, count_{span.count()},
      startIndex_{span.startIndex_}, run_{span.run_.ctRun()}
    {}

    STU_INLINE
    Int operator[](Int index) const {
      STU_ASSERT(0 <= index && index < count_);
      if (array_) {
        return array_[startIndex_ + index];
      }
      Int stringIndex;
      CTRunGetStringIndices(run_, CFRange{startIndex_ + index, 1}, &stringIndex);
      return stringIndex;
    }

    bool hasArray() const { return array_ != nullptr; }

    ArrayRef<const Int> array() const {
      STU_PRECONDITION(array_);
      return {array_, count_, unchecked};
    }

    void assignArray(ArrayRef<const Int> indices) {
      STU_PRECONDITION(count_ == indices.count());
      array_ = indices.begin();
    }
  };

private:
  static GlyphsWithPositions getGlyphsWithPositionsImpl(GlyphRunRef, CFRange);
  static Rect<CGFloat> imageBoundsImpl(GlyphRunRef, CFRange, LocalGlyphBoundsCache&);
  static StringIndicesArray stringIndicesArray_slowPath(GlyphRunRef, CFRange);
  static Range<Int> stringRangeImpl(GlyphRunRef, Range<Int> glyphRange);
  static bool copyInnerCaretOffsetsForLigatureGlyphAtIndexImpl(GlyphRunRef, Int index,
                                                               ArrayRef<CGFloat> outOffsets);

  friend class OptionalValueStorage<GlyphSpan>;
};


struct RunGlyphIndex {
  Int runIndex;
  Int glyphIndex;

  /* implicit */ STU_CONSTEXPR
  operator STURunGlyphIndex() const {
    return {.runIndex = narrow_cast<Int32>(runIndex),
            .glyphIndex = narrow_cast<Int32>(glyphIndex)};
  }

  bool operator==(RunGlyphIndex other) const {
    return runIndex == other.runIndex
        && glyphIndex == other.glyphIndex;
  }
  bool operator!=(RunGlyphIndex other) const {
    return !(*this == other);
  }
};

} // namespace stu_label

template <>
class stu::OptionalValueStorage<stu_label::GlyphRunRef> {
public:
  stu_label::GlyphRunRef value_{uninitialized};

  STU_INLINE bool hasValue() const noexcept { return value_.run_ != nullptr; }
  STU_INLINE void clearValue() noexcept { value_.run_ = nullptr; }
  STU_INLINE void constructValue(stu_label::GlyphRunRef run) { value_ = run; }
};

template <>
class stu::OptionalValueStorage<stu_label::GlyphSpan> {
public:
  stu_label::GlyphSpan value_{uninitialized};

  STU_INLINE bool hasValue() const noexcept { return value_.run_.run_ != nullptr; }

  STU_INLINE void clearValue() noexcept { value_.run_.run_ = nullptr; }

  template <typename... Args>
  STU_INLINE void constructValue(Args&&... args) {
    static_assert(sizeof...(Args) > 0);
    new (&value_) stu_label::GlyphSpan(std::forward<Args>(args)...);
  }
};

