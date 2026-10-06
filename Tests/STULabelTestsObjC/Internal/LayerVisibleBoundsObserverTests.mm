#import "LayerVisibleBoundsObserver.hpp"

#import "TestUtils.h"

using namespace stu_label;

@interface LayerVisibleBoundsObserverTests : XCTestCase
@end

@implementation LayerVisibleBoundsObserverTests

- (void)testNestedClippingUsesEachLayersCoordinateSpace
{
  CALayer *root = [CALayer layer];
  root.bounds = CGRectMake(0, 0, 100, 100);
  CALayer *clip = [CALayer layer];
  clip.frame = CGRectMake(80, 70, 100, 80);
  clip.masksToBounds = YES;
  [root addSublayer:clip];
  CALayer *child = [CALayer layer];
  child.frame = CGRectMake(10, 20, 200, 200);
  [clip addSublayer:child];

  LayerVisibleBoundsObserver observer{};
  observer.setLayer(child);
  const CGRect visibleBounds = observer.calculateVisibleBounds();
  XCTAssertTrue(CGRectEqualToRect(visibleBounds, CGRectMake(-10, -20, 20, 30)));
  XCTAssertEqual(observer.areaScale(), 1);
}

- (void)testMovingSuperlayerInvalidatesVisibleBounds
{
  CALayer *root = [CALayer layer];
  root.bounds = CGRectMake(0, 0, 100, 100);
  CALayer *clip = [CALayer layer];
  clip.frame = CGRectMake(10, 20, 80, 60);
  clip.masksToBounds = YES;
  [root addSublayer:clip];
  CALayer *child = [CALayer layer];
  [clip addSublayer:child];

  LayerVisibleBoundsObserver observer{};
  observer.setLayer(child);
  __block NSUInteger notificationCount = 0;
  observer.setOnVisibleBoundsMayHaveChangedCallback(^{
    ++notificationCount;
  });
  observer.calculateVisibleBounds();
  clip.position = CGPointMake(60, 50);
  XCTAssertEqual(notificationCount, 1u);
  clip.position = CGPointMake(70, 50);
  XCTAssertEqual(notificationCount, 1u);
  observer.calculateVisibleBounds();
  clip.position = CGPointMake(80, 50);
  XCTAssertEqual(notificationCount, 2u);
}

@end
