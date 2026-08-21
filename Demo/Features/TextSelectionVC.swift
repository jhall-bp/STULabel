// Copyright 2026 Stephan Tolksdorf

import STULabelSwift
import SafariServices
import UIKit

private let rightToLeftText = "‫اضغط مطولاً على هذا النصّ لتجربة المقابض."

/// Demonstrates STULabel's non-editable UITextInteraction support.
final class TextSelectionVC: UIViewController, STULabelDelegate {
  private let interactionStatusLabel = UILabel()
  private let selectableTextLabel = STULabel()
  private let rightToLeftTextLabel = STULabel()
  private let truncatedTextLabel = STULabel()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Text selection"
    view.backgroundColor = .white
    configureLabels()
    configureLayout()
    updateInteractionStatus()
  }

  private func configureLabels() {
    interactionStatusLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    interactionStatusLabel.textColor = .darkGray
    interactionStatusLabel.numberOfLines = 0
    interactionStatusLabel.adjustsFontForContentSizeCategory = true

    configureTextLabel(selectableTextLabel)
    selectableTextLabel.text =
      "Long-press this text to select a word or sentence, move the native selection handles, then copy it. Emoji 👩🏽‍💻 and composed characters stay together while selecting."

    let rightToLeftText = NSMutableAttributedString(string: rightToLeftText)
    rightToLeftText.addAttribute(
      .link, value: URL(string: "https://www.google.com")!, range: NSRange(location: 0, length: 5))
    configureTextLabel(rightToLeftTextLabel)
    rightToLeftTextLabel.delegate = self
    rightToLeftTextLabel.semanticContentAttribute = .forceRightToLeft
    rightToLeftTextLabel.attributedText = rightToLeftText

    configureTextLabel(truncatedTextLabel)
    truncatedTextLabel.maximumNumberOfLines = 2
    truncatedTextLabel.text =
      "Selection is based on exactly the text rendered by the label. This deliberately long sample is truncated after two lines, so hidden text is never selected or copied."
  }

  private func configureTextLabel(_ label: STULabel) {
    label.isSelectable = true
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.adjustsFontForContentSizeCategory = true
    label.maximumNumberOfLines = 0
    label.contentInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    label.backgroundColor = UIColor(white: 0.95, alpha: 1)
  }

  private func configureLayout() {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let stackView = UIStackView(arrangedSubviews: [
      interactionStatusLabel,
      sectionCaption("Plain text"),
      selectableTextLabel,
      sectionCaption("Right-to-left text"),
      rightToLeftTextLabel,
      sectionCaption("Truncated text"),
      truncatedTextLabel,
      sectionCaption("Link text presents a context menu, so selection begins on non-link text."),
    ])

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = 16

    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubview(stackView)

    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

      stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
    ])

    contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
      top: 20, leading: 20,
      bottom: 20, trailing: 20)
  }

  private func updateInteractionStatus() {
    if selectableTextLabel.textInteraction.textInteractionMode == .nonEditable {
      interactionStatusLabel.text =
        "Each selectable STULabel installed UITextInteractionModeNonEditable. Long-press any sample below to select and copy its visible text."
    } else {
      interactionStatusLabel.text = "UITextInteractionModeNonEditable was not installed."
    }
  }

  func label(
    _ label: STULabel,
    contextMenuConfigurationForLink link: STUTextLink,
    at location: CGPoint
  ) -> UIContextMenuConfiguration? {
    guard let url = link.linkAttribute as? URL else { return nil }
    return UIContextMenuConfiguration {
      SFSafariViewController(url: url)
    } actionProvider: { _ in
      let open = UIAction(title: "Open", image: UIImage(systemName: "safari")) { _ in
        UIApplication.shared.open(url)
      }
      let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
        UIPasteboard.general.url = url
      }
      return UIMenu(children: [open, copy])
    }
  }

  private func sectionCaption(_ text: String) -> UILabel {
    let label = UILabel()
    label.font = UIFont.preferredFont(forTextStyle: .footnote)
    label.textColor = .darkGray
    label.numberOfLines = 0
    label.adjustsFontForContentSizeCategory = true
    label.text = text
    return label
  }
}
