// Copyright 2017–2018 Stephan Tolksdorf

#import "STUTextHighlightStyle.h"

#import "Internal/TextStyle.hpp"

@interface STUTextHighlightStyle (Internal)

- (stu_label::TextHighlightStyle)stu_resolvedStyle;

@end
