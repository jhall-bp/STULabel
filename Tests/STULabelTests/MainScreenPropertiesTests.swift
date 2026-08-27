// Copyright 2018 Stephan Tolksdorf

import STULabel.MainScreenProperties
import Testing

@MainActor
struct MainScreenPropertiesTests {
  @Test
  func `Display scale for trait collection`() {
    let traitCollection = UITraitCollection(displayScale: 2)
    #expect(stu_displayScaleForTraitCollection(traitCollection) == 2)
  }

  @Test
  func `Display gamut for trait collection`() {
    let traitCollection = UITraitCollection(displayGamut: .P3)
    #expect(stu_displayGamutForTraitCollection(traitCollection) == .P3)
  }

}
