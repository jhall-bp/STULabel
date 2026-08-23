// Copyright 2026 Stephan Tolksdorf

#import "STULabel+UITextInput.h"

#import <UIKit/UITextInteraction.h>

/// Owns a label's UIKit text interaction and the mutable state required by its UITextInput
/// conformance. UITextInteraction's public factory always returns UIKit's concrete class, so
/// this object is its delegate and controller rather than an unsupported subclass.
@interface STULabelTextInteraction : NSObject <UITextInteractionDelegate> {
@private
  __weak STULabel *_label;
  UITextInteraction *_interaction;
  __weak id<UITextInputDelegate> _stu_inputDelegate;
  UITextRange *_stu_selectedTextRange;
  UITextInputStringTokenizer *_stu_tokenizer;
  NSString *_stu_displayedString;
  UITextStorageDirection _stu_selectionAffinity;
}

@property (nonatomic, readonly) UITextInteraction *stu_interaction;
@property (nonatomic, weak, nullable) id<UITextInputDelegate> stu_inputDelegate;
@property (nonatomic, strong, nullable) UITextRange *stu_selectedTextRange;
@property (nonatomic, strong, nullable) UITextInputStringTokenizer *stu_tokenizer;
@property (nonatomic, copy, nullable) NSString *stu_displayedString;
@property (nonatomic) UITextStorageDirection stu_selectionAffinity;

- (instancetype)initWithLabel:(STULabel *)label;
- (void)stu_invalidate;
- (void)stu_textDidDisplay;

@end

@interface STULabel (UITextInput_Internal)

- (STULabelTextInteraction *)stu_textInteraction;

@end
