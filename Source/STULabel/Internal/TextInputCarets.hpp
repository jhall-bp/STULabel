// Copyright 2026 Stephan Tolksdorf

#pragma once

#import "TextFrame.hpp"
#import "NSStringRef.hpp"

#import <UIKit/UITextInput.h>

#include <algorithm>
#include <map>
#include <memory>
#include <vector>

namespace stu_label {

// One visual stop may represent both affinities at an ordinary character boundary.
// At bidi boundaries the distinct logical positions remain separate, even at equal x.
struct TextInputCaret {
  NSUInteger index;
  CGFloat x;
  UITextStorageDirection affinity;
  bool hasBothAffinities = false;

  UITextStorageDirection affinityForMovement(bool right) const {
    return !right && hasBothAffinities
               ? (affinity == UITextStorageDirectionForward ? UITextStorageDirectionBackward : UITextStorageDirectionForward)
               : affinity;
  }
};

class TextInputLineCarets {
  struct LogicalPosition {
    NSUInteger key;
    size_t visualIndex;
  };
  std::vector<LogicalPosition> logicalPositions_;

public:
  std::vector<TextInputCaret> visual;

  TextInputLineCarets(const TextFrameLine &line, NSString *string) {
    ThreadLocalArenaAllocator::InitialBuffer<2048> buffer;
    ThreadLocalArenaAllocator allocator{Ref{buffer}};
    const auto append = [](std::vector<TextInputCaret> &carets, NSUInteger index, CGFloat x, bool leading) {
      carets.push_back({index, x, leading ? UITextStorageDirectionForward : UITextStorageDirectionBackward});
    };
    struct Cluster {
      Range<Float64> x;
      bool leftToRight;
    };
    // A grapheme can span multiple glyphs or runs. Collect its outer bounds before
    // emitting its two edges, using only the spans that the renderer actually draws.
    std::map<std::pair<Int, Int>, Cluster> clusters;
    const auto addCluster = [&](Range<Int> range, Range<Float64> x, bool leftToRight) {
      if (range.isEmpty())
        return;
      auto [it, inserted] = clusters.try_emplace(std::pair{range.start, range.end}, Cluster{x, leftToRight});
      if (!inserted)
        it->second.x = it->second.x.convexHull(x);
    };
    line.forEachStyledGlyphSpan(none, [&](const StyledGlyphSpan &span, const TextStyle &, Range<Float64> spanX) {
      if (span.part == TextLinePart::insertedHyphen) {
        const NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:line.rangeInTruncatedString.end - 1];
        addCluster(Range<Int>{range}, spanX, line.paragraphBaseWritingDirection == STUWritingDirectionLeftToRight);
        return;
      }
      const GlyphSpan glyphs = span.glyphSpan;
      if (glyphs.isEmpty())
        return;
      const bool leftToRight = !glyphs.run().isRightToLeft();
      const auto indices = glyphs.stringIndicesArray();
      // Sorting just the visible indices also handles non-monotonic runs without
      // repeatedly scanning the full (potentially mostly truncated) Core Text run.
      std::vector<Int> boundaries(indices.begin(), indices.end());
      boundaries.push_back(span.stringRange.end);
      std::sort(boundaries.begin(), boundaries.end());
      const NSStringRef source{span.attributedString.string};
      // A grapheme may cross a run boundary. Clip only to the visible line part.
      Range<Int> visibleRange{0, source.count()};
      if (span.part == TextLinePart::originalString) {
        visibleRange = Range<Int>{line.rangeInOriginalString};
        const Range<Int> excised{span.paragraph->excisedRangeInOriginalString()};
        if (span.stringRange.start < excised.start)
          visibleRange.end = min(visibleRange.end, excised.start);
        else
          visibleRange.start = max(visibleRange.start, excised.end);
      }
      Float64 x = spanX.start;
      for (Int i = 0; i < glyphs.count(); ++i) {
        const Float64 nextX = i + 1 == glyphs.count() ? spanX.end
            : min(x + glyphs[{i, Count{1}}].typographicWidth(), spanX.end);
        const auto end = std::upper_bound(boundaries.begin(), boundaries.end(), indices[i]);
        if (end == boundaries.end()) {
          x = nextX;
          continue;
        }
        const Range<Int> glyphRange{indices[i], *end};
        Array<Range<Int>, Fixed, 16> ranges;
        const Int count = source.copyRangesOfGraphemeClustersSkippingTrailingIgnorables(glyphRange, ranges);
        Array<CGFloat, Fixed, 15> offsets;
        const bool split = count > 1 && count <= ranges.count()
            && glyphRange.contains(ranges[0]) && glyphRange.contains(ranges[count - 1])
            && glyphs.copyInnerCaretOffsetsForLigatureGlyphAtIndex(i, offsets[{0, count - 1}]);
        const auto add = [&](Range<Int> range, Range<Float64> bounds) {
          StyledGlyphSpan part = span;
          part.stringRange = Range<Int32>{range.intersection(visibleRange)};
          addCluster(Range<Int>{part.rangeInTruncatedString()}, bounds, leftToRight);
        };
        if (count <= ranges.count()) {
          Float64 startX = x;
          for (Int j = 0; j < count; ++j) {
            const Float64 endX = split && j + 1 < count ? min(x + offsets[j], nextX) : nextX;
            add(ranges[j], {startX, endX});
            if (split)
              startX = endX;
          }
        } else {
          add(glyphRange, {x, nextX});
        }
        x = nextX;
      }
    });
    for (const auto &[range, cluster] : clusters) {
      append(visual, cluster.leftToRight ? range.first : range.second, cluster.x.start, cluster.leftToRight);
      append(visual, cluster.leftToRight ? range.second : range.first, cluster.x.end, !cluster.leftToRight);
    }

