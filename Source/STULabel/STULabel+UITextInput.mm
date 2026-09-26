// Copyright 2026 Stephan Tolksdorf

#import "STULabel+UITextInput-Internal.h"

#import "STULabelLayer.h"
#import "STUTextFrame.h"
#import "STUTextFrame-Unsafe.h"
#import "STUTextFrame-Internal.hpp"
#import "Internal/TextInputCarets.hpp"
#import "Internal/TextLineSpansPath.hpp"

@interface STULabelTextInputPosition : UITextPosition <NSCopying> {
@private
  NSUInteger _index;
  UITextStorageDirection _affinity;
}
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) UITextStorageDirection affinity;
- (instancetype)initWithIndex:(NSUInteger)index affinity:(UITextStorageDirection)affinity;
@end

@implementation STULabelTextInputPosition
- (instancetype)initWithIndex:(NSUInteger)index affinity:(UITextStorageDirection)affinity
{
  if ((self = [super init])) {
    _index = index;
    _affinity = affinity;
  }
  return self;
}
- (NSUInteger)index
{
  return _index;
}
- (UITextStorageDirection)affinity
{
  return _affinity;
}
- (id)copyWithZone:(NSZone *__unused)zone
{
  return self;
}
- (BOOL)isEqual:(id)object
{
  return [object isKindOfClass:STULabelTextInputPosition.class] &&
         _index == ((STULabelTextInputPosition *)object)->_index &&
         _affinity == ((STULabelTextInputPosition *)object)->_affinity;
}
- (NSUInteger)hash
{
  return _index ^ ((NSUInteger)_affinity << 1);
}
@end

@interface STULabelTextInputRange : UITextRange <NSCopying> {
@private
  STULabelTextInputPosition *_startPosition;
  STULabelTextInputPosition *_endPosition;
}
@property (nonatomic, readonly) STULabelTextInputPosition *startPosition;
@property (nonatomic, readonly) STULabelTextInputPosition *endPosition;
- (instancetype)initWithStart:(STULabelTextInputPosition *)start end:(STULabelTextInputPosition *)end;
@end

@implementation STULabelTextInputRange
- (instancetype)initWithStart:(STULabelTextInputPosition *)start end:(STULabelTextInputPosition *)end
{
  if ((self = [super init])) {
    _startPosition = [start copy];
    _endPosition = [end copy];
  }
  return self;
}
- (UITextPosition *)start
{
  return _startPosition;
}
- (UITextPosition *)end
{
  return _endPosition;
}
- (BOOL)isEmpty
{
  return _startPosition.index == _endPosition.index;
}
- (id)copyWithZone:(NSZone *__unused)zone
{
  return self;
}
- (STULabelTextInputPosition *)startPosition
{
  return _startPosition;
}
- (STULabelTextInputPosition *)endPosition
{
  return _endPosition;
}
- (BOOL)isEqual:(id)object
{
  return [object isKindOfClass:STULabelTextInputRange.class] &&
         [_startPosition isEqual:((STULabelTextInputRange *)object)->_startPosition] &&
         [_endPosition isEqual:((STULabelTextInputRange *)object)->_endPosition];
}
- (NSUInteger)hash
{
  return _startPosition.hash ^ (_endPosition.hash * 0x9e3779b9u);
}
@end

@interface STULabelTextInputDocument : NSObject {
@public
  std::shared_ptr<stu_label::TextInputCaretCache> _carets;
}

@property (nonatomic, strong, readonly) STUTextFrame *textFrame;
@property (nonatomic, copy, readonly) NSString *string;
@property (nonatomic, readonly) CGPoint frameOrigin;
@property (nonatomic, readonly) CGFloat displayScale;
@property (nonatomic, strong, readonly) STUTextLinkArray *links;
@property (nonatomic, strong, readonly, nullable) STULabelTextInputRange *selectedTextRange;

- (instancetype)initWithTextFrame:(STUTextFrame *)textFrame
                           string:(NSString *)string
                      frameOrigin:(CGPoint)frameOrigin
                     displayScale:(CGFloat)displayScale
                            links:(STUTextLinkArray *)links
                selectedTextRange:(nullable STULabelTextInputRange *)selectedTextRange;

- (STULabelTextInputDocument *)documentWithSelectedTextRange:(nullable STULabelTextInputRange *)selectedTextRange;

@end

@implementation STULabelTextInputDocument

- (instancetype)initWithTextFrame:(STUTextFrame *)textFrame
                           string:(NSString *)string
                      frameOrigin:(CGPoint)frameOrigin
                     displayScale:(CGFloat)displayScale
                            links:(STUTextLinkArray *)links
                selectedTextRange:(STULabelTextInputRange *)selectedTextRange
{
  if ((self = [super init])) {
    _textFrame = textFrame;
    _string = [string copy];
    _frameOrigin = frameOrigin;
    _displayScale = displayScale;
    _links = links;
    _selectedTextRange = selectedTextRange;
  }
  return self;
}

- (STULabelTextInputDocument *)documentWithSelectedTextRange:(STULabelTextInputRange *)selectedTextRange
{
  STULabelTextInputDocument *const document = [[STULabelTextInputDocument alloc] initWithTextFrame:_textFrame
                                                                                          string:_string
                                                                                     frameOrigin:_frameOrigin
                                                                                    displayScale:_displayScale
                                                                                           links:_links
                                                                               selectedTextRange:selectedTextRange];
  document->_carets = _carets;
  return document;
}

