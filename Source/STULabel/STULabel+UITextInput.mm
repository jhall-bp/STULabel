// Copyright 2026 Stephan Tolksdorf

#import "STULabel+UITextInput-Internal.h"

#import "STULabelLayer.h"
#import "STUTextFrame.h"
#import "STUTextFrame-Unsafe.h"

@interface STULabelTextInputPosition : UITextPosition <NSCopying> {
@private
  NSUInteger _index;
}
@property (nonatomic, readonly) NSUInteger index;
- (instancetype)initWithIndex:(NSUInteger)index;
@end

@implementation STULabelTextInputPosition
- (instancetype)initWithIndex:(NSUInteger)index
{
  if ((self = [super init])) {
    _index = index;
  }
  return self;
}
- (NSUInteger)index
{
  return _index;
}
- (id)copyWithZone:(NSZone *__unused)zone
{
  return self;
}
- (BOOL)isEqual:(id)object
{
  return
      [object isKindOfClass:STULabelTextInputPosition.class] && _index == ((STULabelTextInputPosition *)object)->_index;
}
- (NSUInteger)hash
{
  return _index;
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

static STU_INLINE NSString *visibleString(STULabel *self) { return self.textFrame.truncatedAttributedString.string; }

static STU_INLINE STULabelTextInputPosition *textPosition(NSUInteger index)
{
  return [[STULabelTextInputPosition alloc] initWithIndex:index];
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

static STU_INLINE NSUInteger previousCharacterBoundary(NSString *string, NSUInteger index)
{
  if (index == 0)
    return 0;
  return [string rangeOfComposedCharacterSequenceAtIndex:index - 1].location;
}

static STU_INLINE NSUInteger nextCharacterBoundary(NSString *string, NSUInteger index)
{
  if (index >= string.length)
    return string.length;
  return NSMaxRange([string rangeOfComposedCharacterSequenceAtIndex:index]);
}

static void updateVisibleString(STULabel *self, STULabelTextInteraction *interaction)
{
  NSString *const string = visibleString(self);
  if (!interaction.stu_displayedString) {
    interaction.stu_displayedString = string;
    return;
  }
  const bool didChange = ![interaction.stu_displayedString isEqualToString:string];
  if (!didChange)
    return;

  const bool hadSelection = interaction.stu_selectedTextRange != nil;
  id<UITextInputDelegate> const inputDelegate = interaction.stu_inputDelegate;
  [inputDelegate textWillChange:self];
  if (hadSelection)
    [inputDelegate selectionWillChange:self];
  interaction.stu_displayedString = string;
  interaction.stu_selectedTextRange = nil;
  [inputDelegate textDidChange:self];
  if (hadSelection)
    [inputDelegate selectionDidChange:self];
}

static STU_INLINE STULabelTextInteraction *textInteraction(STULabel *self) { return [self stu_textInteraction]; }

static STU_INLINE NSString *textInputString(STULabel *self)
{
  updateVisibleString(self, textInteraction(self));
  return visibleString(self);
}

static NSRange truncationTokenLinkRange(STULabel *self)
{
  STUTextFrame *const textFrame = self.textFrame;
  const NSRange tokenRange = STUTextFrameRangeGetRangeInTruncatedString(textFrame.rangeOfLastTruncationToken);
  if (tokenRange.length == 0)
    return NSMakeRange(NSNotFound, 0);
  for (STUTextLink *const link in self.links) {
    const NSRange tokenLinkRange = NSIntersectionRange(tokenRange, link.rangeInTruncatedString);
    if (tokenLinkRange.length != 0)
      return tokenLinkRange;
  }
  return NSMakeRange(NSNotFound, 0);
}

static NSRange selectionRangeExcludingTruncationTokenLink(STULabel *self, NSRange range)
{
  const NSRange linkRange = truncationTokenLinkRange(self);
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

static STUTextRectArray *rectsForRange(STULabel *self, NSRange range)
{
  if (range.length == 0)
    return STUTextRectArray.emptyArray;
  STUTextFrame *const textFrame = self.textFrame;
  return [textFrame rectsForRange:[textFrame rangeForRangeInTruncatedString:range]
                      frameOrigin:self.textFrameOrigin
                     displayScale:self.layer.contentsScale];
}

static NSUInteger selectionRectIndexContainingEndpoint(
    STULabel *self, STUTextRectArray *selectionRects, NSString *string, NSRange selectionRange, bool start)
{
  if (selectionRange.length == 0)
    return NSNotFound;
  const NSUInteger characterIndex = start ? selectionRange.location : NSMaxRange(selectionRange) - 1;
  const NSRange characterRange =
      NSIntersectionRange(selectionRange, [string rangeOfComposedCharacterSequenceAtIndex:characterIndex]);
  STUTextRectArray *const characterRects = rectsForRange(self, characterRange);
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

static STUTextFrameGraphemeClusterRange clusterClosestToPoint(STULabel *self, CGPoint point)
{
  return [self.textFrame rangeOfGraphemeClusterClosestToPoint:point
                                   ignoringTrailingWhitespace:true
                                                  frameOrigin:self.textFrameOrigin
                                                 displayScale:self.layer.contentsScale];
}

static NSWritingDirection writingDirectionAtPoint(STULabel *self, CGPoint point)
{
  return (NSWritingDirection)clusterClosestToPoint(self, point).writingDirection;
}

static CGRect caretRect(STULabel *self, NSUInteger index)
{
  NSString *const string = visibleString(self);
  if (string.length == 0)
    return CGRectZero;
  const bool usesPreviousCharacter = index == string.length;
  const NSUInteger start = usesPreviousCharacter ? previousCharacterBoundary(string, index) : index;
  const NSUInteger end = usesPreviousCharacter ? index : nextCharacterBoundary(string, index);
  STUTextRectArray *const rects = rectsForRange(self, NSMakeRange(start, end - start));
  if (rects.rectCount == 0)
    return CGRectZero;
  CGRect const rect = [rects rectAtIndex:usesPreviousCharacter ? rects.rectCount - 1 : 0];
  const NSWritingDirection direction =
      writingDirectionAtPoint(self, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)));
  const bool useMaxX = usesPreviousCharacter == (direction == NSWritingDirectionLeftToRight);
  const CGFloat scale = self.layer.contentsScale > 0 ? self.layer.contentsScale : 1;
  const CGFloat width = 1 / scale;
  return CGRectMake(useMaxX ? CGRectGetMaxX(rect) - width / 2 : CGRectGetMinX(rect) - width / 2,
                    rect.origin.y,
                    width,
                    rect.size.height);
}

static NSWritingDirection writingDirectionAtPosition(STULabel *self, NSUInteger index)
{
  CGRect const rect = caretRect(self, index);
  if (!CGRectIsEmpty(rect)) {
    return writingDirectionAtPoint(self, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)));
  }
  return NSWritingDirectionLeftToRight;
}

