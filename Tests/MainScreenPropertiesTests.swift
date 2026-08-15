// Copyright 2018 Stephan Tolksdorf

import STULabel.MainScreenProperties

import XCTest

class MainScreenPropertiesTests: XCTestCase {

  func testDisplayScaleForTraitCollection() {
    let traitCollection = UITraitCollection(displayScale: 2)
    XCTAssertEqual(stu_displayScaleForTraitCollection(traitCollection), 2)
  }

  func testDisplayGamutForTraitCollection() {
    let traitCollection = UITraitCollection(displayGamut: .P3)
    XCTAssertEqual(stu_displayGamutForTraitCollection(traitCollection), .P3)
  }

}