@end

@interface STULabelTextSelectionRect : UITextSelectionRect <NSCopying> {
@private
  CGRect _rect;
  NSWritingDirection _writingDirection;
  BOOL _containsStart;
  BOOL _containsEnd;
}
- (instancetype)initWithRect:(CGRect)rect
            writingDirection:(NSWritingDirection)writingDirection
               containsStart:(BOOL)containsStart
                 containsEnd:(BOOL)containsEnd;
@end

@implementation STULabelTextSelectionRect
- (instancetype)initWithRect:(CGRect)rect
            writingDirection:(NSWritingDirection)writingDirection
               containsStart:(BOOL)containsStart
                 containsEnd:(BOOL)containsEnd
{
  if ((self = [super init])) {
    _rect = rect;
    _writingDirection = writingDirection;
    _containsStart = containsStart;
    _containsEnd = containsEnd;
  }
  return self;
}
- (CGRect)rect
{
  return _rect;
}
- (NSWritingDirection)writingDirection
{
  return _writingDirection;
}
- (BOOL)containsStart
{
  return _containsStart;
}
- (BOOL)containsEnd
{
  return _containsEnd;
}
- (BOOL)isVertical
{
  return NO;
}
- (CGAffineTransform)transform
{
  return CGAffineTransformIdentity;
}
- (id)copyWithZone:(NSZone *__unused)zone
{
  return self;
}
- (BOOL)isEqual:(id)object
{
  return [object isKindOfClass:STULabelTextSelectionRect.class] &&
         CGRectEqualToRect(_rect, ((STULabelTextSelectionRect *)object)->_rect) &&
         _writingDirection == ((STULabelTextSelectionRect *)object)->_writingDirection &&
         _containsStart == ((STULabelTextSelectionRect *)object)->_containsStart &&
         _containsEnd == ((STULabelTextSelectionRect *)object)->_containsEnd;
}
- (NSUInteger)hash
{
  NSUInteger hash = [NSValue valueWithCGRect:_rect].hash;
  hash ^= (NSUInteger)_writingDirection << 2;
  hash ^= (NSUInteger)_containsStart << 1;
  return hash ^ (NSUInteger)_containsEnd;
}
@end

static STU_INLINE STULabelTextInputPosition *textPosition(NSUInteger index)
{
  return [[STULabelTextInputPosition alloc] initWithIndex:index affinity:UITextStorageDirectionForward];
}

static STU_INLINE STULabelTextInputPosition *textPosition(NSUInteger index, UITextStorageDirection affinity)
{
  return [[STULabelTextInputPosition alloc] initWithIndex:index affinity:affinity];
}

static STULabelTextInputPosition *validTextPosition(UITextPosition *position, NSString *string)
{
  if (![position isKindOfClass:STULabelTextInputPosition.class])
    return nil;
  STULabelTextInputPosition *const p = (STULabelTextInputPosition *)position;
  if (p.index > string.length)
    return nil;
  return p;
}

static STULabelTextInputRange *validTextRange(UITextRange *range, NSString *string)
{
  if (![range isKindOfClass:STULabelTextInputRange.class])
    return nil;
  STULabelTextInputRange *const r = (STULabelTextInputRange *)range;
  STULabelTextInputPosition *const start = validTextPosition(r.startPosition, string);
  STULabelTextInputPosition *const end = validTextPosition(r.endPosition, string);
  if (!start || !end || start.index > end.index)
    return nil;
  return r;
}

static STU_INLINE STULabelTextInteraction *textInteraction(STULabel *self) { return [self stu_textInteraction]; }

static void updateVisibleDocument(STULabel *self, STULabelTextInteraction *interaction)
{
  if (interaction.stu_isPublishingDocument)
    return;

  STUTextFrame *const textFrame = self.textFrame;
  const CGPoint frameOrigin = self.textFrameOrigin;
  const CGFloat displayScale = self.layer.contentsScale;
  STULabelTextInputDocument *const oldDocument = interaction.stu_document;
  if (oldDocument && oldDocument.textFrame == textFrame && CGPointEqualToPoint(oldDocument.frameOrigin, frameOrigin) &&
      oldDocument.displayScale == displayScale) {
    return;
  }

  NSString *const string = textFrame.truncatedAttributedString.string;
  const bool textDidChange = oldDocument && ![oldDocument.string isEqualToString:string];
  STULabelTextInputRange *const selection = textDidChange ? nil : oldDocument.selectedTextRange;
  STULabelTextInputDocument *const newDocument = [[STULabelTextInputDocument alloc] initWithTextFrame:textFrame
                                                                                               string:string
                                                                                          frameOrigin:frameOrigin
                                                                                         displayScale:displayScale
                                                                                                links:self.links
                                                                                    selectedTextRange:selection];
  if (oldDocument && oldDocument.textFrame == textFrame)
    newDocument->_carets = oldDocument->_carets;
  if (!oldDocument || !textDidChange) {
    interaction.stu_document = newDocument;
    return;
  }

  interaction.stu_isPublishingDocument = true;
  const bool hadSelection = oldDocument.selectedTextRange != nil;
  id<UITextInputDelegate> const inputDelegate = interaction.stu_inputDelegate;
  [inputDelegate textWillChange:self];
  if (hadSelection)
    [inputDelegate selectionWillChange:self];
  interaction.stu_document = newDocument;
  [inputDelegate textDidChange:self];
  if (hadSelection)
    [inputDelegate selectionDidChange:self];
  interaction.stu_isPublishingDocument = false;
}

