// Copyright 2026 Stephan Tolksdorf

#import "STULabel.h"

#import <UIKit/UITextInput.h>

STU_ASSUME_NONNULL_AND_STRONG_BEGIN

/// Enables native, non-editable text selection for @c STULabel on iOS 13 and later.
///
/// The text exposed through @c UITextInput is the label's currently displayed, possibly
/// truncated string. Editing operations are not supported.
STU_EXPORT
@interface STULabel (UITextInput) <UITextInput>

/// The lazily created non-editable text interaction used by the label.
@property (nonatomic, readonly) UITextInteraction* textInteraction API_AVAILABLE(ios(13.0));

@end

STU_ASSUME_NONNULL_AND_STRONG_END
