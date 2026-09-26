// Copyright 2026 Stephan Tolksdorf

import Foundation
import STULabelSwift
import Testing

private final class TextInputDelegateRecorder: NSObject, UITextInputDelegate {
  var selectionWillChangeCount = 0
  var selectionDidChangeCount = 0
  var textWillChangeCount = 0
  var textDidChangeCount = 0
  var onTextWillChange: ((any UITextInput) -> Void)?
  var onTextDidChange: ((any UITextInput) -> Void)?

  func selectionWillChange(_ textInput: (any UITextInput)?) {
    selectionWillChangeCount += 1
  }

  func selectionDidChange(_ textInput: (any UITextInput)?) {
    selectionDidChangeCount += 1
  }

  func textWillChange(_ textInput: (any UITextInput)?) {
    textWillChangeCount += 1
    if let textInput {
      onTextWillChange?(textInput)
    }
  }

  func textDidChange(_ textInput: (any UITextInput)?) {
    textDidChangeCount += 1
    if let textInput {
      onTextDidChange?(textInput)
    }
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
  func `Visual caret movement retains affinity at bidirectional boundaries`() throws {
    let label = label(with: "abc אבג", size: CGSize(width: 200, height: 50))
    let input: any UITextInput = label
    let start = input.beginningOfDocument
    let beforeSpace = try #require(input.position(from: start, offset: 3))
    let afterSpace = try #require(input.position(from: beforeSpace, in: .right, offset: 1))
    let afterBidiBoundary = try #require(input.position(from: afterSpace, in: .right, offset: 1))
    let nextBidiPosition = try #require(
      input.position(from: afterBidiBoundary, in: .right, offset: 1))
    let zeroOffsetPosition = try #require(input.position(from: afterSpace, offset: 0))

    #expect(input.offset(from: start, to: afterSpace) == 4)
    #expect(input.offset(from: start, to: afterBidiBoundary) == 7)
    #expect(input.offset(from: start, to: nextBidiPosition) == 6)
    #expect(zeroOffsetPosition == afterSpace)
    #expect(input.caretRect(for: zeroOffsetPosition) == input.caretRect(for: afterSpace))

    let documentRange = try #require(documentRange(for: input))
    let farthestRight = try #require(input.position(within: documentRange, farthestIn: .right))
    #expect(input.offset(from: start, to: farthestRight) == 4)
    #expect(
      input.caretRect(for: farthestRight).midX
        > input.caretRect(for: input.endOfDocument).midX)

