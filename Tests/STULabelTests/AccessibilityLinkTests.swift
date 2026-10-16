import STULabelSwift
import Testing

@MainActor
private final class AccessibilityLinkDelegate: NSObject, STULabelDelegate {
  var activatedLink: STUTextLink?
  var activationPoint: CGPoint?

  func label(_ label: STULabel, link: STUTextLink, wasTappedAt point: CGPoint) {
    activatedLink = link
    activationPoint = point
  }
}

@MainActor
struct AccessibilityLinkTests {
  @Test(arguments: [false, true])
  func activationFollowsDisplayedTextMovement(representsUntruncatedText: Bool) throws {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
    label.verticalAlignment = .center
    label.accessibilityElementRepresentsUntruncatedText = representsUntruncatedText
    label.attributedText = NSAttributedString(
      string: "Open details", attributes: [
        .font: UIFont.systemFont(ofSize: 18),
        .link: URL(string: "https://example.com/details")!,
      ])
    let delegate = AccessibilityLinkDelegate()
    label.delegate = delegate
    label.layer.display()
    let element = try #require(
      label.accessibilityElement.accessibilityElements.first as? UIAccessibilityElement)
    let oldFrame = element.accessibilityFrame

    label.bounds.size.height = 250
    label.layoutIfNeeded()
    label.layer.displayIfNeeded()

    #expect(element.accessibilityFrame.midY > oldFrame.maxY)
    #expect(element.accessibilityActivate())
    let link = try #require(delegate.activatedLink)
    let point = try #require(delegate.activationPoint)
    #expect(link.rangeInOriginalString == NSRange(location: 0, length: 12))
    #expect(link.rectCount > 0)
    #expect(link.bounds.contains(point))
  }
}
