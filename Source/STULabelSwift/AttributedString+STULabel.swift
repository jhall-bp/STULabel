@_exported import STULabel

/// STULabel's custom attributes together with UIKit, Foundation, and accessibility attributes.
///
/// Use Foundation's scoped initializers in both directions:
/// ```swift
/// let text = try AttributedString(nsText, including: \.stu)
/// let nsText = try NSAttributedString(text, including: \.stu)
/// ```
///
/// Attachment and truncation-scope values retain their identity. Core Text run delegates are
/// intentionally excluded: STULabel regenerates them when shaping attachments. For direct Core Text
/// use, call `stu_attributedStringByAddingCTRunDelegatesForSTUTextAttachments()` after conversion.
/// Preserving these attributes does not make other renderers implement STULabel's drawing behavior.
public struct STULabelAttributes: AttributeScope {
  public let accessibilitySpeechLanguage: SpeechLanguageAttribute
  public let stuBackground: BackgroundAttribute
  public let stuParagraphStyle: ParagraphStyleAttribute
  public let stuTruncationScope: TruncationScopeAttribute
  public let stuAttachment: AttachmentAttribute
  public let stuHyphenationLocaleIdentifier: HyphenationLocaleIdentifierAttribute
  public let uiKit: AttributeScopes.UIKitAttributes
  public let accessibility: AttributeScopes.AccessibilityAttributes

  /// Exposes UIKit's speech-language attribute in the Swift AttributedString scope.
  public enum SpeechLanguageAttribute: AttributedStringKey {
    public typealias Value = String
    public static let name = NSAttributedString.Key.accessibilitySpeechLanguage.rawValue
  }

  public enum BackgroundAttribute: AttributedStringKey {
    public typealias Value = STUBackgroundAttribute
    public static let name = NSAttributedString.Key.stuBackground.rawValue
  }

  public enum ParagraphStyleAttribute: AttributedStringKey {
    public typealias Value = STUParagraphStyle
    public static let name = NSAttributedString.Key.stuParagraphStyle.rawValue
  }

  public enum TruncationScopeAttribute: AttributedStringKey {
    public typealias Value = STUTruncationScope
    public static let name = NSAttributedString.Key.stuTruncationScope.rawValue
  }

  public enum AttachmentAttribute: AttributedStringKey {
    public typealias Value = STUTextAttachment
    public static let name = NSAttributedString.Key.stuAttachment.rawValue
    public static let inheritedByAddedText = false
  }

  public enum HyphenationLocaleIdentifierAttribute: AttributedStringKey {
    public typealias Value = String
    public static let name = NSAttributedString.Key.stuHyphenationLocaleIdentifier.rawValue
  }
}

extension AttributeScopes {
  public var stu: STULabelAttributes.Type { STULabelAttributes.self }
}

extension AttributeDynamicLookup {
  public subscript<T: AttributedStringKey>(
    dynamicMember keyPath: KeyPath<STULabelAttributes, T>
  ) -> T {
    self[T.self]
  }
}