static NSWritingDirection
baseWritingDirectionAtPosition(STULabel *self, NSString *string, NSUInteger index, UITextStorageDirection direction)
{
  STUTextFrame *const textFrame = self.textFrame;
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

static NSUInteger
positionOnAdjacentLine(STULabel *self, NSUInteger index, CGRect caret, UITextLayoutDirection direction)
{
  STUTextFrame *const textFrame = self.textFrame;
  const STUTextFrameRange indexRange = [textFrame rangeForRangeInTruncatedString:NSMakeRange(index, 0)];
  const int32_t lineOffset = direction == UITextLayoutDirectionUp ? -1 : 1;
  const int32_t targetLineIndex = (int32_t)indexRange.start.lineIndex + lineOffset;
  const STUTextFrameData *const data = __STUTextFrameGetData(textFrame);
  if (targetLineIndex < 0 || targetLineIndex >= data->lineCount)
    return index;

  const STUTextFrameLine *const targetLine = STUTextFrameDataGetLines(data) + targetLineIndex;
  const NSRange targetRange =
      NSMakeRange((NSUInteger)targetLine->rangeInTruncatedString.start,
                  (NSUInteger)(targetLine->rangeInTruncatedString.end - targetLine->rangeInTruncatedString.start));
  if (targetRange.length == 0)
    return targetRange.location;

  const STUTextFrameLayoutInfo layoutInfo = [textFrame layoutInfoForFrameOrigin:self.textFrameOrigin
                                                                   displayScale:self.layer.contentsScale];
  const CGFloat textScaleFactor = layoutInfo.textScaleFactor > 0 ? layoutInfo.textScaleFactor : 1;
  const CGFloat x = (CGRectGetMidX(caret) - self.textFrameOrigin.x) / textScaleFactor - targetLine->originX;
  const CGFloat xOffset = x < 0 ? 0 : x > targetLine->width ? targetLine->width : x;
  const STUTextFrameGraphemeClusterRange cluster =
      STUTextFrameLineGetRangeOfGraphemeClusterAtXOffset(targetLine, xOffset);
  const NSRange clusterRange = STUTextFrameRangeGetRangeInTruncatedString(cluster.range);
  return direction == UITextLayoutDirectionUp ? clusterRange.location : NSMaxRange(clusterRange);
}

static NSUInteger
positionInDirection(STULabel *self, NSString *string, NSUInteger index, UITextLayoutDirection direction)
{
  const NSWritingDirection writingDirection = writingDirectionAtPosition(self, index);
  switch (direction) {
  case UITextLayoutDirectionLeft:
    return writingDirection == NSWritingDirectionRightToLeft ? nextCharacterBoundary(string, index)
                                                             : previousCharacterBoundary(string, index);
  case UITextLayoutDirectionRight:
    return writingDirection == NSWritingDirectionRightToLeft ? previousCharacterBoundary(string, index)
                                                             : nextCharacterBoundary(string, index);
  case UITextLayoutDirectionUp:
  case UITextLayoutDirectionDown: {
    CGRect const rect = caretRect(self, index);
    if (CGRectIsEmpty(rect))
      return index;
    return positionOnAdjacentLine(self, index, rect, direction);
  }
  }
}

static NSRange
characterRangeInDirection(STULabel *self, NSString *string, NSUInteger index, UITextLayoutDirection direction)
{
  const NSUInteger otherIndex = positionInDirection(self, string, index, direction);
  if (otherIndex == index)
    return NSMakeRange(index, 0);
  return otherIndex < index ? NSMakeRange(otherIndex, index - otherIndex) : NSMakeRange(index, otherIndex - index);
}

@implementation STULabelTextInteraction

@synthesize stu_interaction = _interaction;
@synthesize stu_inputDelegate = _stu_inputDelegate;
@synthesize stu_selectedTextRange = _stu_selectedTextRange;
@synthesize stu_tokenizer = _stu_tokenizer;
@synthesize stu_displayedString = _stu_displayedString;
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
    updateVisibleString(label, self);
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
  return textInputString(self).length != 0;
}

