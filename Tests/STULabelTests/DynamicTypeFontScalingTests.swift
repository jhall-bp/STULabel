// Copyright 2018 Stephan Tolksdorf

import STULabel.DynamicTypeFontScaling
import Testing

private final class LabelWithOverridePreferredContentSizeCategory: UILabel {
  var preferredContentSizeCategory: UIContentSizeCategory = .unspecified {
    didSet {
      traitOverrides.preferredContentSizeCategory = preferredContentSizeCategory
      updateTraitsIfNeeded()
    }
  }
}

private final class STULabelWithOverridePreferredContentSizeCategory: STULabel {
  var preferredContentSizeCategory: UIContentSizeCategory = .unspecified {
    didSet {
      traitOverrides.preferredContentSizeCategory = preferredContentSizeCategory
      updateTraitsIfNeeded()
    }
  }
}

@MainActor
struct DynamicTypeFontScalingTests {

  @Test
  func `default fonts use each layer's rendering environment`() {
    let largeTraits = UITraitCollection(preferredContentSizeCategory: .large)
    let accessibilityTraits = UITraitCollection(
      preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)

    let largeLayer = STULabelLayer()
    largeLayer.renderingTraitCollection = largeTraits
    largeLayer.text = "Large"
    let largeFont = largeLayer.font
    #expect(
      largeFont
        == UIFont.preferredFont(forTextStyle: .body, compatibleWith: largeTraits))
    #expect(largeLayer.font === largeFont)

