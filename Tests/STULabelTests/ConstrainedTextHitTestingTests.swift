import STULabelSwift
import Testing

@MainActor
struct ConstrainedTextHitTestingTests {
  @Test(arguments: [2, 9])
  func restrictedBidirectionalRangeUsesVisualDistance(queryIndex: Int) throws {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 400, height: 60))
    label.isSelectable = true
    label.font = .systemFont(ofSize: 20)
    label.text = "abc אבג xyz"
    let input: any UITextInput = label
    let beginning = input.beginningOfDocument
    let start = try #require(input.position(from: beginning, offset: 5))
    let end = try #require(input.position(from: beginning, offset: 6))
    let range = try #require(input.textRange(from: start, to: end))
    let queryPosition = try #require(input.position(from: beginning, offset: queryIndex))
    let queryCaret = input.caretRect(for: queryPosition)
    let point = CGPoint(x: queryCaret.midX, y: queryCaret.midY)
    let closest = try #require(input.closestPosition(to: point, within: range))

    // This range contains only ב: its logical end is the visual left edge.
    #expect(input.offset(from: beginning, to: closest) == (queryIndex == 2 ? 6 : 5))
  }

  @Test
  func restrictedBidirectionalBoundaryGeometryMatchesUITextView() throws {
    let frame = CGRect(x: 0, y: 0, width: 400, height: 60)
    let label = STULabel(frame: frame)
    label.isSelectable = true
    label.font = .systemFont(ofSize: 20)
    label.text = "abc אבג xyz"
    let textView = UITextView(frame: frame)
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.isEditable = false
    textView.isScrollEnabled = false
    textView.font = label.font
    textView.text = label.text
    textView.layoutIfNeeded()

    func relativeCaretX(_ input: any UITextInput, fraction: CGFloat) throws -> CGFloat {
      let beginning = input.beginningOfDocument
      let start = try #require(input.position(from: beginning, offset: 4))
      let end = try #require(input.position(from: beginning, offset: 7))
      let range = try #require(input.textRange(from: start, to: end))
      let bounds = input.firstRect(for: range)
      try #require(bounds.width > 0)
      let point = CGPoint(x: bounds.minX + fraction * bounds.width, y: bounds.midY)
      let restricted = try #require(input.closestPosition(to: point, within: range))
      #expect(input.compare(restricted, to: start) != .orderedAscending)
      #expect(input.compare(restricted, to: end) != .orderedDescending)
      return (input.caretRect(for: restricted).midX - bounds.minX) / bounds.width
    }

    // Shared bidi boundaries can have different logical positions at the same visual caret.
    // Compare geometry and range membership without requiring the same choice of logical position.
    for fraction: CGFloat in [-0.4, -0.01, 0, 0.01, 0.4, 0.6, 0.99, 1, 1.01, 1.4] {
      let actual = try relativeCaretX(label, fraction: fraction)
      let expected = try relativeCaretX(textView, fraction: fraction)
      #expect(abs(actual - expected) < 0.05)
    }
  }
}
