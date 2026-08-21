// Copyright 2026 Stephan Tolksdorf

#import "STULabel/STULabel+UITextInput.h"
#import "STULabel/STULabel+UITextInput-Internal.h"
#import "STULabel/STUTextFrame.h"
#import "STULabel/STUTextRectArray.h"

#import <XCTest/XCTest.h>

@interface TextInputDelegateRecorder : NSObject <UITextInputDelegate>
@property (nonatomic) NSUInteger selectionWillChangeCount;
@property (nonatomic) NSUInteger selectionDidChangeCount;
@property (nonatomic) NSUInteger textWillChangeCount;
@property (nonatomic) NSUInteger textDidChangeCount;
@end

@implementation TextInputDelegateRecorder
- (void)selectionWillChange:(id<UITextInput> __unused)textInput
{
  ++_selectionWillChangeCount;
}
- (void)selectionDidChange:(id<UITextInput> __unused)textInput
{
  ++_selectionDidChangeCount;
}
- (void)textWillChange:(id<UITextInput> __unused)textInput
{
  ++_textWillChangeCount;
}
- (void)textDidChange:(id<UITextInput> __unused)textInput
{
  ++_textDidChangeCount;
}
- (void)conversationContext:(UIConversationContext *__unused)context
                  didChange:(id<UITextInput> __unused)textInput API_AVAILABLE(ios(18.4))
{}
@end

@interface ContextMenuDelegateRecorder : NSObject <STULabelDelegate>
@property (nonatomic) UIContextMenuConfiguration *configuration;
@property (nonatomic, readonly) NSUInteger callCount;
@property (nonatomic, readonly, weak) STULabel *lastLabel;
@property (nonatomic, readonly) STUTextLink *lastLink;
@property (nonatomic, readonly) CGPoint lastLocation;
@end

@implementation ContextMenuDelegateRecorder
- (UIContextMenuConfiguration *)label:(STULabel *)label
      contextMenuConfigurationForLink:(STUTextLink *)link
                           atLocation:(CGPoint)location
{
  ++_callCount;
  _lastLabel = label;
  _lastLink = link;
  _lastLocation = location;
  return _configuration;
}
@end

@interface TextInputSystemActionLabel : STULabel
- (void)performSystemAction:(id)sender;
@end

@implementation TextInputSystemActionLabel
- (void)performSystemAction:(id __unused)sender
{}
@end

@interface UITextInputTests : XCTestCase
@end

@implementation UITextInputTests

- (void)textDidDisplayInLabel:(STULabel *)label
{
  [[label stu_textInteraction] stu_textDidDisplay];
}

- (STULabel *)labelWithAttributedText:(NSAttributedString *)text size:(CGSize)size insets:(UIEdgeInsets)insets
{
  STULabel *const label = [[STULabel alloc] initWithFrame:(CGRect){.size = size}];
  label.selectable = YES;
  label.contentInsets = insets;
  label.maximumNumberOfLines = 0;
  label.attributedText = text;
  [label layoutIfNeeded];
  (void)label.textFrame;
  [self textDidDisplayInLabel:label];
  return label;
}

- (STULabel *)labelWithText:(NSString *)text size:(CGSize)size
{
  return [self labelWithAttributedText:[[NSAttributedString alloc]
                                           initWithString:text
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]}]
                                  size:size
                                insets:UIEdgeInsetsZero];
}

- (UIContextMenuInteraction *)installedContextMenuInteractionInLabel:(STULabel *)label
{
  for (id<UIInteraction> interaction in label.interactions) {
    if ([interaction isKindOfClass:UIContextMenuInteraction.class] &&
        ((UIContextMenuInteraction *)interaction).delegate == label) {
      return (UIContextMenuInteraction *)interaction;
    }
  }
  return nil;
}

- (UITextRange *)documentRangeForInput:(id<UITextInput>)input
{
  return [input textRangeFromPosition:input.beginningOfDocument toPosition:input.endOfDocument];
}