- (void)insertText:(NSString *__unused)text
{}
- (void)deleteBackward
{}

- (nullable NSString *)textInRange:(UITextRange *)range
{
  NSString *const string = textInputString(self);
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return nil;
  return [string substringWithRange:NSMakeRange(r.startPosition.index, r.endPosition.index - r.startPosition.index)];
}

- (void)replaceRange:(UITextRange *__unused)range withText:(NSString *__unused)text
{}

- (nullable UITextRange *)selectedTextRange
{
  textInputString(self);
  return textInteraction(self).stu_selectedTextRange;
}

- (void)setSelectedTextRange:(nullable UITextRange *)range
{
  NSString *const string = textInputString(self);
  STULabelTextInteraction *const interaction = textInteraction(self);
  STULabelTextInputRange *newRange = range ? validTextRange(range, string) : nil;
  if (range && !newRange)
    return;
  if (newRange) {
    const NSRange normalizedRange = selectionRangeExcludingTruncationTokenLink(
        self, NSMakeRange(newRange.startPosition.index, newRange.endPosition.index - newRange.startPosition.index));
    if (normalizedRange.location == NSNotFound) {
      newRange = nil;
    } else if (normalizedRange.location != newRange.startPosition.index ||
               NSMaxRange(normalizedRange) != newRange.endPosition.index) {
      newRange = [[STULabelTextInputRange alloc] initWithStart:textPosition(normalizedRange.location)
                                                           end:textPosition(NSMaxRange(normalizedRange))];
    }
  }
  STULabelTextInputRange *const oldRange = (STULabelTextInputRange *)interaction.stu_selectedTextRange;
  if (oldRange == newRange || [oldRange isEqual:newRange])
    return;
  [interaction.stu_inputDelegate selectionWillChange:self];
  interaction.stu_selectedTextRange = newRange;
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
  textInputString(self);
  return textPosition(0);
}
- (UITextPosition *)endOfDocument
{
  return textPosition(textInputString(self).length);
}

