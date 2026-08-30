// Copyright 2026 Stephan Tolksdorf

import Foundation
import STULabelSwift
import Testing

private final class TextInputDelegateRecorder: NSObject, UITextInputDelegate {
  var selectionWillChangeCount = 0
  var selectionDidChangeCount = 0
  var textWillChangeCount = 0
  var textDidChangeCount = 0

  func selectionWillChange(_ textInput: (any UITextInput)?) {
    selectionWillChangeCount += 1
  }

  func selectionDidChange(_ textInput: (any UITextInput)?) {
    selectionDidChangeCount += 1
  }

  func textWillChange(_ textInput: (any UITextInput)?) {
    textWillChangeCount += 1
  }

  func textDidChange(_ textInput: (any UITextInput)?) {
    textDidChangeCount += 1
  }

  @available(iOS 18.4, *)
  func conversationContext(
    _ context: UIConversationContext?, didChange textInput: (any UITextInput)?
  ) {}
}

private final class ContextMenuDelegateRecorder: NSObject, STULabelDelegate {
  var configuration: UIContextMenuConfiguration?
  private(set) var callCount = 0
  private(set) weak var lastLabel: STULabel?
  private(set) var lastLink: STUTextLink?
  private(set) var lastLocation = CGPoint.zero

  func label(
    _ label: STULabel,
    contextMenuConfigurationForLink link: STUTextLink,
    at location: CGPoint
  ) -> UIContextMenuConfiguration? {
    callCount += 1
    lastLabel = label
    lastLink = link
    lastLocation = location
    return configuration
  }
}

private final class TextInputSystemActionLabel: STULabel {
  @objc func performSystemAction(_ sender: Any?) {}
}

@MainActor
struct UITextInputTests {
  private func notifyTextDidDisplay(in label: STULabel) {
    let textFrame = label.textFrame
    label.labelLayer(
      label.layer,
      didDisplayTextWith: textFrame.flags,
      in: label.bounds)
  }

  private func label(
    with attributedText: NSAttributedString,
    size: CGSize,
    insets: UIEdgeInsets = .zero
  ) -> STULabel {
    let label = STULabel(frame: CGRect(origin: .zero, size: size))
    label.isSelectable = true
    label.contentInsets = insets
    label.maximumNumberOfLines = 0
    label.attributedText = attributedText
    label.layoutIfNeeded()
    _ = label.textFrame
    notifyTextDidDisplay(in: label)
    return label
  }

  private func label(with text: String, size: CGSize) -> STULabel {
    label(
      with: NSAttributedString(
        string: text,
        attributes: [.font: UIFont.systemFont(ofSize: 18)]),
      size: size)
  }

  private func installedContextMenuInteraction(
    in label: STULabel
  ) -> UIContextMenuInteraction? {
    label.interactions.lazy
      .compactMap { $0 as? UIContextMenuInteraction }
      .first { $0.delegate === label }
  }

  private func documentRange(for input: any UITextInput) -> UITextRange? {
    input.textRange(
      from: input.beginningOfDocument,
      to: input.endOfDocument)
  }

  private func point(in label: STULabel, range: NSRange) -> CGPoint? {
    let textFrame = label.textFrame
    let rects = textFrame.rects(
      for: textFrame.range(forRangeInTruncatedString: range))
    guard rects.rectCount > 0 else { return nil }
    let rect = rects.rect(at: 0)
    return CGPoint(x: rect.midX, y: rect.midY)
  }