    let accessibilityLayer = STULabelLayer()
    accessibilityLayer.renderingTraitCollection = accessibilityTraits
    accessibilityLayer.text = "Accessibility"
    let accessibilityFont = accessibilityLayer.font
    #expect(
      accessibilityFont
        == UIFont.preferredFont(forTextStyle: .body, compatibleWith: accessibilityTraits))
    #expect(accessibilityLayer.font === accessibilityFont)
    #expect(accessibilityFont != largeFont)
  }

  @Test
  func `plain and partially attributed text share the trait-correct default font`() {
    let traits = UITraitCollection(
      preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
    let expectedFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: traits)
    let explicitFont = UIFont.systemFont(ofSize: 13)
    let layer = STULabelLayer()
    layer.renderingTraitCollection = traits

    layer.text = "Plain"
    #expect(layer.font == expectedFont)
    #expect(
      layer.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == expectedFont)

    layer.attributedText = NSAttributedString([
      ("Default", [:]),
      (" explicit", [.font: explicitFont]),
    ])
    #expect(layer.font == expectedFont)
    #expect(
      layer.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == expectedFont)
    #expect(
      layer.attributedText.attribute(.font, at: 8, effectiveRange: nil) as? UIFont == explicitFont)
  }

  @Test
  func `enabling font adjustment immediately applies the current category`() {
    let largeTraits = UITraitCollection(preferredContentSizeCategory: .large)
    let accessibilityCategory = UIContentSizeCategory.accessibilityExtraExtraExtraLarge
    let accessibilityTraits = UITraitCollection(
      preferredContentSizeCategory: accessibilityCategory)
    let label = STULabelWithOverridePreferredContentSizeCategory()
    label.preferredContentSizeCategory = .large
    label.text = "Default"
    let largeFont = label.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
    #expect(
      largeFont
        == UIFont.preferredFont(forTextStyle: .body, compatibleWith: largeTraits))

    label.preferredContentSizeCategory = accessibilityCategory
    #expect(
      label.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == largeFont)

    label.adjustsFontForContentSizeCategory = true
    let expectedFont = UIFont.preferredFont(
      forTextStyle: .body, compatibleWith: accessibilityTraits)
    #expect(label.font == expectedFont)
    #expect(
      label.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == expectedFont)

    label.adjustsFontForContentSizeCategory = false
    label.preferredContentSizeCategory = .large
    #expect(label.font == expectedFont)
    label.text = "Replacement"
    #expect(
      label.font == UIFont.preferredFont(forTextStyle: .body, compatibleWith: largeTraits))

    let explicitFont = UIFont.systemFont(ofSize: 13)
    let attributedLabel = STULabelWithOverridePreferredContentSizeCategory()
    attributedLabel.preferredContentSizeCategory = .large
    attributedLabel.attributedText = NSAttributedString([
      ("Default", [:]),
      (" explicit", [.font: explicitFont]),
    ])
    attributedLabel.preferredContentSizeCategory = accessibilityCategory
    attributedLabel.adjustsFontForContentSizeCategory = true
    #expect(
      attributedLabel.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        == expectedFont)
    #expect(
      attributedLabel.attributedText.attribute(.font, at: 8, effectiveRange: nil) as? UIFont
        == explicitFont)

    attributedLabel.adjustsFontForContentSizeCategory = false
    attributedLabel.preferredContentSizeCategory = .large
    #expect(
      attributedLabel.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        == expectedFont)
    attributedLabel.text = "Replacement"
    #expect(
      attributedLabel.font
        == UIFont.preferredFont(forTextStyle: .body, compatibleWith: largeTraits))
  }

  @Test
  func `replacement text retires an implicit font preserved across a trait change`() {
    let largeTraits = UITraitCollection(preferredContentSizeCategory: .large)
    let accessibilityTraits = UITraitCollection(
      preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
    let accessibilityFont = UIFont.preferredFont(
      forTextStyle: .body, compatibleWith: accessibilityTraits)
    let layer = STULabelLayer()
    layer.renderingTraitCollection = largeTraits
    layer.text = "Initial"
    let largeFont = layer.font
    _ = layer.attributedText

    layer.renderingTraitCollection = accessibilityTraits
    #expect(layer.font == largeFont)
    #expect(
      layer.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == largeFont)

    layer.text = "Replacement"
    #expect(layer.font == accessibilityFont)
    #expect(
      layer.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        == accessibilityFont)
  }

  @Test
  func `an attributed default does not become the replacement plain text font`() {
    let largeTraits = UITraitCollection(preferredContentSizeCategory: .large)
    let accessibilityTraits = UITraitCollection(
      preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
    let largeFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: largeTraits)
    let accessibilityFont = UIFont.preferredFont(
      forTextStyle: .body, compatibleWith: accessibilityTraits)
    let explicitFont = UIFont.systemFont(ofSize: 13)
    let layer = STULabelLayer()
    layer.renderingTraitCollection = largeTraits
    layer.attributedText = NSAttributedString([
      ("Default", [:]),
      (" explicit", [.font: explicitFont]),
    ])
    _ = layer.shapedText

    layer.renderingTraitCollection = accessibilityTraits
    #expect(
      layer.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == largeFont)

    layer.text = "Plain replacement"
    #expect(layer.font == accessibilityFont)

    layer.attributedText = NSAttributedString([
      ("New default", [:]),
      (" explicit", [.font: explicitFont]),
    ])
    #expect(
      layer.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        == accessibilityFont)
    #expect(
      layer.attributedText.attribute(.font, at: 11, effectiveRange: nil) as? UIFont
        == explicitFont)
  }

  @Test
  func `explicit fonts survive trait changes and replacement text`() {
    let largeTraits = UITraitCollection(preferredContentSizeCategory: .large)
    let accessibilityTraits = UITraitCollection(
      preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
    let explicitFont = UIFont.systemFont(ofSize: 13)
    let layer = STULabelLayer()
    layer.renderingTraitCollection = largeTraits
    layer.font = explicitFont
    layer.text = "Initial"
    _ = layer.attributedText

    layer.renderingTraitCollection = accessibilityTraits
    layer.text = "Replacement"
    #expect(layer.font === explicitFont)
    #expect(
      layer.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        === explicitFont)

    layer.attributedText = NSAttributedString(
      string: "Attributed", attributes: [.font: explicitFont])
    layer.renderingTraitCollection = largeTraits
    layer.text = "Plain replacement"
    #expect(layer.font === explicitFont)
  }

  @Test
  func `canonical content size categories are decoded correctly`() {
    let categories: [UIContentSizeCategory] = [
      .extraSmall,
      .small,
      .medium,
      .large,
      .extraLarge,
      .extraExtraLarge,
      .extraExtraExtraLarge,
      .accessibilityMedium,
      .accessibilityLarge,
      .accessibilityExtraLarge,
      .accessibilityExtraExtraLarge,
      .accessibilityExtraExtraExtraLarge,
    ]
    let font = UIFont.preferredFont(
      forTextStyle: .caption2,
      compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))

    for category in categories {
      let expectedFont = UIFont.preferredFont(
        forTextStyle: .caption2,
        compatibleWith: UITraitCollection(preferredContentSizeCategory: category))
      #expect(font.stu_fontAdjusted(forContentSizeCategory: category) == expectedFont)
    }
  }

  @Test
  func `adjusted font respects the content size category`() {
    let fixedFont = UIFont.systemFont(ofSize: 16)

    #expect(fixedFont == fixedFont.stu_fontAdjusted(forContentSizeCategory: .extraLarge))
    // The second call tests a different code path.
    #expect(fixedFont == fixedFont.stu_fontAdjusted(forContentSizeCategory: .extraLarge))

    #expect(
      fixedFont
        == fixedFont.stu_fontAdjusted(
          forContentSizeCategory:
            UIContentSizeCategory(rawValue: "doesn't exist")))

    let preferredFont = UIFont.preferredFont(
      forTextStyle: .caption2,
      compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))
    let label = LabelWithOverridePreferredContentSizeCategory()

    label.adjustsFontForContentSizeCategory = true
    label.preferredContentSizeCategory = .large
    label.font = preferredFont
    label.preferredContentSizeCategory = .extraExtraLarge
    #expect(label.font != preferredFont)
    #expect(label.font == preferredFont.stu_fontAdjusted(forContentSizeCategory: .extraExtraLarge))
    #expect(label.font == preferredFont.stu_fontAdjusted(forContentSizeCategory: .extraExtraLarge))
    label.preferredContentSizeCategory = .extraSmall
    #expect(label.font == preferredFont.stu_fontAdjusted(forContentSizeCategory: .extraSmall))

    // UILabel no longer scales a preferred font after its size is changed.
    let preferredFont2 = UIFont.preferredFont(
      forTextStyle: .body,
      compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))
    let preferredFont3 = preferredFont2.withSize(32)
    label.preferredContentSizeCategory = .large
    label.font = preferredFont3
    label.preferredContentSizeCategory = .extraSmall
    #expect(label.font == preferredFont3)

    label.preferredContentSizeCategory = .large
    #expect(label.font == preferredFont3)

    // UILabel scales preferred fonts with a changed symbolic trait.
    let italicPreferredFont = UIFont(
      descriptor: preferredFont2.fontDescriptor
        .withSymbolicTraits([.traitItalic])!,
      size: preferredFont2.pointSize)
    label.font = italicPreferredFont
    label.preferredContentSizeCategory = .extraSmall
    #expect(label.font == italicPreferredFont.stu_fontAdjusted(forContentSizeCategory: .extraSmall))
    // The adjusted font encodes the text style needed for UIKit to scale it.
    #expect(
      italicPreferredFont.stu_fontAdjusted(forContentSizeCategory: .extraSmall)
        == UIFont.preferredFont(
          forTextStyle: italicPreferredFont.fontDescriptor
            .object(forKey: .textStyle)
            as! UIFont.TextStyle,
          compatibleWith: UITraitCollection(
            preferredContentSizeCategory: .extraSmall)))

    let scaledPreferredFont =
      UIFontMetrics(forTextStyle: .body)
      .scaledFont(
        for: preferredFont2, maximumPointSize: 25,
        compatibleWith: UITraitCollection(preferredContentSizeCategory: .extraSmall))

    label.preferredContentSizeCategory = .extraSmall
    label.font = scaledPreferredFont
    label.preferredContentSizeCategory = .large
    // UIKit preserves maximum-point-size metadata, so these visually identical fonts are no
    // longer equal on current systems.
    #expect(label.font.pointSize == preferredFont2.pointSize)
    #expect(
      scaledPreferredFont.stu_fontAdjusted(forContentSizeCategory: .large).pointSize
        == preferredFont2.pointSize)
    label.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
    #expect(label.font.pointSize == 25)
    #expect(
      label.font.pointSize
        == scaledPreferredFont.stu_fontAdjusted(forContentSizeCategory: .large)
        .stu_fontAdjusted(
          forContentSizeCategory:
            .accessibilityExtraExtraExtraLarge
        ).pointSize)

    label.preferredContentSizeCategory = .large

    let helvetica = UIFont(name: "HelveticaNeue", size: 20)!
    let scaledHelvetica = UIFontMetrics(forTextStyle: .headline)
      .scaledFont(
        for: helvetica,
        compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))
    #expect(scaledHelvetica.pointSize == 20)
    label.font = scaledHelvetica

    label.font = scaledHelvetica
    label.preferredContentSizeCategory = .extraExtraLarge
    #expect(label.font != scaledHelvetica)
    #expect(
      label.font == scaledHelvetica.stu_fontAdjusted(forContentSizeCategory: .extraExtraLarge))
    #expect(
      label.font == scaledHelvetica.stu_fontAdjusted(forContentSizeCategory: .extraExtraLarge))

    label.preferredContentSizeCategory = .large

    let scaledHelvetica2 = UIFontMetrics(forTextStyle: .headline)
      .scaledFont(
        for: helvetica, maximumPointSize: 22,
        compatibleWith: UITraitCollection(preferredContentSizeCategory: .large))
    #expect(scaledHelvetica2.pointSize == 20)

    // UIFont isEqual doesn't compare the text style and maximum point size
    // (which is problematic), but UILabel uses it to optimize invalidation when assigning to the
    // font property (which is arguably a bug), so we set the font first to some unequal value.
    label.font = fixedFont
    label.font = scaledHelvetica2
    label.preferredContentSizeCategory = .extraExtraExtraLarge
    #expect(label.font != scaledHelvetica2)
    #expect(label.font.pointSize == 22)
    #expect(
      label.font == scaledHelvetica2.stu_fontAdjusted(forContentSizeCategory: .extraExtraExtraLarge)
    )
    #expect(
      label.font == scaledHelvetica2.stu_fontAdjusted(forContentSizeCategory: .extraExtraExtraLarge)
    )

    label.preferredContentSizeCategory = .small
    label.font = fixedFont
    label.font = scaledHelvetica
    label.preferredContentSizeCategory = .extraExtraLarge
    #expect(label.font != scaledHelvetica)
    #expect(
      label.font == scaledHelvetica.stu_fontAdjusted(forContentSizeCategory: .extraExtraLarge))
    label.font = nil
  }

  @Test
  func `attributed string fonts respect the content size category`() {
    let category: UIContentSizeCategory = .extraSmall
    let traitCollection = UITraitCollection(preferredContentSizeCategory: category)
    let font1 = UIFont.preferredFont(forTextStyle: .body)
    let scaledFont1 = UIFont.preferredFont(forTextStyle: .body, compatibleWith: traitCollection)
    let font2 = UIFont.preferredFont(forTextStyle: .title1)
    let scaledFont2 = UIFont.preferredFont(forTextStyle: .title1, compatibleWith: traitCollection)
    let fixedFont = UIFont.systemFont(ofSize: 16)

    let string1 = NSAttributedString()
    #expect(string1 === string1.stu_copyWithFontsAdjusted(forContentSizeCategory: category))
    let string2 = NSAttributedString(string: "test")
    #expect(string2 === string2.stu_copyWithFontsAdjusted(forContentSizeCategory: category))
    let string3 = NSAttributedString(string: "test", attributes: [.font: fixedFont])
    #expect(string3 === string3.stu_copyWithFontsAdjusted(forContentSizeCategory: category))

    #expect(
      NSAttributedString(string: "Test", attributes: [.font: font1])
        .stu_copyWithFontsAdjusted(forContentSizeCategory: category)
        == NSAttributedString(string: "Test", attributes: [.font: scaledFont1]))

    let string = NSMutableAttributedString()
    #expect(string !== string.stu_copyWithFontsAdjusted(forContentSizeCategory: category))
    string.stu_adjustFonts(in: NSRange(), forContentSizeCategory: category)

    string.append(NSAttributedString(string: "a", attributes: [.font: fixedFont]))
    string.append(
      NSAttributedString(
        string: "b",
        attributes: [
          .font: fixedFont,
          .foregroundColor: UIColor.red,
        ]))
    let string4 = string.copy() as! NSAttributedString
    #expect(string4 === string4.stu_copyWithFontsAdjusted(forContentSizeCategory: category))
    string.stu_adjustFonts(in: NSRange(0..<string.length), forContentSizeCategory: category)
    #expect(string == string4)

    string.append(NSAttributedString(string: "c", attributes: [.font: font1]))
    string.append(NSAttributedString(string: "d", attributes: [.font: font2]))
    string.append(
      NSAttributedString(
        string: "e",
        attributes: [
          .font: font2,
          .foregroundColor: UIColor.red,
        ]))
    string.append(NSAttributedString(string: "f"))

    string.stu_adjustFonts(in: NSRange(2..<6), forContentSizeCategory: category)
    #expect(string.string == "abcdef")
    #expect(string.attribute(.font, at: 2, effectiveRange: nil) as! UIFont == scaledFont1)
    #expect(string.attribute(.font, at: 3, effectiveRange: nil) as! UIFont == scaledFont2)
    #expect(
      (string.attributes(at: 4, effectiveRange: nil) as NSObject).isEqual(
        ([NSAttributedString.Key.font: scaledFont2, .foregroundColor: UIColor.red]) as NSObject))
    #expect((string.attributes(at: 5, effectiveRange: nil) as NSObject).isEqual(([:]) as NSObject))

  }
}