- (nullable UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
  NSString *const string = textInputString(self);
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
  NSString *const string = textInputString(self);
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p)
    return nil;
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
  NSString *const string = textInputString(self);
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p || offset < 0)
    return nil;
  NSUInteger index = p.index;
  while (offset-- > 0) {
    const NSUInteger next = positionInDirection(self, string, index, direction);
    if (next == index)
      return nil;
    index = next;
  }
  return textPosition(index);
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
  NSString *const string = textInputString(self);
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  STULabelTextInputPosition *const otherP = validTextPosition(other, string);
  if (!p || !otherP)
    return NSOrderedSame;
  return p.index < otherP.index ? NSOrderedAscending : p.index > otherP.index ? NSOrderedDescending : NSOrderedSame;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)to
{
  NSString *const string = textInputString(self);
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
  NSString *const string = textInputString(self);
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return nil;
  const NSWritingDirection writingDirection = writingDirectionAtPosition(self, r.startPosition.index);
  const bool wantsStart =
      direction == UITextLayoutDirectionUp ||
      (direction == UITextLayoutDirectionLeft && writingDirection != NSWritingDirectionRightToLeft) ||
      (direction == UITextLayoutDirectionRight && writingDirection == NSWritingDirectionRightToLeft);
  return wantsStart ? r.startPosition : r.endPosition;
}

- (nullable UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position
                                                inDirection:(UITextLayoutDirection)direction
{
  NSString *const string = textInputString(self);
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p)
    return nil;
  const NSRange range = characterRangeInDirection(self, string, p.index, direction);
  if (range.length == 0)
    return nil;
  return [[STULabelTextInputRange alloc] initWithStart:textPosition(range.location)
                                                   end:textPosition(NSMaxRange(range))];
}

