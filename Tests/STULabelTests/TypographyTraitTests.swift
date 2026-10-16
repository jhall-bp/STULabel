import STULabelSwift
import Testing

@MainActor
struct TypographyTraitTests {
  @Test(arguments: [false, true])
  func enabledFontAdjustmentFollowsBoldText(attributed: Bool) throws {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 400, height: 100))
    label.traitOverrides.preferredContentSizeCategory = .large
    label.traitOverrides.legibilityWeight = .regular
    label.updateTraitsIfNeeded()
    let regularFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: label.traitCollection)
    if attributed {
      label.attributedText = NSAttributedString(string: "Typography", attributes: [.font: regularFont])
    } else {
      label.text = "Typography"
    }
    label.adjustsFontForContentSizeCategory = true
    _ = label.textFrame

    label.traitOverrides.legibilityWeight = .bold
    label.updateTraitsIfNeeded()
    label.layoutIfNeeded()
    let boldFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: label.traitCollection)
    #expect(boldFont != regularFont)
    #expect(label.font == boldFont)
    #expect(label.attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont == boldFont)

    label.traitOverrides.preferredContentSizeCategory = .extraExtraLarge
    label.updateTraitsIfNeeded()
    label.layoutIfNeeded()
    let largeBoldFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: label.traitCollection)
    #expect(label.font == largeBoldFont)

    label.traitOverrides.legibilityWeight = .regular
    label.updateTraitsIfNeeded()
    label.layoutIfNeeded()
    let largeRegularFont = UIFont.preferredFont(forTextStyle: .body, compatibleWith: label.traitCollection)
    #expect(largeRegularFont != largeBoldFont)
    #expect(label.font == largeRegularFont)
  }
}