- (CGPoint)pointInLabel:(STULabel *)label range:(NSRange)range
{
  STUTextFrame *const textFrame = label.textFrame;
  STUTextRectArray *const rects = [textFrame rectsForRange:[textFrame rangeForRangeInTruncatedString:range]
                                               frameOrigin:label.textFrameOrigin
                                              displayScale:label.layer.contentsScale];
  XCTAssertGreaterThan(rects.rectCount, 0u);
  const CGRect rect = [rects rectAtIndex:0];
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (void)testConformanceAndNonEditableInteraction
{
  STULabel *const label = [self labelWithText:@"text" size:CGSizeMake(200, 50)];
  XCTAssertTrue([label conformsToProtocol:@protocol(UITextInput)]);
  XCTAssertTrue(label.isSelectable);

  STULabelTextInteraction *const controller = label.stu_textInteraction;
  UITextInteraction *const interaction = controller.stu_interaction;
  XCTAssertTrue([label.interactions containsObject:interaction]);
  XCTAssertEqual(interaction.view, label);
  XCTAssertTrue([interaction.delegate isKindOfClass:STULabelTextInteraction.class]);
  XCTAssertEqual(interaction.delegate, controller);
  XCTAssertEqual(interaction.textInput, label);
  XCTAssertEqual(interaction.textInteractionMode, UITextInteractionModeNonEditable);
  XCTAssertTrue(label.canBecomeFirstResponder);
}

- (void)testSelectableControlsInteractionInstallation
{
  STULabel *const label = [[STULabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
  XCTAssertFalse(label.isSelectable);

  STULabelTextInteraction *const controller = label.stu_textInteraction;
  UITextInteraction *const interaction = controller.stu_interaction;
  XCTAssertFalse([label.interactions containsObject:interaction]);
  XCTAssertNil(interaction.view);

  label.selectable = YES;
  XCTAssertTrue([label.interactions containsObject:interaction]);
  XCTAssertEqual(interaction.view, label);

  label.selectable = NO;
  XCTAssertFalse([label.interactions containsObject:interaction]);
  XCTAssertNil(interaction.view);
}

- (void)testPositionsAndRangesHaveValueSemantics
{
  STULabel *const firstLabel = [self labelWithText:@"text" size:CGSizeMake(200, 50)];
  STULabel *const secondLabel = [self labelWithText:@"text" size:CGSizeMake(200, 50)];
  id<UITextInput> const firstInput = (id<UITextInput>)firstLabel;
  id<UITextInput> const secondInput = (id<UITextInput>)secondLabel;

  UITextPosition *const firstPosition = firstInput.beginningOfDocument;
  UITextPosition *const equivalentPosition = firstInput.beginningOfDocument;
  UITextPosition *const secondLabelPosition = secondInput.beginningOfDocument;
  XCTAssertEqualObjects(firstPosition, equivalentPosition);
  XCTAssertEqualObjects(firstPosition, secondLabelPosition);
  XCTAssertEqual(firstPosition.hash, equivalentPosition.hash);

  UITextRange *const firstRange = [firstInput textRangeFromPosition:firstPosition toPosition:firstInput.endOfDocument];
  UITextRange *const equivalentRange = [firstInput textRangeFromPosition:equivalentPosition
                                                              toPosition:firstInput.endOfDocument];
  XCTAssertEqualObjects(firstRange, equivalentRange);
  XCTAssertEqual(firstRange.hash, equivalentRange.hash);
}

- (void)testRangesNormalizeReversedEndpointsForSelectionHandleUpdates
{
  STULabel *const label = [self labelWithText:@"first second" size:CGSizeMake(200, 50)];
  id<UITextInput> const input = (id<UITextInput>)label;
  UITextPosition *const lower = [input positionFromPosition:input.beginningOfDocument offset:2];
  UITextPosition *const upper = [input positionFromPosition:input.beginningOfDocument offset:8];

  UITextRange *const range = [input textRangeFromPosition:upper toPosition:lower];

  XCTAssertNotNil(range);
  XCTAssertEqualObjects([input textInRange:range], @"rst se");
  XCTAssertEqual([input comparePosition:range.start toPosition:lower], NSOrderedSame);
  XCTAssertEqual([input comparePosition:range.end toPosition:upper], NSOrderedSame);
  input.selectedTextRange = range;
  XCTAssertEqualObjects(input.selectedTextRange, range);
}

- (void)testVisibleStringPositionsUseUTF16Offsets
{
  STULabel *const label = [self labelWithText:@"A👩‍💻B" size:CGSizeMake(200, 50)];
  id<UITextInput> const input = (id<UITextInput>)label;
  UITextPosition *const begin = input.beginningOfDocument;
  UITextPosition *const afterA = [input positionFromPosition:begin offset:1];
  UITextPosition *const insideEmoji = [input positionFromPosition:afterA offset:1];
  UITextPosition *const afterEmoji = [input positionFromPosition:begin offset:6];
  UITextPosition *const end = input.endOfDocument;

  XCTAssertEqual([input offsetFromPosition:begin toPosition:afterA], 1);
  XCTAssertNotNil(insideEmoji);
  XCTAssertEqual([input offsetFromPosition:begin toPosition:insideEmoji], 2);
  XCTAssertEqual([input offsetFromPosition:afterA toPosition:afterEmoji], 5);
  XCTAssertEqual([input offsetFromPosition:afterEmoji toPosition:end], 1);
  UITextRange *const emojiRange = [input textRangeFromPosition:afterA toPosition:afterEmoji];
  XCTAssertEqualObjects([input textInRange:emojiRange], @"👩‍💻");
  XCTAssertEqualObjects([input positionWithinRange:[self documentRangeForInput:input] atCharacterOffset:2],
                        insideEmoji);
  XCTAssertEqual([input characterOffsetOfPosition:insideEmoji withinRange:[self documentRangeForInput:input]], 2);
  XCTAssertNil([input positionFromPosition:begin offset:-1]);
  XCTAssertNil([input positionFromPosition:end offset:1]);
}

- (void)testMultilineGeometryHitTestingAndTokenizer
{
  STULabel *const label =
      [self labelWithAttributedText:[[NSAttributedString alloc]
                                        initWithString:@"first second third fourth fifth"
                                            attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]}]
                               size:CGSizeMake(105, 130)
                             insets:UIEdgeInsetsMake(7, 11, 5, 3)];
  id<UITextInput> const input = (id<UITextInput>)label;
  UITextRange *const documentRange = [self documentRangeForInput:input];
  NSArray<UITextSelectionRect *> *const selectionRects = [input selectionRectsForRange:documentRange];
  XCTAssertGreaterThanOrEqual(selectionRects.count, 2u);
  XCTAssertGreaterThanOrEqual(CGRectGetMinX(selectionRects.firstObject.rect), label.textFrameOrigin.x);
  XCTAssertGreaterThanOrEqual(CGRectGetMinY(selectionRects.firstObject.rect), label.textFrameOrigin.y);

  const CGPoint point = [self pointInLabel:label range:NSMakeRange(0, 1)];
  UITextRange *const hitRange = [input characterRangeAtPoint:point];
  XCTAssertEqualObjects([input textInRange:hitRange], @"f");

  UITextRange *const wordRange =
      [input.tokenizer rangeEnclosingPosition:input.beginningOfDocument
                              withGranularity:UITextGranularityWord
                                  inDirection:(UITextDirection)UITextStorageDirectionForward];
  XCTAssertEqualObjects([input textInRange:wordRange], @"first");

  UITextPosition *const nextLine = [input positionFromPosition:input.beginningOfDocument
                                                   inDirection:UITextLayoutDirectionDown
                                                        offset:1];
  XCTAssertNotNil(nextLine);
  XCTAssertGreaterThan([input offsetFromPosition:input.beginningOfDocument toPosition:nextLine], 0);
}

- (void)testRTLSelectionRectUsesRTLWritingDirection
{
  STULabel *const label = [self labelWithText:@"שלום עולם" size:CGSizeMake(200, 50)];
  label.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
  (void)label.textFrame;
  [self textDidDisplayInLabel:label];
  id<UITextInput> const input = (id<UITextInput>)label;
  UITextPosition *const end = input.endOfDocument;
  UITextPosition *const beforeEnd = [input positionFromPosition:end offset:-1];
  UITextRange *const range = [input textRangeFromPosition:beforeEnd toPosition:end];
  UITextSelectionRect *const rect = [input selectionRectsForRange:range].firstObject;
  XCTAssertNotNil(rect);
  XCTAssertEqual(rect.writingDirection, NSWritingDirectionRightToLeft);
  XCTAssertTrue(CGAffineTransformIsIdentity(rect.transform));
  XCTAssertEqual([input baseWritingDirectionForPosition:beforeEnd inDirection:UITextStorageDirectionBackward],
                 NSWritingDirectionRightToLeft);
}

- (void)testVisibleTruncationIsTheOnlyCopyableText
{
  STULabel *const label = [self labelWithText:@"abcdefghijklmnopqrst" size:CGSizeMake(62, 50)];
  label.maximumNumberOfLines = 1;
  label.lastLineTruncationMode = STULastLineTruncationModeEnd;
  (void)label.textFrame;
  [self textDidDisplayInLabel:label];
  id<UITextInput> const input = (id<UITextInput>)label;
  NSString *const visibleString = label.textFrame.truncatedAttributedString.string;
  XCTAssertNotEqualObjects(visibleString, label.text);
  XCTAssertEqualObjects([input textInRange:[self documentRangeForInput:input]], visibleString);

  [label selectAll:nil];
  XCTAssertTrue([label canPerformAction:@selector(copy:) withSender:nil]);
  [label copy:nil];
  XCTAssertEqualObjects(UIPasteboard.generalPasteboard.string, visibleString);
}

- (void)testTruncationTokenLinkCannotBeSelected
{
  const UIFont *const font = [UIFont systemFontOfSize:18];
  NSMutableAttributedString *const token =
      [[NSMutableAttributedString alloc] initWithString:@"… more" attributes:@{NSFontAttributeName : font}];
  [token addAttribute:NSLinkAttributeName value:@"more" range:NSMakeRange(2, 4)];
  STULabel *const label =
      [self labelWithAttributedText:[[NSAttributedString alloc] initWithString:@"A long sentence that needs truncation."
                                                                    attributes:@{NSFontAttributeName : font}]
                               size:CGSizeMake(120, 50)
                             insets:UIEdgeInsetsZero];
  label.maximumNumberOfLines = 1;
  label.truncationToken = token;
  (void)label.textFrame;
  [self textDidDisplayInLabel:label];

  XCTAssertEqual(label.links.count, 1u);
  STUTextLink *const link = label.links[0];
  id<UITextInput> const input = (id<UITextInput>)label;
  UITextInteraction *const interaction = label.textInteraction;
  XCTAssertFalse([interaction.delegate interactionShouldBegin:interaction
                                                      atPoint:[self pointInLabel:label
                                                                           range:link.rangeInTruncatedString]]);
  input.selectedTextRange = [self documentRangeForInput:input];
  UITextRange *const selection = input.selectedTextRange;
  XCTAssertNotNil(selection);
  XCTAssertEqual([input offsetFromPosition:input.beginningOfDocument toPosition:selection.end],
                 (NSInteger)link.rangeInTruncatedString.location);
  XCTAssertEqualObjects(
      [input textInRange:selection],
      [label.textFrame.truncatedAttributedString.string substringToIndex:link.rangeInTruncatedString.location]);

  UITextPosition *const linkStart = [input positionFromPosition:input.beginningOfDocument
                                                         offset:(NSInteger)link.rangeInTruncatedString.location];
  UITextPosition *const linkEnd = [input positionFromPosition:linkStart
                                                       offset:(NSInteger)link.rangeInTruncatedString.length];
  input.selectedTextRange = [input textRangeFromPosition:linkStart toPosition:linkEnd];
  XCTAssertNil(input.selectedTextRange);
}

- (void)testEditingAndMarkedTextOperationsAreNoOps
{
  STULabel *const label = [self labelWithText:@"unchanged" size:CGSizeMake(200, 50)];
  id<UITextInput> const input = (id<UITextInput>)label;
  UITextRange *const range = [self documentRangeForInput:input];

  [input insertText:@"x"];
  [input deleteBackward];
  [input replaceRange:range withText:@"replacement"];
  [input setMarkedText:@"marked" selectedRange:NSMakeRange(0, 1)];
  [input unmarkText];
  XCTAssertEqualObjects(label.text, @"unchanged");
  XCTAssertNil(input.markedTextRange);
  XCTAssertFalse([label canPerformAction:@selector(cut:) withSender:nil]);
  XCTAssertFalse([label canPerformAction:@selector(paste:) withSender:nil]);
  XCTAssertFalse([input shouldChangeTextInRange:range replacementText:@"replacement"]);

  XCTAssertFalse([(id)label isEditable]);
}

- (void)testSystemOwnedMenuActionsUseResponderValidation
{
  TextInputSystemActionLabel *const label =
      [[TextInputSystemActionLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
  label.selectable = YES;
  label.text = @"text";

  XCTAssertTrue([label canPerformAction:@selector(performSystemAction:) withSender:nil]);
  XCTAssertFalse([label canPerformAction:@selector(cut:) withSender:nil]);
  XCTAssertFalse([label canPerformAction:@selector(paste:) withSender:nil]);
  XCTAssertFalse([label canPerformAction:@selector(delete:) withSender:nil]);
}

- (void)testVisibleTextChangeNotifiesInputDelegateAndInvalidatesSelection
{
  STULabel *const label = [self labelWithText:@"before" size:CGSizeMake(200, 50)];
  id<UITextInput> const input = (id<UITextInput>)label;
  TextInputDelegateRecorder *const recorder = [[TextInputDelegateRecorder alloc] init];
  input.inputDelegate = recorder;
  input.selectedTextRange = [self documentRangeForInput:input];
  recorder.selectionWillChangeCount = 0;
  recorder.selectionDidChangeCount = 0;

  label.text = @"after";
  (void)label.textFrame;
  [self textDidDisplayInLabel:label];

  XCTAssertEqual(recorder.textWillChangeCount, 1u);
  XCTAssertEqual(recorder.textDidChangeCount, 1u);
  XCTAssertEqual(recorder.selectionWillChangeCount, 1u);
  XCTAssertEqual(recorder.selectionDidChangeCount, 1u);
  XCTAssertNil(input.selectedTextRange);
}

- (void)testLinksRetainTextInteractionPrecedence
{
  NSMutableAttributedString *const text =
      [[NSMutableAttributedString alloc] initWithString:@"link plain text"
                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]}];
  [text addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@"https://example.com"] range:NSMakeRange(0, 4)];
  STULabel *const label = [self labelWithAttributedText:text size:CGSizeMake(250, 50) insets:UIEdgeInsetsZero];
  UITextInteraction *const interaction = label.textInteraction;
  id<UITextInteractionDelegate> const delegate = interaction.delegate;
  XCTAssertTrue([(id)delegate isKindOfClass:STULabelTextInteraction.class]);
  XCTAssertFalse([delegate interactionShouldBegin:interaction
                                          atPoint:[self pointInLabel:label range:NSMakeRange(0, 4)]]);
  XCTAssertTrue([delegate interactionShouldBegin:interaction
                                         atPoint:[self pointInLabel:label range:NSMakeRange(5, 5)]]);
}

