#import "STULabelGhostingMaskLayer.h"
#import "STULabel/STULabel.h"

#import <XCTest/XCTest.h>

@interface GhostingMaskLayerTests : XCTestCase
@end

@implementation GhostingMaskLayerTests

- (void)testGhostedLinksSurviveRelayoutAndTemporaryRemoval
{
  STULabel *const label = [[STULabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
  label.attributedText = [[NSAttributedString alloc]
      initWithString:@"Link"
          attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18],
                       NSLinkAttributeName: @"details"}];
  STUTextLinkArray *const links = label.links;
  XCTAssertEqual(links.count, 1u);
  STUTextLink *const link = links[0];
  STULabelGhostingMaskLayer *const mask = [[STULabelGhostingMaskLayer alloc] init];
  [mask setMaskedLayerFrame:label.bounds links:links];
  [mask ghostLink:link];

  [mask setMaskedLayerFrame:CGRectMake(0, 0, 120, 100) links:links];
  XCTAssertTrue([mask hasGhostedLink:link]);
  XCTAssertTrue([mask unghostLink:link]);
  XCTAssertFalse([mask hasGhostedLink:link]);

  [mask ghostLink:link];
  [mask setMaskedLayerFrame:label.bounds links:STUTextLinkArray.emptyArray];
  const bool remainsGhosted = [mask hasGhostedLink:link];
  XCTAssertTrue(remainsGhosted);
  if (!remainsGhosted) {
    return;
  }
  [mask setMaskedLayerFrame:label.bounds links:links];
  XCTAssertTrue([mask hasGhostedLink:link]);
  XCTAssertTrue([mask unghostLink:link]);
  XCTAssertFalse([mask hasGhostedLink:link]);
}

@end
