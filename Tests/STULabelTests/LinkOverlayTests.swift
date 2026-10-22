import STULabelSwift
import Testing
import UIKit

@MainActor
private final class LinkTouch: UITouch {
  var point = CGPoint.zero

  override func location(in view: UIView?) -> CGPoint { point }
}

@MainActor
struct LinkOverlayTests {
  private func overlayStyle(_ color: UIColor) -> STULabelOverlayStyle {
    let builder = STULabelOverlayStyleBuilder(nil)
    builder.color = color
    builder.fadeInDuration = 0
    builder.fadeOutDuration = 0
    return STULabelOverlayStyle(builder)
  }

  @Test(arguments: [false, true])
  func changingOverlayStyleKeepsTheMovedActiveLink(initiallyHasOverlay: Bool) throws {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
    label.verticalAlignment = .center
    label.activeLinkOverlayStyle = initiallyHasOverlay ? overlayStyle(.red) : nil
    label.attributedText = NSAttributedString(
      string: "Open details", attributes: [
        .font: UIFont.systemFont(ofSize: 18),
        .link: URL(string: "https://example.com/details")!,
      ])
    label.layer.display()
    try #require(label.links.count == 1)
    let originalBounds = label.links[0].bounds

    let touch = LinkTouch()
    touch.point = CGPoint(x: originalBounds.midX, y: originalBounds.midY)
    label.touchesBegan([touch], with: nil)
    defer { label.touchesCancelled([touch], with: nil) }
    try #require(label.activeLink != nil)

    // Move the touch with the centered text while preserving its layout.
    touch.point.y += 100
    label.bounds.size.height = 250
    label.layoutIfNeeded()
    let expectedBounds = originalBounds.offsetBy(dx: 0, dy: 100)
    let movedBounds = try #require(label.activeLink).bounds
    try #require(abs(movedBounds.minY - expectedBounds.minY) < 0.00001)
    try #require(abs(movedBounds.maxY - expectedBounds.maxY) < 0.00001)

    label.activeLinkOverlayStyle = overlayStyle(.blue)

    let activeLink = try #require(label.activeLink)
    #expect(abs(activeLink.bounds.minY - expectedBounds.minY) < 0.00001)
    #expect(abs(activeLink.bounds.maxY - expectedBounds.maxY) < 0.00001)
    #expect(activeLink.rangeInOriginalString == NSRange(location: 0, length: 12))
  }
}