- (NSWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position
                                          inDirection:(UITextStorageDirection)direction
{
  NSString *const string = textInputString(self);
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  return p ? baseWritingDirectionAtPosition(self, string, p.index, direction) : NSWritingDirectionNatural;
}

- (void)setBaseWritingDirection:(NSWritingDirection __unused)writingDirection forRange:(UITextRange *__unused)range
{}

- (CGRect)firstRectForRange:(UITextRange *)range
{
  NSString *const string = textInputString(self);
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return CGRectZero;
  if (r.empty)
    return caretRect(self, r.startPosition.index);
  STUTextRectArray *const rects =
      rectsForRange(self, NSMakeRange(r.startPosition.index, r.endPosition.index - r.startPosition.index));
  return rects.rectCount ? [rects rectAtIndex:0] : CGRectZero;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
  STULabelTextInputPosition *const p = validTextPosition(position, textInputString(self));
  return p ? caretRect(self, p.index) : CGRectZero;
}

- (NSArray<UITextSelectionRect *> *)selectionRectsForRange:(UITextRange *)range
{
  NSString *const string = textInputString(self);
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r || r.empty)
    return @[];
  const NSRange selectionRange = NSMakeRange(r.startPosition.index, r.endPosition.index - r.startPosition.index);
  STUTextRectArray *const rects = rectsForRange(self, selectionRange);
  const NSUInteger startRectIndex = selectionRectIndexContainingEndpoint(self, rects, string, selectionRange, true);
  const NSUInteger endRectIndex = selectionRectIndexContainingEndpoint(self, rects, string, selectionRange, false);
  NSMutableArray<UITextSelectionRect *> *const result = [NSMutableArray arrayWithCapacity:rects.rectCount];
  for (size_t i = 0; i < rects.rectCount; ++i) {
    const CGRect rect = [rects rectAtIndex:i];
    STULabelTextSelectionRect *const selectionRect = [[STULabelTextSelectionRect alloc]
            initWithRect:rect
        writingDirection:writingDirectionAtPoint(self, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)))
           containsStart:i == (startRectIndex == NSNotFound ? 0 : startRectIndex)
             containsEnd:i == (endRectIndex == NSNotFound ? rects.rectCount - 1 : endRectIndex)];
    [result addObject:selectionRect];
  }
  return result;
}

- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point
{
  textInputString(self);
  const STUTextFrameGraphemeClusterRange cluster = clusterClosestToPoint(self, point);
  const NSRange range = STUTextFrameRangeGetRangeInTruncatedString(cluster.range);
  if (range.length == 0)
    return textPosition(range.location);
  const CGFloat midX = CGRectGetMidX(cluster.bounds);
  const bool onTrailingHalf =
      cluster.writingDirection == STUWritingDirectionLeftToRight ? point.x >= midX : point.x <= midX;
  return textPosition(onTrailingHalf ? NSMaxRange(range) : range.location);
}

- (nullable UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
{
  NSString *const string = textInputString(self);
  STULabelTextInputRange *const r = validTextRange(range, string);
  UITextPosition *const position = [self closestPositionToPoint:point];
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!r || !p)
    return nil;
  const NSUInteger index = p.index < r.startPosition.index ? r.startPosition.index
                           : p.index > r.endPosition.index ? r.endPosition.index
                                                           : p.index;
  return textPosition(index);
}

- (nullable UITextRange *)characterRangeAtPoint:(CGPoint)point
{
  textInputString(self);
  const STUTextFrameGraphemeClusterRange cluster = clusterClosestToPoint(self, point);
  const NSRange range = STUTextFrameRangeGetRangeInTruncatedString(cluster.range);
  if (range.length == 0)
    return nil;
  return [[STULabelTextInputRange alloc] initWithStart:textPosition(range.location)
                                                   end:textPosition(NSMaxRange(range))];
}

- (nullable NSDictionary<NSAttributedStringKey, id> *)textStylingAtPosition:(UITextPosition *)position
                                                                inDirection:(UITextStorageDirection __unused)direction
{
  NSString *const string = textInputString(self);
  STULabelTextInputPosition *const p = validTextPosition(position, string);
  if (!p || string.length == 0)
    return nil;
  const NSUInteger index = p.index == string.length ? p.index - 1 : p.index;
  return [self.textFrame attributesAtIndexInTruncatedString:index];
}

- (nullable UITextPosition *)positionWithinRange:(UITextRange *)range atCharacterOffset:(NSInteger)offset
{
  NSString *const string = textInputString(self);
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
  NSString *const string = textInputString(self);
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
  NSString *const string = textInputString(self);
  STULabelTextInputRange *const r = validTextRange(range, string);
  if (!r)
    return [[NSAttributedString alloc] initWithString:@""];
  return [self.textFrame.truncatedAttributedString
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