static STU_INLINE STULabelTextInputDocument *textInputDocument(STULabel *self)
{
  STULabelTextInteraction *const interaction = textInteraction(self);
  updateVisibleDocument(self, interaction);
  return interaction.stu_document;
}

static NSRange truncationTokenLinkRange(STULabelTextInputDocument *document)
{
  STUTextFrame *const textFrame = document.textFrame;
  const NSRange tokenRange = STUTextFrameRangeGetRangeInTruncatedString(textFrame.rangeOfLastTruncationToken);
  if (tokenRange.length == 0)
    return NSMakeRange(NSNotFound, 0);
  for (STUTextLink *const link in document.links) {
    const NSRange tokenLinkRange = NSIntersectionRange(tokenRange, link.rangeInTruncatedString);
    if (tokenLinkRange.length != 0)
      return tokenLinkRange;
  }
  return NSMakeRange(NSNotFound, 0);
}

static NSRange selectionRangeExcludingTruncationTokenLink(STULabelTextInputDocument *document, NSRange range)
{
  const NSRange linkRange = truncationTokenLinkRange(document);
  if (linkRange.location == NSNotFound || NSIntersectionRange(range, linkRange).length == 0) {
    return range;
  }
  if (range.location < linkRange.location) {
    return NSMakeRange(range.location, linkRange.location - range.location);
  }
  const NSUInteger linkEnd = NSMaxRange(linkRange);
  const NSUInteger rangeEnd = NSMaxRange(range);
  if (rangeEnd > linkEnd)
    return NSMakeRange(linkEnd, rangeEnd - linkEnd);
  return NSMakeRange(NSNotFound, 0);
}

static STUTextRectArray *rectsForRange(STULabelTextInputDocument *document, NSRange range)
{
  if (range.length == 0)
    return STUTextRectArray.emptyArray;
  STUTextFrame *const textFrame = document.textFrame;
  return [textFrame rectsForRange:[textFrame rangeForRangeInTruncatedString:range]
                      frameOrigin:document.frameOrigin
                     displayScale:document.displayScale];
}

static NSUInteger selectionRectIndexContainingEndpoint(STULabelTextInputDocument *document,
                                                       STUTextRectArray *selectionRects,
                                                       NSString *string,
                                                       NSRange selectionRange,
                                                       bool start)
{
  if (selectionRange.length == 0)
    return NSNotFound;
  const NSUInteger characterIndex = start ? selectionRange.location : NSMaxRange(selectionRange) - 1;
  const NSRange characterRange =
      NSIntersectionRange(selectionRange, [string rangeOfComposedCharacterSequenceAtIndex:characterIndex]);
  STUTextRectArray *const characterRects = rectsForRange(document, characterRange);
  for (size_t j = 0; j < characterRects.rectCount; ++j) {
    const size_t lineIndex = [characterRects textLineIndexForRectAtIndex:j];
    const CGRect characterRect = [characterRects rectAtIndex:j];
    const CGPoint midpoint = CGPointMake(CGRectGetMidX(characterRect), CGRectGetMidY(characterRect));
    for (size_t i = 0; i < selectionRects.rectCount; ++i) {
      if ([selectionRects textLineIndexForRectAtIndex:i] != lineIndex)
        continue;
      const CGRect rect = CGRectInset([selectionRects rectAtIndex:i], -1, -1);
      if (CGRectContainsPoint(rect, midpoint))
        return i;
    }
  }
  return NSNotFound;
}

static STUTextFrameGraphemeClusterRange clusterClosestToPoint(STULabelTextInputDocument *document, CGPoint point)
{
  return [document.textFrame rangeOfGraphemeClusterClosestToPoint:point
                                       ignoringTrailingWhitespace:true
                                                      frameOrigin:document.frameOrigin
                                                     displayScale:document.displayScale];
}

static NSWritingDirection writingDirectionAtPoint(STULabelTextInputDocument *document, CGPoint point)
{
  return (NSWritingDirection)clusterClosestToPoint(document, point).writingDirection;
}

static const STUTextFrameLine *lineForPosition(STULabelTextInputDocument *document,
                                               STULabelTextInputPosition *position)
{
  STUTextFrame *const textFrame = document.textFrame;
  const STUTextFrameData *const data = __STUTextFrameGetData(textFrame);
  if (data->lineCount == 0)
    return nullptr;
  // A backward-affinity position at a soft wrap belongs to the preceding visual line.
  const NSUInteger index = position.index - (position.affinity == UITextStorageDirectionBackward && position.index > 0);
  const STUTextFrameRange range = [textFrame rangeForRangeInTruncatedString:NSMakeRange(index, 0)];
  return STUTextFrameDataGetLines(data) + MIN((int32_t)range.start.lineIndex, data->lineCount - 1);
}

static const stu_label::TextInputLineCarets &lineCarets(STULabelTextInputDocument *document,
                                                       const STUTextFrameLine *line)
{
  if (!document->_carets)
    document->_carets = std::make_shared<stu_label::TextInputCaretCache>();
  return document->_carets->try_emplace(line->lineIndex, *line, document.string).first->second;
}

