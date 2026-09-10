import STULabelSwift
import Testing
import UIKit

@MainActor
struct PrerenderedBackgroundTests {
  @Test(arguments: [false, true], [nil, UIColor.red, UIColor.clear])
  func `Prerendered backgrounds replace view state and survive trait changes`(
    existingBackground: Bool, imported: UIColor?
  ) {
    let label = STULabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    label.attributedText = NSAttributedString(
      string: "Background", attributes: [.font: UIFont.systemFont(ofSize: 17)])
    if existingBackground { label.backgroundColor = .blue }
    let prerenderer = STULabelPrerenderer(traitCollection: label.traitCollection)
    prerenderer.attributedText = label.attributedText
    prerenderer.setSize(label.bounds.size, contentInsets: .zero, options: [])
    prerenderer.backgroundColor = imported?.cgColor
    prerenderer.render()
    label.configure(with: prerenderer)
    #expect(label.backgroundColor?.cgColor == imported?.cgColor)
    for style in [UIUserInterfaceStyle.dark, .light] {
      label.traitOverrides.userInterfaceStyle = style
      label.updateTraitsIfNeeded()
      label.layer.display()
      #expect(label.backgroundColor?.cgColor == imported?.cgColor)
      #expect(label.layer.displayedBackgroundColor == imported?.cgColor)
    }

    let dynamic = UIColor.label
    label.backgroundColor = dynamic
    for style in [UIUserInterfaceStyle.dark, .light] {
      label.traitOverrides.userInterfaceStyle = style
      label.updateTraitsIfNeeded()
      #expect(label.backgroundColor === dynamic)
      #expect(label.layer.displayedBackgroundColor == dynamic.resolvedColor(with: label.traitCollection).cgColor)
    }
  }
}
