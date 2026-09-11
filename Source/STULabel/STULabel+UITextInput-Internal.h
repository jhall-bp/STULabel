// Copyright 2026 Stephan Tolksdorf

#import "STULabel+UITextInput.h"

#import <UIKit/UITextInteraction.h>

@class STULabelTextInputDocument;

/// Owns a label's UIKit text interaction and the mutable state required by its UITextInput
/// conformance. UITextInteraction's public factory always returns UIKit's concrete class, so
/// this object is its delegate and controller rather than an unsupported subclass.
@interface STULabelTextInteraction : NSObject <UITextInteractionDelegate> {
@private
  __weak STULabel *_label;
  UITextInteraction *_interaction;
  __weak id<UITextInputDelegate> _stu_inputDelegate;
  UITextInputStringTokenizer *_stu_tokenizer;
  STULabelTextInputDocument *_stu_document;
  bool _stu_isPublishingDocument;
  UITextStorageDirection _stu_selectionAffinity;
}

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
