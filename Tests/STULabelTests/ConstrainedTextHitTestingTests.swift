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
}
