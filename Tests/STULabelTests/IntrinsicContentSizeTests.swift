import STULabelSwift
import Testing
import UIKit

@MainActor
struct IntrinsicContentSizeTests {
  private class Label: STULabel {
    var layoutCount = 0
    var measurementCount = 0
    var invalidationCount = 0

    override func layoutSubviews() {
      layoutCount += 1
      super.layoutSubviews()
    }

    override var intrinsicContentSize: CGSize {
      measurementCount += 1
      return super.intrinsicContentSize
    }

    override func invalidateIntrinsicContentSize() {
      invalidationCount += 1
      super.invalidateIntrinsicContentSize()
    }
  }

  private func makeLabel() -> Label {
    let label = Label()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 17)
    label.maximumNumberOfLines = 0
    label.text = String(repeating: "Width dependent multiline layout. ", count: 8)
    return label
  }

  @Test
  func `Constrained multiline layout converges after width and content changes`() {
    for hasIntrinsicWidth in [true, false] {
      print("Auto Layout runtime: \(ProcessInfo.processInfo.operatingSystemVersionString)")
      let root = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))
      let label = makeLabel()
      label.hasIntrinsicContentWidth = hasIntrinsicWidth
      root.addSubview(label)
      let width = label.widthAnchor.constraint(equalToConstant: 240)
      NSLayoutConstraint.activate([
        label.leadingAnchor.constraint(equalTo: root.leadingAnchor),
        label.topAnchor.constraint(equalTo: root.topAnchor),
        width
      ])

      for targetWidth: CGFloat in [240, 120, 360, 120, 240] {
        width.constant = targetWidth
        // Detached views need an explicit request for the layout pass.
        root.setNeedsLayout()
        root.layoutIfNeeded()
        let expected = label.sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
        #expect(abs(label.bounds.height - expected.height) < 0.01)
        #expect(label.bounds.width == targetWidth)
        #expect(!label.hasAmbiguousLayout)
        let count = label.layoutCount
        let measurements = label.measurementCount
        root.layoutIfNeeded()
        #expect(label.layoutCount == count)
        #expect(label.measurementCount == measurements)
      }

      for text in ["Short", String(repeating: "New multiline content. ", count: 12), ""] {
        label.text = text
        root.setNeedsLayout()
        root.layoutIfNeeded()
        let expected = label.sizeThatFits(CGSize(width: width.constant, height: .greatestFiniteMagnitude))
        #expect(abs(label.bounds.height - expected.height) < 0.01)
        let count = label.layoutCount
        root.layoutIfNeeded()
        #expect(label.layoutCount == count)
      }
    }
  }

  @Test
  func `Self sizing container follows multiline content at its established width`() {
    let container = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 1000))
    let label = makeLabel()
    container.addSubview(label)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
      label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
      label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
      label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
    ])
    for width: CGFloat in [180, 320, 140] {
      container.bounds.size.width = width
      container.layoutIfNeeded()
      let size = container.systemLayoutSizeFitting(
        CGSize(width: width, height: 0),
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel)
      let expected = label.sizeThatFits(CGSize(width: width - 16, height: .greatestFiniteMagnitude))
      #expect(abs(size.height - expected.height - 12) < 0.01)
      #expect(size.width == width)
      container.bounds.size.height = size.height
      container.layoutIfNeeded()
      #expect(abs(label.bounds.height - expected.height) < 0.01)
    }
  }

  @Test
  func `Baseline anchors and content guide follow width font and inset changes`() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))
    let label = makeLabel()
    root.addSubview(label)
    let first = UIView()
    let last = UIView()
    first.translatesAutoresizingMaskIntoConstraints = false
    last.translatesAutoresizingMaskIntoConstraints = false
    root.addSubview(first)
    root.addSubview(last)
    let content = label.contentLayoutGuide
    let width = label.widthAnchor.constraint(equalToConstant: 200)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 10),
      label.topAnchor.constraint(equalTo: root.topAnchor, constant: 20),
      width,
      first.topAnchor.constraint(equalTo: label.firstBaselineAnchor),
      last.topAnchor.constraint(equalTo: label.lastBaselineAnchor),
      first.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      last.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      first.widthAnchor.constraint(equalToConstant: 1),
      last.widthAnchor.constraint(equalToConstant: 1),
      first.heightAnchor.constraint(equalToConstant: 1),
      last.heightAnchor.constraint(equalToConstant: 1)
    ])
    for value: CGFloat in [200, 100, 300] {
      width.constant = value
      label.font = .systemFont(ofSize: value / 10)
      label.contentInsets = UIEdgeInsets(top: 7, left: 11, bottom: 13, right: 17)
      root.setNeedsLayout()
      root.layoutIfNeeded()
      let info = label.layoutInfo
      let tolerance = 1 / info.displayScale
      #expect(abs(first.frame.minY - label.frame.minY - info.firstBaseline) <= tolerance)
      #expect(abs(last.frame.minY - label.frame.minY - info.lastBaseline) <= tolerance)
      #expect(content.layoutFrame == label.bounds.inset(by: label.contentInsets))
      let count = label.layoutCount
      root.layoutIfNeeded()
      #expect(label.layoutCount == count)
    }
  }

  @Test
  func `Baseline anchors follow bounds origins without invalidating intrinsic size`() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 1000))
    let label = makeLabel()
    label.text = "First line\nLast line"
    label.contentInsets = UIEdgeInsets(top: 7, left: 11, bottom: 13, right: 17)
    root.addSubview(label)

    let first = UIView()
    let last = UIView()
    let spaced = UIView()
    first.translatesAutoresizingMaskIntoConstraints = false
    last.translatesAutoresizingMaskIntoConstraints = false
    spaced.translatesAutoresizingMaskIntoConstraints = false
    root.addSubview(first)
    root.addSubview(last)
    root.addSubview(spaced)
    let baselineSpacing = constrain(
      spaced, .top, .equal, label, .firstBaseline,
      plusLineHeightMultipliedBy: 1, plus: 3)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 10),
      label.topAnchor.constraint(equalTo: root.topAnchor, constant: 20),
      label.widthAnchor.constraint(equalToConstant: 200),
      label.heightAnchor.constraint(equalToConstant: 120),
      first.topAnchor.constraint(equalTo: label.firstBaselineAnchor),
      last.topAnchor.constraint(equalTo: label.lastBaselineAnchor),
      baselineSpacing,
      first.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      last.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      spaced.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      first.widthAnchor.constraint(equalToConstant: 1),
      last.widthAnchor.constraint(equalToConstant: 1),
      first.heightAnchor.constraint(equalToConstant: 1),
      last.heightAnchor.constraint(equalToConstant: 1),
      spaced.widthAnchor.constraint(equalToConstant: 1),
      spaced.heightAnchor.constraint(equalToConstant: 1),
    ])

    for alignment: STULabelVerticalAlignment in [.top, .center, .bottom] {
      label.verticalAlignment = alignment
      root.setNeedsLayout()
      root.layoutIfNeeded()
      _ = label.intrinsicContentSize
      let invalidationCount = label.invalidationCount
      let baselineSpacingConstant = baselineSpacing.constant

      for originY: CGFloat in [0, 9, -9, 0] {
        label.bounds.origin.y = originY
        root.layoutIfNeeded()

        let info = label.layoutInfo
        let tolerance = 1 / info.displayScale
        let convertedFirstBaseline = label.convert(
          CGPoint(x: 0, y: info.firstBaseline), to: root
        ).y
        let convertedLastBaseline = label.convert(
          CGPoint(x: 0, y: info.lastBaseline), to: root
        ).y
        #expect(abs(first.frame.minY - convertedFirstBaseline) <= tolerance)
        #expect(abs(last.frame.minY - convertedLastBaseline) <= tolerance)
        #expect(
          abs(spaced.frame.minY - convertedFirstBaseline - baselineSpacing.constant) <= tolerance)
        #expect(baselineSpacing.constant == baselineSpacingConstant)
        #expect(label.invalidationCount == invalidationCount)
      }
    }
  }

  @Test
  func `Baseline spacing rounds at the layer rendering scale`() {
    let root = UIView(frame: CGRect(x: 0, y: 0, width: 600, height: 1_000))
    root.traitOverrides.displayScale = 3
    let label = makeLabel()
    root.addSubview(label)
    let spaced = UIView()
    spaced.translatesAutoresizingMaskIntoConstraints = false
    root.addSubview(spaced)
    let baselineSpacing = constrain(
      spaced, .top, .equal, label, .firstBaseline, plusLineHeightMultipliedBy: 1)
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      label.topAnchor.constraint(equalTo: root.topAnchor),
      label.widthAnchor.constraint(equalToConstant: 200),
      label.heightAnchor.constraint(equalToConstant: 120),
      baselineSpacing,
      spaced.leadingAnchor.constraint(equalTo: root.leadingAnchor),
      spaced.widthAnchor.constraint(equalToConstant: 1),
      spaced.heightAnchor.constraint(equalToConstant: 1),
    ])
    root.updateTraitsIfNeeded()
    label.updateTraitsIfNeeded()
    #expect(label.traitCollection.displayScale == 3)

    for scale: CGFloat in [1, 2, 3] {
      label.contentScaleFactor = scale
      root.setNeedsLayout()
      root.layoutIfNeeded()
      let info = label.layoutInfo
      let expected = ceil(CGFloat(info.firstLineHeight) * scale) / scale
      #expect(info.displayScale == scale)
      #expect(abs(baselineSpacing.constant - expected) < 0.000_001)
    }
  }

  @Test
  func `Single line bounds changes reuse intrinsic measurement`() {
    let label = makeLabel()
    label.maximumNumberOfLines = 1
    let size = label.intrinsicContentSize
    let count = label.invalidationCount
    for width: CGFloat in [100, 200, 50] {
      label.bounds.size = CGSize(width: width, height: size.height)
      #expect(label.intrinsicContentSize == size)
    }
    #expect(label.invalidationCount == count)
  }

  @Test
  func `Height and origin changes preserve a multiline intrinsic measurement`() {
    let label = makeLabel()
    label.text = "Short"
    label.bounds.size = CGSize(width: 1000, height: 100)
    let size = label.intrinsicContentSize
    let count = label.invalidationCount
    for height: CGFloat in [200, 50, 100] {
      label.bounds = CGRect(x: 3, y: 5, width: 1000, height: height)
      #expect(label.invalidationCount == count)
      #expect(label.intrinsicContentSize == size)
    }
  }

  @Test
  func `Direct intrinsic measurement is invalidated by a new multiline width`() {
    let label = makeLabel()
    label.bounds.size.width = 200
    let first = label.intrinsicContentSize
    let count = label.invalidationCount
    label.bounds.size.width = 100
    #expect(label.invalidationCount == count + 1)
    #expect(label.intrinsicContentSize.height > first.height)
  }
}