static CGRect lineBounds(STULabelTextInputDocument *document, const STUTextFrameLine *line)
{
  using namespace stu_label;
  const TextFrame &frame = textFrameRef(document.textFrame);
  const TextFrameScaleAndDisplayScale scales{frame, document.displayScale};
  TextLineVerticalPosition vertical = textLineVerticalPosition(
      frame.lines()[line->lineIndex], scales.displayScale, VerticalEdgeInsets{},
      VerticalOffsets{.textFrameOriginY = document.frameOrigin.y / scales.textFrameScale});
  vertical.scale(scales.textFrameScale);
  return CGRectMake(document.frameOrigin.x + line->originX * scales.textFrameScale,
                    vertical.y().start, line->width * scales.textFrameScale, vertical.y().end - vertical.y().start);
}

static CGRect caretRect(STULabelTextInputDocument *document, STULabelTextInputPosition *position)
{
  const STUTextFrameLine *const line = lineForPosition(document, position);
  if (!line)
    return CGRectZero;
  const auto &carets = lineCarets(document, line);
  const auto &caret = carets.visual[carets.visualIndex(position.index, position.affinity)];
  const CGRect bounds = lineBounds(document, line);
  const CGFloat textScale = __STUTextFrameGetData(document.textFrame)->textScaleFactor;
  const CGFloat width = 1 / (document.displayScale > 0 ? document.displayScale : 1);
  return CGRectMake(bounds.origin.x + caret.x * textScale - width / 2,
                    bounds.origin.y, width, bounds.size.height);
}

// Hit testing first chooses an insertion line, including lines without glyphs.
static const STUTextFrameLine *lineClosestToY(STULabelTextInputDocument *document, CGFloat y)
{
  using namespace stu_label;
  const TextFrame &frame = textFrameRef(document.textFrame);
  if (frame.lineCount == 0)
    return nullptr;
  const CGFloat textScale = frame.textScaleFactor;
  const CGFloat localY = (y - document.frameOrigin.y) / textScale;
  const CGFloat epsilon = 1 / ((document.displayScale > 0 ? document.displayScale : 1) * textScale);
  auto range = frame.verticalSearchTable().indexRange(
      Range<Float32>{static_cast<Float32>(localY - epsilon), static_cast<Float32>(localY + epsilon)});
  if (range.isEmpty()) {
    range.start = MAX(0, range.start - 1);
    range.end = MIN(frame.lineCount, range.end + 1);
  }
  const STUTextFrameLine *const lines = STUTextFrameDataGetLines(__STUTextFrameGetData(document.textFrame));
  const STUTextFrameLine *closest = nullptr;
  CGFloat bestDistance = CGFLOAT_MAX;
  CGFloat bestCenterDistance = CGFLOAT_MAX;
  for (auto i = range.start; i < range.end; ++i) {
    const CGRect bounds = lineBounds(document, lines + i);
    const CGFloat distance = MAX(0, MAX(CGRectGetMinY(bounds) - y, y - CGRectGetMaxY(bounds)));
    const CGFloat centerDistance = ABS(y - CGRectGetMidY(bounds));
    if (distance < bestDistance || (distance == bestDistance && centerDistance < bestCenterDistance)) {
      closest = lines + i;
      bestDistance = distance;
      bestCenterDistance = centerDistance;
    }
  }
  return closest;
}

static STULabelTextInputPosition *positionClosestToX(STULabelTextInputDocument *document,
                                                      const STUTextFrameLine *line, CGFloat x)
{
  if (!line)
    return textPosition(0);
  if (line->width == 0)
    return textPosition(line->rangeInTruncatedString.start);
  const auto &carets = lineCarets(document, line).visual;
  const CGFloat scale = __STUTextFrameGetData(document.textFrame)->textScaleFactor;
  x = std::clamp<CGFloat>((x - document.frameOrigin.x) / scale - line->originX, 0, line->width);
  auto right = std::lower_bound(carets.begin(), carets.end(), x,
                               [](const auto &caret, CGFloat x) { return caret.x < x; });
  const bool useRight = right != carets.end()
      && (right == carets.begin() || right->x - x <= x - (right - 1)->x);
  // At coincident bidi edges, choose the edge bordering the glyph under the point.
  const auto &caret = useRight ? *right : *(right - 1);
  return textPosition(caret.index, caret.affinityForMovement(useRight));
}

static STULabelTextInputPosition *positionClosestToPoint(STULabelTextInputDocument *document, CGPoint point)
{
  return positionClosestToX(document, lineClosestToY(document, point.y), point.x);
}

static NSWritingDirection
baseWritingDirectionAtPosition(STULabelTextInputDocument *document, NSUInteger index, UITextStorageDirection direction)
{
  NSString *const string = document.string;
  STUTextFrame *const textFrame = document.textFrame;
  if (direction == UITextStorageDirectionBackward && index > 0) {
    --index;
  } else if (index == string.length && index > 0) {
    --index;
  }
  const STUTextFrameRange range = [textFrame rangeForRangeInTruncatedString:NSMakeRange(index, 0)];
  const STUTextFrameData *const data = __STUTextFrameGetData(textFrame);
  if (data->lineCount == 0 || data->paragraphCount == 0)
    return NSWritingDirectionNatural;
  const int32_t lineIndex = MIN((int32_t)range.start.lineIndex, data->lineCount - 1);
  const STUTextFrameLine *const line = STUTextFrameDataGetLines(data) + lineIndex;
  const STUTextFrameParagraph *const paragraph = STUTextFrameDataGetParagraphs(data) + line->paragraphIndex;
  return (NSWritingDirection)paragraph->baseWritingDirection;
}