- (void)testContextMenuInteractionIsInstalledOnlyForCapableDelegate
{
  NSMutableAttributedString *const text =
      [[NSMutableAttributedString alloc] initWithString:@"link plain text"
                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]}];
  [text addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@"https://example.com"] range:NSMakeRange(0, 4)];
  STULabel *const label = [self labelWithAttributedText:text size:CGSizeMake(250, 50) insets:UIEdgeInsetsZero];

  [label labelLayer:label.layer didDisplayTextWithFlags:STUTextFrameHasLink inRect:label.bounds];
  XCTAssertNil([self installedContextMenuInteractionInLabel:label]);

  ContextMenuDelegateRecorder *const recorder = [[ContextMenuDelegateRecorder alloc] init];
  label.delegate = recorder;
  UIContextMenuInteraction *const interaction = [self installedContextMenuInteractionInLabel:label];
  XCTAssertNotNil(interaction);
  XCTAssertEqual(interaction.view, label);
  XCTAssertEqual(interaction.delegate, label);
}

- (void)testLinkContextMenuInteractionInstallationAndDelegateForwarding
{
  NSMutableAttributedString *const text =
      [[NSMutableAttributedString alloc] initWithString:@"link plain text"
                                             attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]}];
  [text addAttribute:NSLinkAttributeName value:[NSURL URLWithString:@"https://example.com"] range:NSMakeRange(0, 4)];
  STULabel *const label = [self labelWithAttributedText:text size:CGSizeMake(250, 50) insets:UIEdgeInsetsZero];
  UIContextMenuInteraction *const interaction = label.contextMenuInteraction;
  XCTAssertTrue([label.interactions containsObject:interaction]);
  XCTAssertEqual(interaction.view, label);
  XCTAssertEqual(interaction.delegate, label);

  const CGPoint linkPoint = [self pointInLabel:label range:NSMakeRange(0, 4)];
  XCTAssertNil([label contextMenuInteraction:interaction configurationForMenuAtLocation:linkPoint]);

  ContextMenuDelegateRecorder *const recorder = [[ContextMenuDelegateRecorder alloc] init];
  UIContextMenuConfiguration *const configuration = [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                                                            previewProvider:nil
                                                                                             actionProvider:nil];
  recorder.configuration = configuration;
  label.delegate = recorder;

  XCTAssertEqual([label contextMenuInteraction:interaction configurationForMenuAtLocation:linkPoint], configuration);
  XCTAssertEqual(recorder.callCount, 1u);
  XCTAssertEqual(recorder.lastLabel, label);
  XCTAssertEqual(recorder.lastLink, label.links[0]);
  XCTAssertTrue(CGPointEqualToPoint(recorder.lastLocation, linkPoint));

  XCTAssertNil([label contextMenuInteraction:interaction configurationForMenuAtLocation:CGPointMake(-100, -100)]);
  XCTAssertEqual(recorder.callCount, 1u);

  recorder.configuration = nil;
  XCTAssertNil([label contextMenuInteraction:interaction configurationForMenuAtLocation:linkPoint]);
  XCTAssertEqual(recorder.callCount, 2u);

  label.delegate = nil;
  XCTAssertNil([label contextMenuInteraction:interaction configurationForMenuAtLocation:linkPoint]);
  XCTAssertEqual(recorder.callCount, 2u);
}

- (void)testAccessibilityElementDoesNotRetainLabel
{
  __weak STULabel *weakLabel;
  @autoreleasepool {
    STULabel *const label = [[STULabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    label.text = @"Accessible text";
    XCTAssertNotNil(label.accessibilityElements);
    weakLabel = label;
  }
  XCTAssertNil(weakLabel);
}

@end
