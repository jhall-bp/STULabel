// Copyright 2026 Stephan Tolksdorf

#import "STULabel/STULabel.h"

#import <XCTest/XCTest.h>

@interface PrerendererTraitTests : XCTestCase
@end

@implementation PrerendererTraitTests

- (void)setUp
{
  [super setUp];
  self.continueAfterFailure = false;
}

- (void)testTargetTraitsAreCurrentWhenShapingAndRendering
{
  UITraitCollection *const targetTraits =
      [UITraitCollection traitCollectionWithTraits:^(id<UIMutableTraits> traits) {
        traits.userInterfaceStyle = UIUserInterfaceStyleDark;
        traits.preferredContentSizeCategory = UIContentSizeCategoryAccessibilityLarge;
      }];
  UITraitCollection *const outerTraits =
      [UITraitCollection traitCollectionWithTraits:^(id<UIMutableTraits> traits) {
        traits.userInterfaceStyle = UIUserInterfaceStyleLight;
        traits.preferredContentSizeCategory = UIContentSizeCategorySmall;
      }];

  __block UIUserInterfaceStyle shapingStyle = UIUserInterfaceStyleUnspecified;
  __block UIContentSizeCategory shapingContentSizeCategory;
  UIColor *const attributedColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
    shapingStyle = traits.userInterfaceStyle;
    shapingContentSizeCategory = traits.preferredContentSizeCategory;
    return UIColor.whiteColor;
  }];
  __block UIUserInterfaceStyle renderingStyle = UIUserInterfaceStyleUnspecified;
  __block UIContentSizeCategory renderingContentSizeCategory;
  UIColor *const overrideColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
    renderingStyle = traits.userInterfaceStyle;
    renderingContentSizeCategory = traits.preferredContentSizeCategory;
    return UIColor.whiteColor;
  }];
  __block UIContentSizeCategory layoutContentSizeCategory;
  UIColor *const truncationTokenColor =
      [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
        layoutContentSizeCategory = traits.preferredContentSizeCategory;
        return UIColor.whiteColor;
      }];

  STULabelPrerenderer *const prerenderer =
      [[STULabelPrerenderer alloc] initWithTraitCollection:targetTraits];
  [prerenderer setSize:CGSize{50, 30} contentInsets:UIEdgeInsetsZero options:0];
  prerenderer.attributedText =
      [[NSAttributedString alloc] initWithString:@"This text must be truncated"
                                      attributes:@{NSForegroundColorAttributeName: attributedColor}];
  prerenderer.maximumNumberOfLines = 1;
  prerenderer.truncationToken =
      [[NSAttributedString alloc] initWithString:@"…"
                                      attributes:@{NSForegroundColorAttributeName: truncationTokenColor}];
  prerenderer.overrideTextColor = overrideColor;

  dispatch_queue_t const queue = dispatch_queue_create("STULabel.PrerendererTraitTests", nullptr);
  [outerTraits performAsCurrentTraitCollection:^{
    [prerenderer renderUsingScheduler:^(void *context, void (*function)(void *)) {
      dispatch_sync_f(queue, context, function);
    }];
  }];

  XCTAssertEqual(shapingStyle, UIUserInterfaceStyleDark);
  XCTAssertEqualObjects(shapingContentSizeCategory, UIContentSizeCategoryAccessibilityLarge);
  XCTAssertEqualObjects(layoutContentSizeCategory, UIContentSizeCategoryAccessibilityLarge);
  XCTAssertEqual(renderingStyle, UIUserInterfaceStyleDark);
  XCTAssertEqualObjects(renderingContentSizeCategory, UIContentSizeCategoryAccessibilityLarge);
}

- (void)testLabelRerendersPrerenderedContentForDifferentTraits
{
  STULabel *const label = [[STULabel alloc] initWithFrame:CGRect{CGPointZero, {200, 50}}];
  label.traitOverrides.preferredContentSizeCategory = UIContentSizeCategorySmall;
  [label updateTraitsIfNeeded];
  [label.layer displayIfNeeded];

  UITraitCollection *const prerendererTraits =
      [label.traitCollection traitCollectionByModifyingTraits:^(id<UIMutableTraits> traits) {
        traits.preferredContentSizeCategory = UIContentSizeCategoryAccessibilityLarge;
      }];
  __block UIContentSizeCategory renderingContentSizeCategory;
  UIColor *const color = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
    renderingContentSizeCategory = traits.preferredContentSizeCategory;
    const bool isAccessibilityLarge = [traits.preferredContentSizeCategory
        isEqualToString:UIContentSizeCategoryAccessibilityLarge];
    return isAccessibilityLarge ? UIColor.whiteColor : UIColor.blackColor;
  }];

  STULabelPrerenderer *const prerenderer =
      [[STULabelPrerenderer alloc] initWithTraitCollection:prerendererTraits];
  [prerenderer setSize:label.bounds.size contentInsets:UIEdgeInsetsZero options:0];
  prerenderer.attributedText =
      [[NSAttributedString alloc] initWithString:@"Test"
                                      attributes:@{NSForegroundColorAttributeName: color}];
  [prerenderer render];
  XCTAssertEqualObjects(renderingContentSizeCategory, UIContentSizeCategoryAccessibilityLarge);

  renderingContentSizeCategory = nil;
  [label configureWithPrerenderer:prerenderer];
  XCTAssertTrue(label.layer.needsDisplay);
  [label.layer displayIfNeeded];
  XCTAssertEqualObjects(renderingContentSizeCategory, UIContentSizeCategorySmall);
}

@end