  @Test
  func `Conformance and non-editable interaction`() throws {
    let label = label(with: "text", size: CGSize(width: 200, height: 50))
    let textInputProtocol = try #require(NSProtocolFromString("UITextInput"))
    #expect(label.conforms(to: textInputProtocol))
    #expect(label.isSelectable)

    let interaction = label.textInteraction
    #expect(label.interactions.contains { $0 === interaction })
    #expect(interaction.view === label)
    let delegate = try #require(interaction.delegate as? NSObject)
    let controllerClass: AnyClass = try #require(
      NSClassFromString("STULabelTextInteraction"))
    #expect(delegate.isKind(of: controllerClass))
    #expect(interaction.textInput === label)
    #expect(interaction.textInteractionMode == .nonEditable)
    #expect(label.canBecomeFirstResponder)
  }

  @Test
  func `Selectable controls interaction installation`() {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    #expect(!label.isSelectable)

    let interaction = label.textInteraction
    #expect(!label.interactions.contains { $0 === interaction })
    #expect(interaction.view == nil)

    label.isSelectable = true
    #expect(label.interactions.contains { $0 === interaction })
    #expect(interaction.view === label)

    label.isSelectable = false
    #expect(!label.interactions.contains { $0 === interaction })
    #expect(interaction.view == nil)
  }

  @Test
  func `Positions and ranges have value semantics`() throws {
    let firstLabel = label(with: "text", size: CGSize(width: 200, height: 50))
    let secondLabel = label(with: "text", size: CGSize(width: 200, height: 50))
    let firstInput: any UITextInput = firstLabel
    let secondInput: any UITextInput = secondLabel

    let firstPosition = firstInput.beginningOfDocument
    let equivalentPosition = firstInput.beginningOfDocument
    let secondLabelPosition = secondInput.beginningOfDocument
    #expect(firstPosition == equivalentPosition)
    #expect(firstPosition == secondLabelPosition)
    #expect(firstPosition.hash == equivalentPosition.hash)

    let firstRange = try #require(
      firstInput.textRange(
        from: firstPosition,
        to: firstInput.endOfDocument))
    let equivalentRange = try #require(
      firstInput.textRange(
        from: equivalentPosition,
        to: firstInput.endOfDocument))
    #expect(firstRange == equivalentRange)
    #expect(firstRange.hash == equivalentRange.hash)
  }

  @Test
  func `Ranges normalize reversed endpoints for selection handle updates`() throws {
    let label = label(with: "first second", size: CGSize(width: 200, height: 50))
    let input: any UITextInput = label
    let lower = try #require(
      input.position(from: input.beginningOfDocument, offset: 2))
    let upper = try #require(
      input.position(from: input.beginningOfDocument, offset: 8))

    let range = try #require(input.textRange(from: upper, to: lower))

    #expect(input.text(in: range) == "rst se")
    #expect(input.compare(lower, to: range.start) == .orderedSame)
    #expect(input.compare(upper, to: range.end) == .orderedSame)
    input.selectedTextRange = range
    #expect(input.selectedTextRange == range)
  }

  @Test
  func `Visible string positions use UTF-16 offsets`() throws {
    let label = label(with: "A👩‍💻B", size: CGSize(width: 200, height: 50))
    let input: any UITextInput = label
    let begin = input.beginningOfDocument
    let afterA = try #require(input.position(from: begin, offset: 1))
    let insideEmoji = try #require(input.position(from: afterA, offset: 1))
    let afterEmoji = try #require(input.position(from: begin, offset: 6))
    let end = input.endOfDocument

    #expect(input.offset(from: begin, to: afterA) == 1)
    #expect(input.offset(from: begin, to: insideEmoji) == 2)
    #expect(input.offset(from: afterA, to: afterEmoji) == 5)
    #expect(input.offset(from: afterEmoji, to: end) == 1)
    let emojiRange = try #require(input.textRange(from: afterA, to: afterEmoji))
    #expect(input.text(in: emojiRange) == "👩‍💻")
    let documentRange = try #require(documentRange(for: input))
    let positionWithinRange = try #require(input.position)
    #expect(positionWithinRange(documentRange, 2) == insideEmoji)
    let characterOffset = try #require(input.characterOffset)
    #expect(characterOffset(insideEmoji, documentRange) == 2)
    #expect(input.position(from: begin, offset: -1) == nil)
    #expect(input.position(from: end, offset: 1) == nil)
  }

  @Test
  func `Multiline geometry, hit testing, and tokenizer`() throws {
    let label = label(
      with: NSAttributedString(
        string: "first second third fourth fifth",
        attributes: [.font: UIFont.systemFont(ofSize: 18)]),
      size: CGSize(width: 105, height: 130),
      insets: UIEdgeInsets(top: 7, left: 11, bottom: 5, right: 3))
    let input: any UITextInput = label
    let documentRange = try #require(documentRange(for: input))
    let selectionRects = input.selectionRects(for: documentRange)
    #expect(selectionRects.count >= 2)

    let firstRect = try #require(selectionRects.first?.rect)
    let tolerance: CGFloat = 1e-6
    #expect(firstRect.minX + tolerance >= label.textFrame.origin.x)
    #expect(firstRect.minY + tolerance >= label.textFrame.origin.y)

    let point = try #require(point(in: label, range: NSRange(location: 0, length: 1)))
    let hitRange = try #require(input.characterRange(at: point))
    #expect(input.text(in: hitRange) == "f")

    let wordRange = try #require(
      input.tokenizer.rangeEnclosingPosition(
        input.beginningOfDocument,
        with: .word,
        inDirection: UITextDirection(rawValue: UITextStorageDirection.forward.rawValue)))
    #expect(input.text(in: wordRange) == "first")

    let nextLine = try #require(
      input.position(
        from: input.beginningOfDocument,
        in: .down,
        offset: 1))
    #expect(input.offset(from: input.beginningOfDocument, to: nextLine) > 0)
  }

  @Test
  func `Right-to-left selection rect uses right-to-left writing direction`() throws {
    let label = label(with: "שלום עולם", size: CGSize(width: 200, height: 50))
    label.semanticContentAttribute = .forceRightToLeft
    _ = label.textFrame
    notifyTextDidDisplay(in: label)
    let input: any UITextInput = label
    let end = input.endOfDocument
    let beforeEnd = try #require(input.position(from: end, offset: -1))
    let range = try #require(input.textRange(from: beforeEnd, to: end))
    let rect = try #require(input.selectionRects(for: range).first)
    #expect(rect.writingDirection == .rightToLeft)
    #expect(rect.transform.isIdentity)
    #expect(
      input.baseWritingDirection(for: beforeEnd, in: .backward)
        == .rightToLeft)
  }

  @Test
  func `Visible truncation is the only copyable text`() throws {
    let label = label(
      with: "abcdefghijklmnopqrst",
      size: CGSize(width: 62, height: 50))
    label.maximumNumberOfLines = 1
    label.lastLineTruncationMode = .end
    _ = label.textFrame
    notifyTextDidDisplay(in: label)
    let input: any UITextInput = label
    let visibleString = label.textFrame.truncatedAttributedString.string
    #expect(visibleString != label.text)
    let documentRange = try #require(documentRange(for: input))
    #expect(input.text(in: documentRange) == visibleString)

    label.selectAll(nil)
    #expect(
      label.canPerformAction(
        #selector(UIResponderStandardEditActions.copy(_:)),
        withSender: nil))
    let pasteboard = UIPasteboard.general
    pasteboard.items = []
    // Reading the pasteboard directly triggers the system confirmation prompt during tests.
    #expect(!pasteboard.hasStrings)
    label.copy(nil)
    #expect(pasteboard.hasStrings)
  }

  @Test
  func `Truncation token link cannot be selected`() throws {
    let font = UIFont.systemFont(ofSize: 18)
    let token = NSMutableAttributedString(
      string: "… more",
      attributes: [.font: font])
    token.addAttribute(
      .link,
      value: "more",
      range: NSRange(location: 2, length: 4))
    let label = label(
      with: NSAttributedString(
        string: "A long sentence that needs truncation.",
        attributes: [.font: font]),
      size: CGSize(width: 120, height: 50))
    label.maximumNumberOfLines = 1
    label.truncationToken = token
    _ = label.textFrame
    notifyTextDidDisplay(in: label)

    #expect(label.links.count == 1)
    let link = label.links[0]
    let input: any UITextInput = label
    let interaction = label.textInteraction
    let delegate = try #require(interaction.delegate)
    let interactionShouldBegin = try #require(delegate.interactionShouldBegin)
    let linkPoint = try #require(
      point(in: label, range: link.rangeInTruncatedString))
    #expect(!interactionShouldBegin(interaction, linkPoint))
    let documentRange = try #require(documentRange(for: input))
    input.selectedTextRange = documentRange
    let selection = try #require(input.selectedTextRange)
    #expect(
      input.offset(from: input.beginningOfDocument, to: selection.end)
        == link.rangeInTruncatedString.location)
    #expect(
      input.text(in: selection)
        == (label.textFrame.truncatedAttributedString.string as NSString)
        .substring(to: link.rangeInTruncatedString.location))

    let linkStart = try #require(
      input.position(
        from: input.beginningOfDocument,
        offset: link.rangeInTruncatedString.location))
    let linkEnd = try #require(
      input.position(
        from: linkStart,
        offset: link.rangeInTruncatedString.length))
    let linkRange = try #require(input.textRange(from: linkStart, to: linkEnd))
    input.selectedTextRange = linkRange
    #expect(input.selectedTextRange == nil)
  }

  @Test
  func `Editing and marked text operations are no-ops`() throws {
    let label = label(with: "unchanged", size: CGSize(width: 200, height: 50))
    let input: any UITextInput = label
    let range = try #require(documentRange(for: input))

    input.insertText("x")
    input.deleteBackward()
    input.replace(range, withText: "replacement")
    input.setMarkedText("marked", selectedRange: NSRange(location: 0, length: 1))
    input.unmarkText()
    #expect(label.text == "unchanged")
    #expect(input.markedTextRange == nil)
    #expect(
      !label.canPerformAction(
        #selector(UIResponderStandardEditActions.cut(_:)),
        withSender: nil))
    #expect(
      !label.canPerformAction(
        #selector(UIResponderStandardEditActions.paste(_:)),
        withSender: nil))
    let shouldChangeText = try #require(input.shouldChangeText)
    #expect(!shouldChangeText(range, "replacement"))
    #expect(label.value(forKey: "editable") as? Bool == false)
  }

  @Test
  func `System-owned menu actions use responder validation`() {
    let label = TextInputSystemActionLabel(
      frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    label.isSelectable = true
    label.text = "text"

    #expect(
      label.canPerformAction(
        #selector(TextInputSystemActionLabel.performSystemAction(_:)),
        withSender: nil))
    #expect(
      !label.canPerformAction(
        #selector(UIResponderStandardEditActions.cut(_:)),
        withSender: nil))
    #expect(
      !label.canPerformAction(
        #selector(UIResponderStandardEditActions.paste(_:)),
        withSender: nil))
    #expect(
      !label.canPerformAction(
        #selector(UIResponderStandardEditActions.delete(_:)),
        withSender: nil))
  }

  @Test
  func `Visible text change notifies input delegate and invalidates selection`() throws {
    let label = label(with: "before", size: CGSize(width: 200, height: 50))
    let input: any UITextInput = label
    let recorder = TextInputDelegateRecorder()
    input.inputDelegate = recorder
    let documentRange = try #require(documentRange(for: input))
    input.selectedTextRange = documentRange
    recorder.selectionWillChangeCount = 0
    recorder.selectionDidChangeCount = 0

    label.text = "after"
    _ = label.textFrame
    notifyTextDidDisplay(in: label)

    #expect(recorder.textWillChangeCount == 1)
    #expect(recorder.textDidChangeCount == 1)
    #expect(recorder.selectionWillChangeCount == 1)
    #expect(recorder.selectionDidChangeCount == 1)
    #expect(input.selectedTextRange == nil)
  }

  @Test
  func `Links retain text interaction precedence`() throws {
    let text = NSMutableAttributedString(
      string: "link plain text",
      attributes: [.font: UIFont.systemFont(ofSize: 18)])
    text.addAttribute(
      .link,
      value: URL(string: "https://example.com")!,
      range: NSRange(location: 0, length: 4))
    let label = label(
      with: text,
      size: CGSize(width: 250, height: 50))
    let interaction = label.textInteraction
    let delegate = try #require(interaction.delegate)
    let interactionShouldBegin = try #require(delegate.interactionShouldBegin)
    let linkPoint = try #require(
      point(in: label, range: NSRange(location: 0, length: 4)))
    let plainTextPoint = try #require(
      point(in: label, range: NSRange(location: 5, length: 5)))
    #expect(!interactionShouldBegin(interaction, linkPoint))
    #expect(interactionShouldBegin(interaction, plainTextPoint))
  }

  @Test
  func `Context menu interaction is installed only for a capable delegate`() throws {
    let text = NSMutableAttributedString(
      string: "link plain text",
      attributes: [.font: UIFont.systemFont(ofSize: 18)])
    text.addAttribute(
      .link,
      value: URL(string: "https://example.com")!,
      range: NSRange(location: 0, length: 4))
    let label = label(
      with: text,
      size: CGSize(width: 250, height: 50))

    notifyTextDidDisplay(in: label)
    #expect(installedContextMenuInteraction(in: label) == nil)

    let recorder = ContextMenuDelegateRecorder()
    label.delegate = recorder
    let interaction = try #require(installedContextMenuInteraction(in: label))
    #expect(interaction.view === label)
    #expect(interaction.delegate === label)
  }

  @Test
  func `Link context menu interaction installation and delegate forwarding`() throws {
    let text = NSMutableAttributedString(
      string: "link plain text",
      attributes: [.font: UIFont.systemFont(ofSize: 18)])
    text.addAttribute(
      .link,
      value: URL(string: "https://example.com")!,
      range: NSRange(location: 0, length: 4))
    let label = label(
      with: text,
      size: CGSize(width: 250, height: 50))
    let interaction = label.contextMenuInteraction
    #expect(label.interactions.contains { $0 === interaction })
    #expect(interaction.view === label)
    #expect(interaction.delegate === label)

    let linkPoint = try #require(
      point(in: label, range: NSRange(location: 0, length: 4)))
    #expect(
      label.contextMenuInteraction(
        interaction,
        configurationForMenuAtLocation: linkPoint) == nil)

    let recorder = ContextMenuDelegateRecorder()
    let configuration = UIContextMenuConfiguration(
      identifier: nil,
      previewProvider: nil,
      actionProvider: nil)
    recorder.configuration = configuration
    label.delegate = recorder

    #expect(
      label.contextMenuInteraction(
        interaction,
        configurationForMenuAtLocation: linkPoint) === configuration)
    #expect(recorder.callCount == 1)
    #expect(recorder.lastLabel === label)
    #expect(recorder.lastLink === label.links[0])
    #expect(recorder.lastLocation == linkPoint)

    #expect(
      label.contextMenuInteraction(
        interaction,
        configurationForMenuAtLocation: CGPoint(x: -100, y: -100)) == nil)
    #expect(recorder.callCount == 1)

    recorder.configuration = nil
    #expect(
      label.contextMenuInteraction(
        interaction,
        configurationForMenuAtLocation: linkPoint) == nil)
    #expect(recorder.callCount == 2)

    label.delegate = nil
    #expect(
      label.contextMenuInteraction(
        interaction,
        configurationForMenuAtLocation: linkPoint) == nil)
    #expect(recorder.callCount == 2)
  }

  @Test
  func `Accessibility element does not retain label`() {
    weak var weakLabel: STULabel?
    autoreleasepool {
      let label = STULabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
      label.text = "Accessible text"
      #expect(!label.accessibilityElements.isEmpty)
      weakLabel = label
    }
    #expect(weakLabel == nil)
  }
}
