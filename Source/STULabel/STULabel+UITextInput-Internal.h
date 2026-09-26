// Copyright 2026 Stephan Tolksdorf

#import "STULabel+UITextInput.h"

#import <UIKit/UITextInteraction.h>

@class STULabelTextInputRange;

STULabelTextInputRange *__nonnull STULabelTextInputRangeForLink(STUTextLink *__nonnull link);

@class STULabelTextInputDocument;

/// Owns a label's UIKit text interaction and the mutable state required by its UITextInput
/// conformance. UITextInteraction's public factory always returns UIKit's concrete class, so
/// this object is its delegate and controller rather than an unsupported subclass.
@interface STULabelTextInteraction : NSObject <UITextInteractionDelegate>

@property (nonatomic, readonly) UITextInteraction *stu_interaction;
@property (nonatomic, weak, nullable) id<UITextInputDelegate> stu_inputDelegate;
@property (nonatomic, strong, nullable) UITextInputStringTokenizer *stu_tokenizer;
@property (nonatomic, strong, nullable) STULabelTextInputDocument *stu_document;
@property (nonatomic) bool stu_isPublishingDocument;
@property (nonatomic) UITextStorageDirection stu_selectionAffinity;

- (instancetype)initWithLabel:(STULabel *)label;
- (void)stu_invalidate;
- (void)stu_textDidDisplay;

@end

@interface STULabel (UITextInput_Internal)

- (STULabelTextInteraction *)stu_textInteraction;

@end
