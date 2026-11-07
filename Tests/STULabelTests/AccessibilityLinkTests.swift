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
  @Test(arguments: [CGFloat(130), 300])
  func rtlLinksKeepTheirRangesAndActivationAcrossStyleChanges(width: CGFloat) throws {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: width, height: 200))
    label.maximumNumberOfLines = 0
    let paragraph = NSMutableParagraphStyle()
    paragraph.baseWritingDirection = .rightToLeft
    let source = NSMutableAttributedString(
      string: "ראשון 12345 שני 67890 שלישי",
      attributes: [.font: UIFont.systemFont(ofSize: 20), .paragraphStyle: paragraph])
    let words = ["ראשון 12345", "שני 67890", "שלישי"]
    let ranges = words.map { (source.string as NSString).range(of: $0) }
    let urls = try words.indices.map { try #require(URL(string: "https://example.com/\($0)")) }
    for index in words.indices {
      source.addAttribute(.link, value: urls[index], range: ranges[index])
      source.addAttributes(
        [.font: UIFont.boldSystemFont(ofSize: 24), .foregroundColor: UIColor.red],
        range: NSRange(location: ranges[index].location, length: 2))
    }
    label.attributedText = source
    let delegate = AccessibilityLinkDelegate()
    label.delegate = delegate
    label.layer.display()
    try #require(label.links.count == words.count)
    let textElement = try #require(
      label.accessibilityElement.accessibilityElements.first as? UIAccessibilityElement)
    let rotor = try #require(textElement.accessibilityCustomRotors?.first)
    let predicate = UIAccessibilityCustomRotorSearchPredicate()
    predicate.searchDirection = .next

    for index in words.indices {
      let link = label.links[index]
      #expect(link.rangeInOriginalString == ranges[index])
      #expect(link.linkAttribute as? URL == urls[index])
      for rectIndex in 0..<link.rectCount {
        let rect = link.rect(at: rectIndex)
        let point = CGPoint(x: rect.midX, y: rect.midY)
        #expect(label.links.link(closestTo: point, maxDistance: 0)?.linkAttribute as? URL == urls[index])
      }
      let result = try #require(rotor.itemSearchBlock(predicate))
      let element = try #require(result.targetElement as? UIAccessibilityElement)
      #expect(element.accessibilityLabel == words[index])
      #expect(element.accessibilityActivate())
      #expect(delegate.activatedLink?.rangeInOriginalString == ranges[index])
      #expect(delegate.activatedLink?.linkAttribute as? URL == urls[index])
      let point = try #require(delegate.activationPoint)
      #expect(label.links.link(closestTo: point, maxDistance: 0)?.linkAttribute as? URL == urls[index])
      predicate.currentItem = result
    }
    #expect(rotor.itemSearchBlock(predicate) == nil)
  }

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