static STULabelTextInputPosition *positionOnAdjacentLine(STULabelTextInputDocument *document,
                                                         STULabelTextInputPosition *position,
                                                         CGRect caret,
                                                         UITextLayoutDirection direction)
{
  STUTextFrame *const textFrame = document.textFrame;
  const STUTextFrameLine *const line = lineForPosition(document, position);
  if (!line)
    return position;
  const int32_t lineOffset = direction == UITextLayoutDirectionUp ? -1 : 1;
  const int32_t targetLineIndex = line->lineIndex + lineOffset;
  const STUTextFrameData *const data = __STUTextFrameGetData(textFrame);
  if (targetLineIndex < 0 || targetLineIndex >= data->lineCount)
    return position;

  const STUTextFrameLine *const targetLine = STUTextFrameDataGetLines(data) + targetLineIndex;
  return positionClosestToX(document, targetLine, CGRectGetMidX(caret));
}

static STULabelTextInputPosition *positionAtVisualEdge(STUTextFrameGraphemeClusterRange cluster, bool left)
{
  const NSRange range = STUTextFrameRangeGetRangeInTruncatedString(cluster.range);
  if (range.length == 0)
    return textPosition(range.location);
  const bool isLeftToRight = cluster.writingDirection == STUWritingDirectionLeftToRight;
  if (left == isLeftToRight)
    return textPosition(range.location, UITextStorageDirectionForward);
  return textPosition(NSMaxRange(range), UITextStorageDirectionBackward);
}

static bool areEqualTextPositions(STULabelTextInputPosition *a, STULabelTextInputPosition *b)
{
  return a.index == b.index && a.affinity == b.affinity;
}

static STULabelTextInputPosition *positionInHorizontalDirection(STULabelTextInputDocument *document,
                                                                STULabelTextInputPosition *position,
                                                                UITextLayoutDirection direction,
                                                                NSUInteger offset)
{
  if (offset == 0)
    return position;
  const STUTextFrameLine *line = lineForPosition(document, position);
  if (!line)
    return nil;
  const STUTextFrameData *const data = __STUTextFrameGetData(document.textFrame);
  const STUTextFrameLine *const lines = STUTextFrameDataGetLines(data);
  const bool movingRight = direction == UITextLayoutDirectionRight;
  const auto navigationBounds = [](const STUTextFrameLine *line, const stu_label::TextInputLineCarets &carets) {
    size_t first = 0;
    size_t last = carets.visual.size() - 1;
    // Crossing the last trailing whitespace character already enters the next
    // line. Do not add another stop at that character's coincident trailing edge.
    if (!line->isLastLine && line->trailingWhitespaceInTruncatedStringLength > 0 && first != last) {
      if (line->paragraphBaseWritingDirection == STUWritingDirectionLeftToRight)
        --last;
      else
        ++first;
    }
    return std::pair{first, last};
  };

  const auto *carets = &lineCarets(document, line);
  size_t index = carets->visualIndex(position.index, position.affinity);
  for (;;) {
    const auto [first, last] = navigationBounds(line, *carets);
    const size_t available = movingRight ? (index < last ? last - index : 0) : (index > first ? index - first : 0);
    if (offset <= available) {
      index = movingRight ? index + offset : index - offset;
      const auto &caret = carets->visual[index];
      return textPosition(caret.index, caret.affinityForMovement(movingRight));
    }
    offset -= available;
    const bool movingForward = movingRight == (line->paragraphBaseWritingDirection == STUWritingDirectionLeftToRight);
    const int32_t targetLineIndex = line->lineIndex + (movingForward ? 1 : -1);
    if (targetLineIndex < 0 || targetLineIndex >= data->lineCount)
      return nil;
    line = lines + targetLineIndex;
    carets = &lineCarets(document, line);
    const auto [targetFirst, targetLast] = navigationBounds(line, *carets);
    const bool targetLeft = movingForward == (line->paragraphBaseWritingDirection == STUWritingDirectionLeftToRight);
    index = targetLeft ? targetFirst : targetLast;
    if (--offset == 0) {
      const auto &caret = carets->visual[index];
      return textPosition(caret.index, caret.affinityForMovement(!targetLeft));
    }
  }
}

static NSRange characterRangeInDirection(STULabelTextInputDocument *document,
                                         STULabelTextInputPosition *position,
                                         UITextLayoutDirection direction)
{
  // Like UITextView, this query extends in storage order: left looks backward,
  // and the other directions look forward. Visual neighbours can straddle a bidi run.
  NSString *const string = document.string;
  NSUInteger index = position.index;
  if (direction == UITextLayoutDirectionLeft) {
    if (index == 0)
      return NSMakeRange(0, 0);
    --index;
  } else if (index == string.length) {
    return NSMakeRange(index, 0);
  }
  return [string rangeOfComposedCharacterSequenceAtIndex:index];
}

