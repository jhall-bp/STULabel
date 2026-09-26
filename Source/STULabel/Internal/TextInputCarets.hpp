// Copyright 2026 Stephan Tolksdorf

#pragma once

#import "../STUTextFrame-Unsafe.h"

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

  TextInputLineCarets(const STUTextFrameLine &line, NSString *string) {
    const STUTextFrameParagraph &paragraph = *STUTextFrameLineGetParagraph(&line);
    std::vector<TextInputCaret> left;
    std::vector<TextInputCaret> right;
    auto *const leftCarets = &left;
    auto *const rightCarets = &right;
    const auto excised = paragraph.excisedRangeInOriginalString;
    const NSUInteger tokenStart = (NSUInteger)paragraph.rangeInTruncatedString.start
                                  + excised.start - paragraph.rangeInOriginalString.start;
    const auto append = [](std::vector<TextInputCaret> &carets, NSUInteger index, CGFloat x, bool leading) {
      carets.push_back({index, x, leading ? UITextStorageDirectionForward : UITextStorageDirectionBackward});
    };

    // Inserted hyphens can split a mixed-direction line between runs. Cache the
    // run mapping once so each original caret receives the same shift as drawing.
    struct HyphenRun {
      CFRange range;
      bool rightPart;
      bool rightToLeft;
    };
    std::vector<HyphenRun> hyphenRuns;
    if (line.hasInsertedHyphen && line._ctLine) {
      const CFArrayRef runs = CTLineGetGlyphRuns(line._ctLine);
      for (CFIndex i = 0; i < CFArrayGetCount(runs); ++i) {
        const CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runs, i);
        hyphenRuns.push_back({CTRunGetStringRange(run),
                             line._rightPartStart.runIndex >= 0 && i >= line._rightPartStart.runIndex,
                             (CTRunGetStatus(run) & kCTRunStatusRightToLeft) != 0});
      }
      std::sort(hyphenRuns.begin(), hyphenRuns.end(),
                [](const auto &a, const auto &b) { return a.range.location < b.range.location; });
    }
    const auto *const hyphenRunData = &hyphenRuns;
    if (line._ctLine) {
      CTLineEnumerateCaretOffsets(line._ctLine, ^(double x, CFIndex index, bool leading, bool *) {
        // Core Text reports the first UTF-16 unit for a leading edge and the last
        // UTF-16 unit for a trailing edge (including surrogate pairs and ligatures).
        if (index < line.rangeInOriginalString.start || index >= line.rangeInOriginalString.end)
          return;
        if (line.hasTruncationToken && index >= excised.start && index < excised.end)
          return;
        const bool prefix = index < excised.start;
        const NSInteger stringOffset = prefix
            ? line.rangeInTruncatedString.start - line.rangeInOriginalString.start
            : line.rangeInTruncatedString.end - line.rangeInOriginalString.end;
        const NSUInteger position = index + !leading + stringOffset;
        auto hyphenRun = hyphenRunData->end();
        if (line.hasInsertedHyphen) {
          hyphenRun = std::lower_bound(hyphenRunData->begin(), hyphenRunData->end(), index,
                                      [](const auto &run, CFIndex i) {
                                        return run.range.location + run.range.length <= i;
                                      });
        }
        const bool isRightPart = hyphenRun != hyphenRunData->end()
            ? hyphenRun->rightPart
            : line.hasTruncationToken && (prefix == line.isTruncatedAsRightToLeftLine);
        const CGFloat minX = isRightPart ? line.leftPartWidth + line.tokenWidth : 0;
        const CGFloat maxX = isRightPart ? line.width : line.leftPartWidth;
        CGFloat offset = std::clamp<CGFloat>(x + (isRightPart ? line._rightPartXOffset : 0), minX, maxX);
        if (hyphenRun != hyphenRunData->end()
            && position == (NSUInteger)line.rangeInTruncatedString.end && !leading)
          offset = line.leftPartWidth + (hyphenRun->rightToLeft ? 0 : line.tokenWidth);
        append(isRightPart ? *rightCarets : *leftCarets, position, offset, leading);
      });
    }
    if (line.hasInsertedHyphen && !hyphenRuns.empty()
        && [string characterAtIndex:line.rangeInTruncatedString.end - 1] == 0xAD) {
      const CGFloat x = line.leftPartWidth + (hyphenRuns.back().rightToLeft ? line.tokenWidth : 0);
      append(left, line.rangeInTruncatedString.end - 1, x, false);
      append(left, line.rangeInTruncatedString.end - 1, x, true);
    }
    visual = std::move(left);
    if (line.hasTruncationToken && line._tokenCTLine) {
      auto *const carets = &visual;
      CTLineEnumerateCaretOffsets(line._tokenCTLine, ^(double x, CFIndex index, bool leading, bool *) {
        if (index < 0 || index >= paragraph.truncationTokenLength)
          return;
        append(*carets, tokenStart + index + !leading,
               line.leftPartWidth + std::clamp<CGFloat>(x, 0, line.tokenWidth), leading);
      });
    }
    visual.insert(visual.end(), right.begin(), right.end());

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

    // Preserve Core Text's order for coincident bidi edges and zero-width characters.
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
