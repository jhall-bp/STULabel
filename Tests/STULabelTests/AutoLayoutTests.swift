// Copyright 2018 Stephan Tolksdorf

import STULabelSwift

import Foundation
import SnapshotTesting
import Testing

@MainActor
struct AutoLayoutTests {
  func newView(_ name: String) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.accessibilityIdentifier = name
    return view
  }

  func newContainer(_ suffix: String = "") -> UIView {
    let container = newView("container" + suffix)
    [constrain(container, .width, eq, 0, priority: .fittingSizeLevel),
     constrain(container, .height, eq, 0, priority: .fittingSizeLevel)].activate()
    return container
  }

  func newLabel(_ suffix: String = "") -> STULabel {
    let label = STULabel()
    label.textLayoutMode = .textKit
    label.maximumNumberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    label.accessibilityIdentifier = "label" + suffix
    return label
  }

  func font(size: CGFloat) -> UIFont {
    return UIFont(name: "HelveticaNeue", size: size)!
  }

  @Test
  func `Content layout guide`() {
    let label = newLabel()
    label.font = font(size: 20)
    label.text = "Lj"
    label.contentInsets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)

    let overlay = newView("contentOverlay")
    label.addSubview(overlay)

    overlay.backgroundColor = UIColor.orange.withAlphaComponent(0.25)
    constrain(overlay, toEdgesOf: label.contentLayoutGuide).activate()

    assertSnapshot(of: label, as: .image)

    label.contentInsets = UIEdgeInsets(top: 4, left: 3, bottom: 2, right: 1)
    assertSnapshot(of: label, as: .image)
  }

  @Test
  func `Baseline anchors`() {
    let container = newContainer()
    let labelA = newLabel("A")
    let labelB = newLabel("B")
    container.addSubview(labelA)
    container.addSubview(labelB)

    labelA.attributedText = NSAttributedString([("Lj 1A\n", [.font: font(size: 36)]),
                                                ("Lj 2A", [.font: font(size: 20)])])

    labelB.attributedText = NSAttributedString([("Lj 1B\n", [.font: font(size: 11.6)]),
                                                ("Lj 2B", [.font: font(size: 23)])])

    var cs = [NSLayoutConstraint]()
    constrain(&cs, labelA, within: container)
    constrain(&cs, labelB, within: container)
    constrain(&cs, labelA, .right, eq, labelB, .left, plus: -20)
    constrain(&cs, labelA, .top, eq, container, .top, priority: .fittingSizeLevel)

    cs.activate();

    {
      let c = constrain(labelA, .lastBaseline, eq, labelB, .firstBaseline)
      c.isActive = true
      assertSnapshot(of: container, as: .image, named: "last_first")
      c.isActive = false
    }()

    let c = NSLayoutConstraint(item: labelA, attribute: .lastBaseline, relatedBy: .equal,
                               toItem: labelB, attribute: .firstBaseline,
                               multiplier: 1, constant: 0)
    c.isActive = true
    assertSnapshot(of: container, as: .image, named: "last_first")
    c.isActive = false

    {
      let c = constrain(labelA, .firstBaseline, eq, labelB, .lastBaseline)
      c.isActive = true
      assertSnapshot(of: container, as: .image, named: "first_last")

      swap(&labelA.attributedText, &labelB.attributedText)
      assertSnapshot(of: container, as: .image, named: "swapped_first_last")
    }()
  }

  @Test
  func `Spacing constraints`() {
    let container = newContainer()
    let labelA = newLabel("A")
    let labelB = newLabel("B")
    let labelC = newLabel("C")

    container.addSubview(labelA)
    container.addSubview(labelB)
    container.addSubview(labelC)

    var cs = [NSLayoutConstraint]()
    constrain(&cs, labelA, within: container)
    constrain(&cs, labelB, within: container)
    constrain(&cs, labelC, within: container)

    constrain(&cs, labelA, .right, eq, labelB, .left, plus: -20)
    constrain(&cs, labelB, .leading, eq, labelC, .leading)

    cs.activate()

    let c0 = constrain(labelA, .firstBaseline, eq, labelB, .firstBaseline)
    #expect(!c0.stu_isLabelSpacingConstraint)
    #expect(c0.stu_labelSpacingConstraintMultiplier == 0)
    #expect(c0.stu_labelSpacingConstraintOffset == 0)

    c0.isActive = true

    labelA.attributedText = NSAttributedString([("Lj 1A\n", [.font: font(size: 36)]),
                                                ("Lj 2A", [.font: font(size: 16)])])

    labelB.attributedText = NSAttributedString(string: "Lj 1B\n", attributes: [.font: font(size: 36)])
    labelC.attributedText = NSAttributedString(string: "Lj 1B\n", attributes: [.font: font(size: 16)])


    ({
      let c = constrain(labelB, .lastBaseline, eq, positionAbove: labelC, .firstBaseline)
      c.isActive = true
      defer { c.isActive = false }

      assertSnapshot(of: container, as: .image)

      #expect(c.stu_labelSpacingConstraintMultiplier == 1)
      c.stu_labelSpacingConstraintMultiplier = 2
      #expect(c.stu_labelSpacingConstraintMultiplier == 2)
      assertSnapshot(of: container, as: .image)

      #expect(c.stu_labelSpacingConstraintOffset == 0)
      c.stu_labelSpacingConstraintOffset = -3
      #expect(c.stu_labelSpacingConstraintOffset == -3)
      assertSnapshot(of: container, as: .image)
    }())

    ({
      let c = constrain(labelB, .lastBaseline, eq, positionAbove: labelC, .firstBaseline,
                        spacingMultipliedBy: 2, plus: -3)
      c.isActive = true
      defer { c.isActive = false }
      assertSnapshot(of: container, as: .image)
    }())

    ({
      let c = constrain(labelC, .firstBaseline, eq, positionBelow: labelB, .lastBaseline,
                        spacingMultipliedBy: 1)
      c.isActive = true
      defer { c.isActive = false }

      assertSnapshot(of: container, as: .image)

      #expect(c.stu_labelSpacingConstraintMultiplier == 1)
      c.stu_labelSpacingConstraintMultiplier = 2
      #expect(c.stu_labelSpacingConstraintMultiplier == 2)
      assertSnapshot(of: container, as: .image)

      #expect(c.stu_labelSpacingConstraintOffset == 0)
      c.stu_labelSpacingConstraintOffset = 3
      #expect(c.stu_labelSpacingConstraintOffset == 3)
      assertSnapshot(of: container, as: .image)

      let c2 = constrain(labelC, .firstBaseline, leq, positionBelow: labelB, .lastBaseline,
                        spacingMultipliedBy: 3)
      c2.isActive = true
      defer { c2.isActive = false }

      let c3 = constrain(labelC, .firstBaseline, geq, positionBelow: labelB, .lastBaseline,
                        spacingMultipliedBy: 1.5)
      c3.isActive = true
      defer { c3.isActive = false }

      assertSnapshot(of: container, as: .image)
    }())

    ({
      let c = constrain(labelC, .firstBaseline, eq, positionBelow: labelB, .lastBaseline,
                        spacingMultipliedBy: 2, plus: 3)
      c.isActive = true
      defer { c.isActive = false }
      assertSnapshot(of: container, as: .image)
    }())

    labelA.attributedText = NSAttributedString([("Lj 1A\n", [.font: font(size: 36)]),
                                                ("Lj 2A", [.font: font(size: 36)])])

    ({
      let c = constrain(labelC, .firstBaseline, eq, labelB, .lastBaseline,
                        plusLineHeightMultipliedBy: 1)
      c.isActive = true
      defer { c.isActive = false }

      assertSnapshot(of: container, as: .image, named: "lineHeight_1")

      #expect(c.stu_labelSpacingConstraintMultiplier == 1)
      c.stu_labelSpacingConstraintMultiplier = 2
      #expect(c.stu_labelSpacingConstraintMultiplier == 2)
      assertSnapshot(of: container, as: .image, named: "lineHeight_2")

      #expect(c.stu_labelSpacingConstraintOffset == 0)
      c.stu_labelSpacingConstraintOffset = 3
      #expect(c.stu_labelSpacingConstraintOffset == 3)
      assertSnapshot(of: container, as: .image, named: "lineHeight_3")

      c.stu_labelSpacingConstraintMultiplier = 1
      c.stu_labelSpacingConstraintOffset = 0

      let view = newView("overlay")
      container.addSubview(view)
      view.backgroundColor = UIColor.orange.withAlphaComponent(0.25)
      [constrain(view, .height, eq, 1 / view.traitCollection.displayScale),
       constrain(view, .leading, eq, labelC, .leading),
       constrain(view, .width, eq, labelC, .width),
       constrain(view, .top, eq, labelB, .lastBaseline,
                 plusLineHeightMultipliedBy: 1, plus: -1 / view.traitCollection.displayScale)].activate()

      assertSnapshot(of: container, as: .image, named: "lineHeight_1_overlay")
    }())
  }

  @Test
  func `Label baselines layout guide is deallocated`() {
    _ = autoreleasepool { () -> NSLayoutConstraint? in
      let container: UIView = newContainer()
      let labelA: STULabel = newLabel("A")
      let labelB: STULabel = newLabel("B")

      container.addSubview(labelA)
      container.addSubview(labelB)
      let c = constrain(labelA, .firstBaseline, eq, positionAbove: labelB, .lastBaseline)
      c.isActive = true
      let c2 = constrain(labelB, .firstBaseline, eq, positionAbove: labelA, .lastBaseline)
      c2.isActive = true
      return c // Trigger destruction of labels and layout guides (because the constraint doesn't
               // retain the items.)
    }
  }

  @Test
  func `Spacing above and below with a non-label anchor`() {
    let container = newContainer()
    let label = newLabel()

    let f = UIFont(name: "Helvetica", size: 16)!
    assert(f.leading == 0)
    let size1 = (roundToDisplayScale(f.ascender, displayScale: container.traitCollection.displayScale) / f.ascender)*16
    let size2 = (roundToDisplayScale(f.descender, displayScale: container.traitCollection.displayScale) / f.descender)*16
    label.attributedText = NSAttributedString(
                             [("Lj 1\n", [.font: UIFont(name: "Helvetica", size: size1)!]),
                              ("Lj 2", [.font: UIFont(name: "Helvetica", size: size2)!])])
    let viewAbove = newView("above")
    viewAbove.backgroundColor = .red
    let viewBelow = newView("below")
    viewBelow.backgroundColor = .blue

    container.addSubview(label)
    container.addSubview(viewAbove)
    container.addSubview(viewBelow)

    let onePixel = 1 / container.traitCollection.displayScale

    var cs = [NSLayoutConstraint]()
    constrain(&cs, label, within: container)
    constrain(&cs, viewAbove, .left, eq, label, .left)
    constrain(&cs, viewBelow, .left, eq, label, .left)
    constrain(&cs, viewAbove, .width, eq, label, .width)
    constrain(&cs, viewBelow, .width, eq, label, .width)
    constrain(&cs, viewAbove, .height, eq, onePixel)
    constrain(&cs, viewBelow, .height, eq, onePixel)
    cs.append(constrain(viewAbove.bottomAnchor, eq, positionAbove: label, .firstBaseline,
                        plus: onePixel))
    cs.append(constrain(viewBelow.topAnchor, eq, positionBelow: label, .lastBaseline,
                        plus: -onePixel))
    cs.activate()

    assertSnapshot(of: container, as: .image)
  }
}
