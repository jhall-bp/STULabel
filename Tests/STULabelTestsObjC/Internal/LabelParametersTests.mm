#import "LabelParameters.hpp"

#import "TestUtils.h"

using namespace stu_label;

@interface LabelParametersTests : XCTestCase
@end

@implementation LabelParametersTests

- (void)testOversizedInsetsDoNotDependOnPreviousInsets
{
  for (CGFloat previousLeft : {CGFloat{0}, CGFloat{10}, CGFloat{40}}) {
    LabelParameters parameters{};
    parameters.setSize_afterBaseAssignment_alreadyCeiledToScale(CGSizeMake(100, 100));
    parameters.setEdgeInsets(UIEdgeInsetsMake(0, previousLeft, 0, 0));
    parameters.setEdgeInsets(UIEdgeInsetsMake(0, 80, 0, 80));
    XCTAssertEqual(parameters.edgeInsets().left, 50);
    XCTAssertEqual(parameters.edgeInsets().right, 50);
    XCTAssertEqual(parameters.maxTextFrameSize().width, 0);
  }
}

- (void)testSizeChangeStatusComparesWithPreviousSize
{
  LabelParameters parameters{};
  parameters.setSize_afterBaseAssignment_alreadyCeiledToScale(CGSizeMake(100, 100));
  XCTAssertEqual(parameters.setSizeAndEdgeInsets(CGSizeMake(120, 100), UIEdgeInsetsZero),
                 LabelParameterChangeStatus::sizeChanged);
  XCTAssertTrue(CGSizeEqualToSize(parameters.size(), CGSizeMake(120, 100)));
  XCTAssertEqual(parameters.setSizeAndEdgeInsets(CGSizeMake(120, 100), UIEdgeInsetsZero),
                 LabelParameterChangeStatus::noChange);
}

@end
