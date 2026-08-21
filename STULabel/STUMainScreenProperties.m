// Copyright 2016–2018 Stephan Tolksdorf

#import "STUMainScreenProperties.h"

STU_EXPORT
CGFloat stu_displayScaleForTraitCollection(UITraitCollection *traitCollection) {
  return traitCollection.displayScale;
}

STU_EXPORT
STUDisplayGamut stu_displayGamutForTraitCollection(UITraitCollection *traitCollection) {
  return (STUDisplayGamut)traitCollection.displayGamut;
}