static STULabelTextInputPosition *positionFarthestInDirection(STULabelTextInputDocument *document,
                                                              STULabelTextInputRange *range,
                                                              UITextLayoutDirection direction)
{
  if (direction == UITextLayoutDirectionUp)
    return range.startPosition;
  if (direction == UITextLayoutDirectionDown)
    return range.endPosition;

  const NSRange stringRange =
      NSMakeRange(range.startPosition.index, range.endPosition.index - range.startPosition.index);
  if (stringRange.length == 0)
    return range.startPosition;

  const bool wantsLeft = direction == UITextLayoutDirectionLeft;
  const CGFloat scale = document.displayScale > 0 ? document.displayScale : 1;
  STULabelTextInputPosition *bestPosition = nil;
  CGFloat bestX = wantsLeft ? CGFLOAT_MAX : -CGFLOAT_MAX;
  STUTextRectArray *const rects = rectsForRange(document, stringRange);
  for (size_t i = 0; i < rects.rectCount; ++i) {
    const CGRect rect = [rects rectAtIndex:i];
    const CGFloat inset = MIN(rect.size.width / 4, 0.5 / scale);
    const CGPoint point =
        CGPointMake(wantsLeft ? CGRectGetMinX(rect) + inset : CGRectGetMaxX(rect) - inset, CGRectGetMidY(rect));
    const STUTextFrameGraphemeClusterRange cluster = clusterClosestToPoint(document, point);
    STULabelTextInputPosition *const candidate = positionAtVisualEdge(cluster, wantsLeft);
    if (candidate.index < range.startPosition.index || candidate.index > range.endPosition.index)
      continue;
    const CGFloat x = CGRectGetMidX(caretRect(document, candidate));
    if (!bestPosition || (wantsLeft ? x < bestX : x > bestX)) {
      bestPosition = candidate;
      bestX = x;
    }
  }
  return bestPosition ?: range.startPosition;
}

@implementation STULabelTextInteraction

@synthesize stu_interaction = _interaction;
@synthesize stu_inputDelegate = _stu_inputDelegate;
@synthesize stu_tokenizer = _stu_tokenizer;
@synthesize stu_document = _stu_document;
@synthesize stu_isPublishingDocument = _stu_isPublishingDocument;
@synthesize stu_selectionAffinity = _stu_selectionAffinity;

- (instancetype)initWithLabel:(STULabel *)label
{
  if ((self = [super init])) {
    _label = label;
    _interaction = [UITextInteraction textInteractionForMode:UITextInteractionModeNonEditable];
    _interaction.delegate = self;
    _interaction.textInput = label;
    _stu_selectionAffinity = UITextStorageDirectionForward;
  }
  return self;
}

- (void)stu_invalidate
{
  _interaction.delegate = nil;
  _interaction.textInput = nil;
  _label = nil;
}

- (void)stu_textDidDisplay
{
  STULabel *const label = _label;
  if (label)
    updateVisibleDocument(label, self);
}

- (BOOL)interactionShouldBegin:(UITextInteraction *__unused)interaction atPoint:(CGPoint)point
{
  STULabel *const label = _label;
  return label.isSelectable && ![label.links linkClosestToPoint:point maxDistance:label.linkTouchAreaExtensionRadius];
}

@end

@implementation STULabel (UITextInput)

@dynamic textInteraction;

- (BOOL)hasText
{
  return textInputDocument(self).string.length != 0;
}

- (void)insertText:(NSString *__unused)text
{}
- (void)deleteBackward
{}

- (nullable NSString *)textInRange:(UITextRange *)range
{
  NSString *const string = textInputDocument(self).string;
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return nil;
  return [string substringWithRange:NSMakeRange(r.startPosition.index, r.endPosition.index - r.startPosition.index)];
}

- (void)replaceRange:(UITextRange *__unused)range withText:(NSString *__unused)text
{}

- (nullable UITextRange *)selectedTextRange
{
  return textInputDocument(self).selectedTextRange;
}

- (void)setSelectedTextRange:(nullable UITextRange *)range
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInteraction *const interaction = textInteraction(self);
  STULabelTextInputRange *newRange = range ? validTextRange(range, string) : nil;
  if (range && !newRange)
    return;
  if (newRange) {
    const NSRange normalizedRange = selectionRangeExcludingTruncationTokenLink(
        document, NSMakeRange(newRange.startPosition.index, newRange.endPosition.index - newRange.startPosition.index));
    if (normalizedRange.location == NSNotFound) {
      newRange = nil;
    } else if (normalizedRange.location != newRange.startPosition.index ||
               NSMaxRange(normalizedRange) != newRange.endPosition.index) {
      newRange = [[STULabelTextInputRange alloc] initWithStart:textPosition(normalizedRange.location)
                                                           end:textPosition(NSMaxRange(normalizedRange))];
    }
  }
  STULabelTextInputRange *const oldRange = document.selectedTextRange;
  if (oldRange == newRange || [oldRange isEqual:newRange])
    return;
  [interaction.stu_inputDelegate selectionWillChange:self];
  interaction.stu_document = [document documentWithSelectedTextRange:newRange];
  [interaction.stu_inputDelegate selectionDidChange:self];
}

- (nullable UITextRange *)markedTextRange
{
  return nil;
}
- (nullable NSDictionary<NSAttributedStringKey, id> *)markedTextStyle
{
  return nil;
}
- (void)setMarkedTextStyle:(NSDictionary<NSAttributedStringKey, id> *__unused)markedTextStyle
{}
- (void)setMarkedText:(NSString *__unused)markedText selectedRange:(NSRange __unused)selectedRange
{}
- (void)unmarkText
{}