    let leftToRightLabel = self.label(with: "a👩‍💻b", size: CGSize(width: 200, height: 50))
    let leftToRightInput: any UITextInput = leftToRightLabel
    let afterA = try #require(
      leftToRightInput.position(
        from: leftToRightInput.beginningOfDocument,
        in: .right,
        offset: 1))
    let afterEmoji = try #require(leftToRightInput.position(from: afterA, in: .right, offset: 1))
    #expect(leftToRightInput.offset(from: leftToRightInput.beginningOfDocument, to: afterA) == 1)
    #expect(
      leftToRightInput.offset(from: leftToRightInput.beginningOfDocument, to: afterEmoji) == 6)

    let rightToLeftLabel = self.label(with: "אבג", size: CGSize(width: 200, height: 50))
    let rightToLeftInput: any UITextInput = rightToLeftLabel
    let afterFirstVisualCharacter = try #require(
      rightToLeftInput.position(
        from: rightToLeftInput.beginningOfDocument,
        in: .left,
        offset: 1))
    #expect(
      rightToLeftInput.offset(
        from: rightToLeftInput.beginningOfDocument,
        to: afterFirstVisualCharacter) == 1)
  }

  @Test
  func `Horizontal caret movement crosses wrapped lines in both writing directions`() throws {
    let wrappedLabel = self.label(with: "first second third", size: CGSize(width: 80, height: 100))
    let wrappedInput: any UITextInput = wrappedLabel
    let nextLine = try #require(
      wrappedInput.position(
        from: wrappedInput.beginningOfDocument,
        in: .down,
        offset: 1))
    #expect(
      wrappedInput.compare(nextLine, to: wrappedInput.beginningOfDocument) == .orderedDescending)

    var wrappedPosition = wrappedInput.beginningOfDocument
    var movedToAnotherLine = false
    var previousCaret = wrappedInput.caretRect(for: wrappedPosition)
    for _ in 0...wrappedLabel.text.utf16.count {
      guard let next = wrappedInput.position(from: wrappedPosition, in: .right, offset: 1) else {
        break
      }
      let caret = wrappedInput.caretRect(for: next)
      movedToAnotherLine = movedToAnotherLine || caret.midY > previousCaret.midY
      previousCaret = caret
      wrappedPosition = next
    }
    #expect(movedToAnotherLine)
    #expect(wrappedInput.compare(wrappedPosition, to: wrappedInput.endOfDocument) == .orderedSame)

    for _ in 0...wrappedLabel.text.utf16.count {
      guard let previous = wrappedInput.position(from: wrappedPosition, in: .left, offset: 1) else {
        break
      }
      wrappedPosition = previous
    }
    #expect(
      wrappedInput.compare(wrappedPosition, to: wrappedInput.beginningOfDocument) == .orderedSame)

    let wrappedRightToLeftLabel = self.label(
      with: "אבג דהו זחט יכל מנס",
      size: CGSize(width: 80, height: 100))
    wrappedRightToLeftLabel.semanticContentAttribute = .forceRightToLeft
    wrappedRightToLeftLabel.layoutIfNeeded()
    _ = wrappedRightToLeftLabel.textFrame
    notifyTextDidDisplay(in: wrappedRightToLeftLabel)
    let wrappedRightToLeftInput: any UITextInput = wrappedRightToLeftLabel
    var wrappedRightToLeftPosition = wrappedRightToLeftInput.beginningOfDocument
    for _ in 0...wrappedRightToLeftLabel.text.utf16.count {
      guard
        let next = wrappedRightToLeftInput.position(
          from: wrappedRightToLeftPosition,
          in: .left,
          offset: 1)
      else {
        break
      }
      wrappedRightToLeftPosition = next
    }
    #expect(
      wrappedRightToLeftInput.compare(
        wrappedRightToLeftPosition,
        to: wrappedRightToLeftInput.endOfDocument) == .orderedSame)

    for _ in 0...wrappedRightToLeftLabel.text.utf16.count {
      guard
        let previous = wrappedRightToLeftInput.position(
          from: wrappedRightToLeftPosition,
          in: .right,
          offset: 1)
      else {
        break
      }
      wrappedRightToLeftPosition = previous
    }
    #expect(
      wrappedRightToLeftInput.compare(
        wrappedRightToLeftPosition,
        to: wrappedRightToLeftInput.beginningOfDocument) == .orderedSame)
  }

  @Test
  func `Trailing whitespace and line terminators have usable carets`() throws {
    for text in ["abc  ", "אבג  ", "abc\n\ndef", "a\r\nb", " \t "] {
      let label = label(with: text, size: CGSize(width: 200, height: 200))
      let input: any UITextInput = label
      for index in 0...text.utf16.count {
        let position = try #require(input.position(from: input.beginningOfDocument, offset: index))
        let caret = input.caretRect(for: position)
        #expect(!caret.isEmpty, "Missing caret at UTF-16 offset \(index) in \(text.debugDescription)")
        #expect(caret.origin.x.isFinite && caret.origin.y.isFinite)
      }
      if text.hasSuffix("  ") {
        let direction: UITextLayoutDirection = text.hasPrefix("abc") ? .left : .right
        let previous = try #require(input.position(from: input.endOfDocument, in: direction, offset: 1))
        #expect(input.offset(from: previous, to: input.endOfDocument) == 1)
        let beforeWhitespace = try #require(
          input.position(from: input.endOfDocument, in: direction, offset: 2))
        #expect(input.offset(from: beforeWhitespace, to: input.endOfDocument) == 2)
      }
    }
  }

  @Test
  func `Multi-character visual movement matches individual steps`() throws {
    for text in [
      String(repeating: "a", count: 800),
      "abc אבג def",
      "a👩‍💻e\u{301}b",
      "abc  ",
    ] {
      let label = label(with: text, size: CGSize(width: 20000, height: 100))
      let input: any UITextInput = label
      for direction in [UITextLayoutDirection.right, .left] {
        let range = try #require(documentRange(for: input))
        let start = try #require(
          input.position(within: range, farthestIn: direction == .right ? .left : .right))
        var current = start
        var count = 0
        while let next = input.position(from: current, in: direction, offset: 1) {
          count += 1
          #expect(count <= text.utf16.count * 2 + 1)
          if count > text.utf16.count * 2 + 1 { break }
          let direct = try #require(input.position(from: start, in: direction, offset: count))
          #expect(direct == next)
          #expect(input.caretRect(for: direct) == input.caretRect(for: next))
          current = next
        }
        #expect(count > 0)
        #expect(input.position(from: start, in: direction, offset: count + 1) == nil)
      }
    }
  }

  @Test
  func `Caret geometry agrees with rendered text after truncation and scaling`() throws {
    for text in [
      "office affinity efficient",
      "אבג דהו זחט יכל מנס",
      "abc אבג def דהו ghi",
      "a👩‍💻e\u{301}b and more text",
    ] {
      for mode in [STULastLineTruncationMode.start, .middle, .end] {
        for minimumScale in [CGFloat(1), 0.6] {
          let label = label(
            with: NSAttributedString(
              string: text,
              attributes: [.font: UIFont(name: "TimesNewRomanPSMT", size: 24)!, .ligature: 1]),
            size: CGSize(width: 120, height: 70),
            insets: UIEdgeInsets(top: 5, left: 7, bottom: 3, right: 11))
          label.maximumNumberOfLines = 1
          label.lastLineTruncationMode = mode
          label.minimumTextScaleFactor = minimumScale
          label.layoutIfNeeded()
          notifyTextDidDisplay(in: label)
          let input: any UITextInput = label
          let frame = label.textFrame
          let length = input.offset(from: input.beginningOfDocument, to: input.endOfDocument)
          let rects = frame.rects(
            for: frame.range(forRangeInTruncatedString: NSRange(location: 0, length: length)))
          #expect(rects.rectCount > 0)
          for index in 0..<rects.rectCount {
            let rect = rects.rect(at: index)
            for x in stride(from: rect.minX + 0.5, to: rect.maxX, by: 3) {
              let cluster = frame.rangeOfGraphemeCluster(
                closestTo: CGPoint(x: x, y: rect.midY),
                ignoringTrailingWhitespace: true)
              for fraction in [CGFloat(0.25), 0.75] {
                let point = CGPoint(
                  x: cluster.bounds.minX + fraction * cluster.bounds.width,
                  y: cluster.bounds.midY)
                let position = try #require(input.closestPosition(to: point))
                let caret = input.caretRect(for: position)
                let expectedX = fraction < 0.5 ? cluster.bounds.minX : cluster.bounds.maxX
                // Core Text can redistribute insertion offsets within glyph clusters
                // relative to the individual glyph advances used by selection rects.
                #expect(
                  abs(caret.midX - expectedX) < 0.5,
                  "\(text), \(mode), scale \(minimumScale), position \(input.offset(from: input.beginningOfDocument, to: position))")
                #expect(caret.height > 0)
              }
            }
          }
        }
      }
    }
  }

  @Test
  func `Inserted hyphens preserve caret geometry in both writing directions`() throws {
    for text in ["ab\u{AD}cdefghij", "אב\u{AD}גדהוזחטי"] {
      let label = label(with: text, size: CGSize(width: 35, height: 200))
      let input: any UITextInput = label
      let frame = label.textFrame
      #expect(try #require(frame.textFrame.lines.first).hasInsertedHyphen)
      for index in 0..<2 {
        let rects = frame.rects(
          for: frame.range(forRangeInTruncatedString: NSRange(location: index, length: 1)))
        let rect = rects.rect(at: 0)
        let position = try #require(input.position(from: input.beginningOfDocument, offset: index))
        let expectedX = text.hasPrefix("ab") ? rect.minX : rect.maxX
        #expect(abs(input.caretRect(for: position).midX - expectedX) < 0.01)
      }
      let precedingRects = frame.rects(
        for: frame.range(forRangeInTruncatedString: NSRange(location: 1, length: 1)))
      let precedingRect = precedingRects.rect(at: 0)
      let beforeHyphen = try #require(input.position(from: input.beginningOfDocument, offset: 2))
      let expectedX = text.hasPrefix("ab") ? precedingRect.maxX : precedingRect.minX
      #expect(abs(input.caretRect(for: beforeHyphen).midX - expectedX) < 0.01)
      let afterHyphen = try #require(
        input.position(from: beforeHyphen, in: text.hasPrefix("ab") ? .right : .left, offset: 1))
      #expect(input.offset(from: input.beginningOfDocument, to: afterHyphen) == 3)
      #expect(input.caretRect(for: afterHyphen).midY == input.caretRect(for: beforeHyphen).midY)
    }
  }

  @Test
  func `Character extension follows storage characters across bidi boundaries`() throws {
    for text in ["abc אבג def", "אבג abc דהו", "a👩‍💻e\u{301}b"] {
      let label = label(with: text, size: CGSize(width: 90, height: 200))
      let input: any UITextInput = label
      let string = text as NSString
      var index = 0
      while index < string.length {
        let character = string.rangeOfComposedCharacterSequence(at: index)
        let position = try #require(input.position(from: input.beginningOfDocument, offset: index))
        for direction in [UITextLayoutDirection.right, .up, .down] {
          let range = try #require(input.characterRange(byExtending: position, in: direction))
          #expect(input.text(in: range) == string.substring(with: character))
        }
        let after = try #require(
          input.position(from: input.beginningOfDocument, offset: NSMaxRange(character)))
        let backward = try #require(input.characterRange(byExtending: after, in: .left))
        #expect(input.text(in: backward) == string.substring(with: character))
        index = NSMaxRange(character)
      }
    }

    let label = label(with: "abc אבג", size: CGSize(width: 200, height: 50))
    let input: any UITextInput = label
    let beforeSpace = try #require(input.position(from: input.beginningOfDocument, offset: 3))
    let afterSpace = try #require(input.position(from: beforeSpace, in: .right, offset: 1))
    let range = try #require(input.characterRange(byExtending: afterSpace, in: .right))
    #expect(input.text(in: range) == "א")
    #expect(input.characterRange(byExtending: input.beginningOfDocument, in: .left) == nil)
    #expect(input.characterRange(byExtending: input.endOfDocument, in: .right) == nil)
  }

  @Test
  func `Vertical movement uses the visual line at soft wraps`() throws {
    for text in ["abcdefghijklmno", "אבגדהוזחטיכלמנס"] {
      let label = label(with: text, size: CGSize(width: 45, height: 200))
      let input: any UITextInput = label
      let lines = label.textFrame.textFrame.lines
      #expect(lines.count >= 3)
      let endIndex = NSMaxRange(lines[0].rangeInTruncatedString)
      let beforeEnd = try #require(
        input.position(from: input.beginningOfDocument, offset: endIndex - 1))
      let direction: UITextLayoutDirection = text == "abcdefghijklmno" ? .right : .left
      let endOfFirstLine = try #require(input.position(from: beforeEnd, in: direction, offset: 1))
      let startOfSecondLine = try #require(
        input.position(from: input.beginningOfDocument, offset: endIndex))
      #expect(input.compare(endOfFirstLine, to: startOfSecondLine) == .orderedSame)
      #expect(input.caretRect(for: endOfFirstLine).midY < input.caretRect(for: startOfSecondLine).midY)
      #expect(input.position(from: endOfFirstLine, in: .up, offset: 1) == nil)

      let down = try #require(input.position(from: endOfFirstLine, in: .down, offset: 1))
      #expect(abs(input.caretRect(for: down).midY - input.caretRect(for: startOfSecondLine).midY) < 0.5)
      let up = try #require(input.position(from: down, in: .up, offset: 1))
      #expect(abs(input.caretRect(for: up).midY - input.caretRect(for: endOfFirstLine).midY) < 0.5)
    }
  }

  @Test
  func `Constrained hit testing preserves caret affinity`() throws {
    for (text, width) in [("abc אבג", 200.0), ("abcdefghijklmno", 45.0)] {
      let label = label(with: text, size: CGSize(width: width, height: 200))
      let input: any UITextInput = label
      let wholeDocument = try #require(documentRange(for: input))
      let preceding = try #require(input.position(from: input.beginningOfDocument, offset: 3))
      let boundary = try #require(input.position(from: preceding, in: .right, offset: 1))
      let caret = input.caretRect(for: boundary)
      let point = CGPoint(x: caret.midX - 0.1, y: caret.midY)
      let hit = try #require(input.closestPosition(to: point))
      let constrainedHit = try #require(input.closestPosition(to: point, within: wholeDocument))
      #expect(constrainedHit == hit)
      #expect(input.caretRect(for: constrainedHit) == input.caretRect(for: hit))

      let collapsedRange = try #require(input.textRange(from: boundary, to: boundary))
      for x in [-100.0, 1000.0] {
        let clamped = try #require(
          input.closestPosition(to: CGPoint(x: x, y: caret.midY), within: collapsedRange))
        #expect(clamped == boundary)
        #expect(input.caretRect(for: clamped) == caret)
      }
    }
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
  func `Visible document publication is stable during delegate callbacks`() throws {
    let label = label(with: "before", size: CGSize(width: 200, height: 50))
    let input: any UITextInput = label
    let recorder = TextInputDelegateRecorder()
    var lengthsDuringWillChange: [Int] = []
    var lengthsDuringDidChange: [Int] = []
    var hadSelectionDuringWillChange: [Bool] = []
    var hadSelectionDuringDidChange: [Bool] = []
    recorder.onTextWillChange = { changedInput in
      lengthsDuringWillChange.append(
        changedInput.offset(
          from: changedInput.beginningOfDocument,
          to: changedInput.endOfDocument))
      hadSelectionDuringWillChange.append(changedInput.selectedTextRange != nil)
    }
    recorder.onTextDidChange = { changedInput in
      lengthsDuringDidChange.append(
        changedInput.offset(
          from: changedInput.beginningOfDocument,
          to: changedInput.endOfDocument))
      hadSelectionDuringDidChange.append(changedInput.selectedTextRange != nil)
    }
    input.inputDelegate = recorder
    input.selectedTextRange = documentRange(for: input)
    recorder.selectionWillChangeCount = 0
    recorder.selectionDidChangeCount = 0

    label.text = "after"
    _ = label.textFrame
    notifyTextDidDisplay(in: label)

    #expect(recorder.textWillChangeCount == 1)
    #expect(recorder.textDidChangeCount == 1)
    #expect(recorder.selectionWillChangeCount == 1)
    #expect(recorder.selectionDidChangeCount == 1)
    #expect(lengthsDuringWillChange == [6])
    #expect(lengthsDuringDidChange == [5])
    #expect(hadSelectionDuringWillChange == [true])
    #expect(hadSelectionDuringDidChange == [false])
    #expect(input.selectedTextRange == nil)

    let truncatingLabel = self.label(
      with: "abcdefghijklmnopqrst",
      size: CGSize(width: 62, height: 50))
    let truncatingInput: any UITextInput = truncatingLabel
    let truncationRecorder = TextInputDelegateRecorder()
    truncatingInput.inputDelegate = truncationRecorder
    truncatingLabel.maximumNumberOfLines = 1
    truncatingLabel.lastLineTruncationMode = .end
    _ = truncatingLabel.textFrame
    notifyTextDidDisplay(in: truncatingLabel)

    #expect(truncationRecorder.textWillChangeCount == 1)
    #expect(truncationRecorder.textDidChangeCount == 1)
    #expect(
      truncatingInput.offset(
        from: truncatingInput.beginningOfDocument,
        to: truncatingInput.endOfDocument) < truncatingLabel.text.utf16.count)
  }

  @Test
  func `Published document keeps text and caret geometry coherent during callbacks`() throws {
    let font = UIFont.systemFont(ofSize: 20)
    let label = label(
      with: NSAttributedString(string: "iiii", attributes: [.font: font]),
      size: CGSize(width: 400, height: 100))
    let input: any UITextInput = label
    let oldEnd = input.endOfDocument
    let oldCaret = input.caretRect(for: oldEnd)
    let probePoint = CGPoint(x: 30, y: 10)
    let oldRange = try #require(documentRange(for: input))
    let oldSelectionRects = input.selectionRects(for: oldRange).map(\.rect)
    let oldClosestPosition = try #require(input.closestPosition(to: probePoint))
    let oldClosestOffset = input.offset(from: input.beginningOfDocument, to: oldClosestPosition)
    let oldHitRange = try #require(input.characterRange(at: probePoint))
    let oldHitOffset = input.offset(from: input.beginningOfDocument, to: oldHitRange.start)
    let recorder = TextInputDelegateRecorder()
    var textDuringWillChange: String?
    var textDuringDidChange: String?
    var caretDuringWillChange: CGRect?
    var caretDuringDidChange: CGRect?
    var selectionRectsDuringWillChange: [CGRect]?
    var selectionRectsDuringDidChange: [CGRect]?
    var closestOffsetDuringWillChange: Int?
    var closestOffsetDuringDidChange: Int?
    var hitOffsetDuringWillChange: Int?
    var hitOffsetDuringDidChange: Int?
    recorder.onTextWillChange = { changedInput in
      let range = changedInput.textRange(
        from: changedInput.beginningOfDocument,
        to: changedInput.endOfDocument)
      textDuringWillChange = range.flatMap { changedInput.text(in: $0) }
      caretDuringWillChange = changedInput.caretRect(for: changedInput.endOfDocument)
      selectionRectsDuringWillChange = range.map {
        changedInput.selectionRects(for: $0).map(\.rect)
      }
      closestOffsetDuringWillChange = changedInput.closestPosition(to: probePoint).map {
        changedInput.offset(from: changedInput.beginningOfDocument, to: $0)
      }
      hitOffsetDuringWillChange = changedInput.characterRange(at: probePoint).map {
        changedInput.offset(from: changedInput.beginningOfDocument, to: $0.start)
      }
    }
    recorder.onTextDidChange = { changedInput in
      let range = changedInput.textRange(
        from: changedInput.beginningOfDocument,
        to: changedInput.endOfDocument)
      textDuringDidChange = range.flatMap { changedInput.text(in: $0) }
      caretDuringDidChange = changedInput.caretRect(for: changedInput.endOfDocument)
      selectionRectsDuringDidChange = range.map {
        changedInput.selectionRects(for: $0).map(\.rect)
      }
      closestOffsetDuringDidChange = changedInput.closestPosition(to: probePoint).map {
        changedInput.offset(from: changedInput.beginningOfDocument, to: $0)
      }
      hitOffsetDuringDidChange = changedInput.characterRange(at: probePoint).map {
        changedInput.offset(from: changedInput.beginningOfDocument, to: $0.start)
      }
    }
    input.inputDelegate = recorder

    label.contentInsets = UIEdgeInsets(top: 5, left: 23, bottom: 0, right: 0)
    label.attributedText = NSAttributedString(string: "WWWW", attributes: [.font: font])
    _ = label.textFrame
    notifyTextDidDisplay(in: label)

    let newCaret = input.caretRect(for: input.endOfDocument)
    let newRange = try #require(documentRange(for: input))
    let newSelectionRects = input.selectionRects(for: newRange).map(\.rect)
    let newClosestPosition = try #require(input.closestPosition(to: probePoint))
    let newClosestOffset = input.offset(from: input.beginningOfDocument, to: newClosestPosition)
    let newHitRange = try #require(input.characterRange(at: probePoint))
    let newHitOffset = input.offset(from: input.beginningOfDocument, to: newHitRange.start)
    #expect(recorder.textWillChangeCount == 1)
    #expect(recorder.textDidChangeCount == 1)
    #expect(textDuringWillChange == "iiii")
    #expect(textDuringDidChange == "WWWW")
    #expect(caretDuringWillChange == oldCaret)
    #expect(caretDuringDidChange == newCaret)
    #expect(selectionRectsDuringWillChange == oldSelectionRects)
    #expect(selectionRectsDuringDidChange == newSelectionRects)
    #expect(closestOffsetDuringWillChange == oldClosestOffset)
    #expect(closestOffsetDuringDidChange == newClosestOffset)
    #expect(hitOffsetDuringWillChange == oldHitOffset)
    #expect(hitOffsetDuringDidChange == newHitOffset)
    #expect(newCaret.midX > oldCaret.midX + 20)
  }

  @Test
  func `Published document keeps an old endpoint valid while text shrinks`() throws {
    let font = UIFont.systemFont(ofSize: 20)
    let label = label(
      with: NSAttributedString(string: "abcdef", attributes: [.font: font]),
      size: CGSize(width: 400, height: 100))
    let input: any UITextInput = label
    let oldEnd = try #require(input.closestPosition(to: CGPoint(x: 399, y: 10)))
    #expect(input.offset(from: input.beginningOfDocument, to: oldEnd) == 6)
    let oldCaret = input.caretRect(for: oldEnd)
    let recorder = TextInputDelegateRecorder()
    var textDuringWillChange: String?
    var caretDuringWillChange: CGRect?
    recorder.onTextWillChange = { changedInput in
      let range = changedInput.textRange(
        from: changedInput.beginningOfDocument,
        to: changedInput.endOfDocument)
      textDuringWillChange = range.flatMap { changedInput.text(in: $0) }
      caretDuringWillChange = changedInput.caretRect(for: oldEnd)
    }
    input.inputDelegate = recorder

    label.attributedText = NSAttributedString(string: "a", attributes: [.font: font])
    _ = label.textFrame
    notifyTextDidDisplay(in: label)

    #expect(recorder.textWillChangeCount == 1)
    #expect(recorder.textDidChangeCount == 1)
    #expect(textDuringWillChange == "abcdef")
    #expect(caretDuringWillChange == oldCaret)
    #expect(input.caretRect(for: oldEnd) == .zero)
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