    // STULabel does not draw trailing whitespace. Its insertion positions belong
    // at the logical end of the line, rather than having no caret rectangle.
    const bool leftToRight = line.paragraphBaseWritingDirection == STUWritingDirectionLeftToRight;
    const CGFloat trailingX = leftToRight ? line.width : 0;
    std::vector<TextInputCaret> trailing;
    const NSUInteger end = line.rangeInTruncatedString.end + line.trailingWhitespaceInTruncatedStringLength;
    for (NSUInteger index = line.rangeInTruncatedString.end; index < end;) {
      const NSUInteger next = MIN(NSMaxRange([string rangeOfComposedCharacterSequenceAtIndex:index]), end);
      append(trailing, index, trailingX, true);
      append(trailing, next, trailingX, false);
      index = next;
    }
    if (leftToRight) {
      visual.insert(visual.end(), trailing.begin(), trailing.end());
    } else {
      std::reverse(trailing.begin(), trailing.end());
      visual.insert(visual.begin(), trailing.begin(), trailing.end());
    }
    if (visual.empty())
      visual.push_back({(NSUInteger)line.rangeInTruncatedString.start, trailingX, UITextStorageDirectionForward});

    // Keep the adjoining edges in visual order at bidi boundaries and zero-width characters.
    std::stable_sort(visual.begin(), visual.end(), [](const auto &a, const auto &b) { return a.x < b.x; });
    size_t count = 0;
    for (const auto caret : visual) {
      if (count && visual[count - 1].index == caret.index && visual[count - 1].x == caret.x) {
        visual[count - 1].hasBothAffinities |= visual[count - 1].affinity != caret.affinity;
      } else {
        visual[count++] = caret;
      }
    }
    visual.resize(count);
    logicalPositions_.reserve(2 * count);
    for (size_t i = 0; i < count; ++i) {
      const auto &caret = visual[i];
      logicalPositions_.push_back({2 * caret.index + (caret.affinity == UITextStorageDirectionBackward), i});
      if (caret.hasBothAffinities)
        logicalPositions_.push_back({2 * caret.index + (caret.affinity != UITextStorageDirectionBackward), i});
    }
    std::sort(logicalPositions_.begin(), logicalPositions_.end(),
              [](const auto &a, const auto &b) { return a.key < b.key; });
  }

  size_t visualIndex(NSUInteger index, UITextStorageDirection affinity) const {
    const NSUInteger key = 2 * index + (affinity == UITextStorageDirectionBackward);
    auto it = std::lower_bound(logicalPositions_.begin(), logicalPositions_.end(), key,
                              [](const auto &position, NSUInteger value) { return position.key < value; });
    if (it != logicalPositions_.end() && it->key / 2 == index)
      return it->visualIndex;
    if (it != logicalPositions_.begin() && (it - 1)->key / 2 == index)
      return (it - 1)->visualIndex;
    // UITextInput also permits UTF-16 offsets inside a composed character.
    if (affinity == UITextStorageDirectionForward && it != logicalPositions_.begin())
      --it;
    else if (it == logicalPositions_.end())
      --it;
    return it->visualIndex;
  }
};

// The cache is owned by the immutable document generation and shared by its
// selection-only copies. It is populated only by UITextInput queries on the main thread.
using TextInputCaretCache = std::map<int32_t, TextInputLineCarets>;

} // namespace stu_label