- (UITextPosition *)beginningOfDocument
{
  textInputDocument(self);
  return textPosition(0);
}
- (UITextPosition *)endOfDocument
{
  return textPosition(textInputDocument(self).string.length);
}

- (nullable UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
  NSString *const string = textInputDocument(self).string;
  STULabelTextInputPosition *const from = validTextPosition(fromPosition, string);
  STULabelTextInputPosition *const to = validTextPosition(toPosition, string);
  if (!from || !to)
    return nil;
  // UIKit supplies the endpoints in either order while moving selection handles.
  STULabelTextInputPosition *const start = from.index <= to.index ? from : to;
  STULabelTextInputPosition *const end = from.index <= to.index ? to : from;
  return [[STULabelTextInputRange alloc] initWithStart:start end:end];
}

- (nullable UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
  NSString *const string = textInputDocument(self).string;
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p)
    return nil;
  if (offset == 0)
    return p;
  NSUInteger index;
  if (offset >= 0) {
    const NSUInteger unsignedOffset = (NSUInteger)offset;
    if (unsignedOffset > string.length - p.index)
      return nil;
    index = p.index + unsignedOffset;
  } else {
    // Avoid negating NSIntegerMin.
    const NSUInteger unsignedOffset = (NSUInteger)(-(offset + 1)) + 1;
    if (unsignedOffset > p.index)
      return nil;
    index = p.index - unsignedOffset;
  }
  // UITextInput offsets count UTF-16 code units, not composed character sequences.
  return textPosition(index);
}

- (nullable UITextPosition *)positionFromPosition:(UITextPosition *)position
                                      inDirection:(UITextLayoutDirection)direction
                                           offset:(NSInteger)offset
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p || offset < 0)
    return nil;
  if (direction == UITextLayoutDirectionLeft || direction == UITextLayoutDirectionRight)
    return positionInHorizontalDirection(document, p, direction, (NSUInteger)offset);
  STULabelTextInputPosition *currentPosition = p;
  while (offset-- > 0) {
    const CGRect rect = caretRect(document, currentPosition);
    if (CGRectIsEmpty(rect))
      return nil;
    STULabelTextInputPosition *const nextPosition = positionOnAdjacentLine(document, currentPosition, rect, direction);
    if (areEqualTextPositions(nextPosition, currentPosition))
      return nil;
    currentPosition = nextPosition;
  }
  return currentPosition;
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
  NSString *const string = textInputDocument(self).string;
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  STULabelTextInputPosition *const otherP = validTextPosition(other, string);
  if (!p || !otherP)
    return NSOrderedSame;
  return p.index < otherP.index ? NSOrderedAscending : p.index > otherP.index ? NSOrderedDescending : NSOrderedSame;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)to
{
  NSString *const string = textInputDocument(self).string;
  STULabelTextInputPosition *const start = validTextPosition(from, string);
  STULabelTextInputPosition *const end = validTextPosition(to, string);
  if (!start || !end)
    return 0;
  return (NSInteger)end.index - (NSInteger)start.index;
}

- (nullable id<UITextInputDelegate>)inputDelegate
{
  return textInteraction(self).stu_inputDelegate;
}
- (void)setInputDelegate:(nullable id<UITextInputDelegate>)inputDelegate
{
  textInteraction(self).stu_inputDelegate = inputDelegate;
}

- (id<UITextInputTokenizer>)tokenizer
{
  STULabelTextInteraction *const interaction = textInteraction(self);
  if (!interaction.stu_tokenizer) {
    interaction.stu_tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
  }
  return interaction.stu_tokenizer;
}

- (nullable UITextPosition *)positionWithinRange:(UITextRange *)range
                             farthestInDirection:(UITextLayoutDirection)direction
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return nil;
  return positionFarthestInDirection(document, r, direction);
}

- (nullable UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position
                                                inDirection:(UITextLayoutDirection)direction
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p)
    return nil;
  const NSRange range = characterRangeInDirection(document, p, direction);
  if (range.length == 0)
    return nil;
  return [[STULabelTextInputRange alloc] initWithStart:textPosition(range.location)
                                                   end:textPosition(NSMaxRange(range))];
}

- (NSWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position
                                          inDirection:(UITextStorageDirection)direction
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  return p ? baseWritingDirectionAtPosition(document, p.index, direction) : NSWritingDirectionNatural;
}

- (void)setBaseWritingDirection:(NSWritingDirection __unused)writingDirection forRange:(UITextRange *__unused)range
{}

- (CGRect)firstRectForRange:(UITextRange *)range
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return CGRectZero;
  if (r.empty)
    return caretRect(document, r.startPosition);
  STUTextRectArray *const rects =
      rectsForRange(document, NSMakeRange(r.startPosition.index, r.endPosition.index - r.startPosition.index));
  return rects.rectCount ? [rects rectAtIndex:0] : CGRectZero;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  STULabelTextInputPosition *const p = validTextPosition(position, document.string);
  return p ? caretRect(document, p) : CGRectZero;
}

- (NSArray<UITextSelectionRect *> *)selectionRectsForRange:(UITextRange *)range
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r || r.empty)
    return @[];
  const NSRange selectionRange = NSMakeRange(r.startPosition.index, r.endPosition.index - r.startPosition.index);
  STUTextRectArray *const rects = rectsForRange(document, selectionRange);
  const NSUInteger startRectIndex = selectionRectIndexContainingEndpoint(document, rects, string, selectionRange, true);
  const NSUInteger endRectIndex = selectionRectIndexContainingEndpoint(document, rects, string, selectionRange, false);
  NSMutableArray<UITextSelectionRect *> *const result = [NSMutableArray arrayWithCapacity:rects.rectCount];
  for (size_t i = 0; i < rects.rectCount; ++i) {
    const CGRect rect = [rects rectAtIndex:i];
    STULabelTextSelectionRect *const selectionRect = [[STULabelTextSelectionRect alloc]
            initWithRect:rect
        writingDirection:writingDirectionAtPoint(document, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)))
           containsStart:i == (startRectIndex == NSNotFound ? 0 : startRectIndex)
             containsEnd:i == (endRectIndex == NSNotFound ? rects.rectCount - 1 : endRectIndex)];
    [result addObject:selectionRect];
  }
  return result;
}

- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  return positionClosestToPoint(document, point);
}

- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return nil;
  if (r.empty)
    return r.startPosition;
  STULabelTextInputPosition *const p = positionClosestToPoint(document, point);
  return p.index < r.startPosition.index ? r.startPosition
         : p.index > r.endPosition.index ? r.endPosition
                                        : p;
}

- (nullable UITextRange *)characterRangeAtPoint:(CGPoint)point
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  const STUTextFrameGraphemeClusterRange cluster = clusterClosestToPoint(document, point);
  const NSRange range = STUTextFrameRangeGetRangeInTruncatedString(cluster.range);
  if (range.length == 0)
    return nil;
  return [[STULabelTextInputRange alloc] initWithStart:textPosition(range.location)
                                                   end:textPosition(NSMaxRange(range))];
}

- (nullable NSDictionary<NSAttributedStringKey, id> *)textStylingAtPosition:(UITextPosition *)position
                                                                inDirection:(UITextStorageDirection __unused)direction
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p || string.length == 0)
    return nil;
  const NSUInteger index = p.index == string.length ? p.index - 1 : p.index;
  return [document.textFrame attributesAtIndexInTruncatedString:index];
}

- (nullable UITextPosition *)positionWithinRange:(UITextRange *)range atCharacterOffset:(NSInteger)offset
{
  NSString *const string = textInputDocument(self).string;
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r || offset < 0)
    return nil;
  const NSUInteger unsignedOffset = (NSUInteger)offset;
  if (unsignedOffset > r.endPosition.index - r.startPosition.index)
    return nil;
  const NSUInteger index = r.startPosition.index + unsignedOffset;
  return textPosition(index);
}

- (NSInteger)characterOffsetOfPosition:(UITextPosition *)position withinRange:(UITextRange *)range
{
  NSString *const string = textInputDocument(self).string;
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!p || !r || p.index < r.startPosition.index || p.index > r.endPosition.index)
    return 0;
  return (NSInteger)p.index - (NSInteger)r.startPosition.index;
}

- (__kindof UIView *)textInputView
{
  return self;
}
- (UITextStorageDirection)selectionAffinity
{
  return textInteraction(self).stu_selectionAffinity;
}
- (void)setSelectionAffinity:(UITextStorageDirection)selectionAffinity
{
  textInteraction(self).stu_selectionAffinity = selectionAffinity;
}

- (void)copy:(id __unused)sender
{
  UITextRange *const range = self.selectedTextRange;
  NSString *const string = range ? [self textInRange:range] : nil;
  if (string.length != 0)
    UIPasteboard.generalPasteboard.string = string;
}

- (void)cut:(id __unused)sender
{}
- (void)paste:(id __unused)sender
{}
- (void)delete:(id __unused)sender
{}

- (void)selectAll:(id __unused)sender
{
  self.selectedTextRange = [self textRangeFromPosition:self.beginningOfDocument toPosition:self.endOfDocument];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
  if (action == @selector(copy:))
    return self.selectedTextRange && !self.selectedTextRange.empty;
  if (action == @selector(selectAll:))
    return self.hasText;
  if (action == @selector(cut:) || action == @selector(paste:) || action == @selector(delete:)) {
    return NO;
  }
  // UIKit provides services such as Look Up, Translate, Search Web and Share through
  // responder actions. Let the responder chain validate those system-owned actions.
  return [super canPerformAction:action withSender:sender];
}

- (BOOL)shouldChangeTextInRange:(UITextRange *__unused)range replacementText:(NSString *__unused)text
{
  return NO;
}

- (NSAttributedString *)attributedTextInRange:(UITextRange *)range
{
  STULabelTextInputDocument *const document = textInputDocument(self);
  NSString *const string = document.string;
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return [[NSAttributedString alloc] initWithString:@""];
  return [document.textFrame.truncatedAttributedString
      attributedSubstringFromRange:NSMakeRange(r.startPosition.index, r.endPosition.index - r.startPosition.index)];
}

- (void)insertAttributedText:(NSAttributedString *__unused)string
{}
- (void)replaceRange:(UITextRange *__unused)range withAttributedText:(NSAttributedString *__unused)attributedText
{}
- (void)setAttributedMarkedText:(NSAttributedString *__unused)markedText
                  selectedRange:(NSRange __unused)selectedRange API_UNAVAILABLE(watchos)
{}

- (BOOL)isEditable
{
  return NO;
}

@end
