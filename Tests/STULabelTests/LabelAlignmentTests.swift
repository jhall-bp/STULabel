// Copyright 2018 Stephan Tolksdorf

import Foundation
import STULabelSwift
import SnapshotTesting
import Testing

@MainActor
struct LabelAlignmentTests {
  @Test
  func `Alignment`() {
    assertAlignment(useContentSublayer: false)
    assertAlignment(useContentSublayer: true)
  }

  func assertAlignment(useContentSublayer: Bool) {
    let s: CGFloat = 4
    let label = STULabel()
    if useContentSublayer {
      let selector = Selector(("stu_setAlwaysUsesContentSublayer:"))
      let layer = label.layer
      let method = layer.method(for: selector)
      let f = unsafeBitCast(method, to: (@convention(c) (NSObject, Selector, Bool) -> Void).self)
      f(layer, selector, true)
    }
    label.maximumNumberOfLines = 1
    label.contentInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    label.contentScaleFactor = s
    let fontSize = 16 * (16 / UIFont(name: "Helvetica", size: 16)!.ascender)
    let font1 = UIFont(name: "Helvetica", size: fontSize)!
    label.font = font1
    label.text = "Lxj"
    var size = label.sizeThatFits(CGSize(width: 100, height: 100))
    size.width = ceil(size.width * 1.5)
    size.height = ceil(size.height * 1.5)
    label.frame = CGRect(origin: .zero, size: size)

    label.drawingBlock = { p in
      p.draw()
      let ctx = p.context
      let tf = p.textFrame
      // This also tests the layoutInfo a bit.
      let info = label.layoutInfo
      let d = 1 / info.displayScale

      let offset = CGPoint(
        x: tf.origin.x - info.textFrameOrigin.x,
        y: tf.origin.y - info.textFrameOrigin.y)

      var bounds = info.layoutBounds
      bounds.origin = CGPoint(
        x: bounds.origin.x + offset.x,
        y: bounds.origin.y + offset.y)
      bounds.origin.x -= d / 2
      bounds.origin.y -= d / 2
      bounds.size.width += d
      bounds.size.height += d
      ctx.setStrokeColor(UIColor.green.cgColor)
      ctx.setLineWidth(d)
      ctx.stroke(bounds)

      let firstLine = tf.lines.first!
      let lastLine = tf.lines.last!
      let firstBaseline = info.firstBaseline + offset.y
      let lastBaseline = info.lastBaseline + offset.y

      ctx.setFillColor(UIColor.blue.cgColor)
      ctx.fill(
        CGRect(
          origin: CGPoint(x: firstLine.baselineOrigin.x, y: firstBaseline),
          size: CGSize(width: firstLine.width, height: d)))
      if tf.lines.count > 1 {
        ctx.fill(
          CGRect(
            origin: CGPoint(x: lastLine.baselineOrigin.x, y: lastBaseline),
            size: CGSize(width: lastLine.width, height: d)))
      }
      ctx.setFillColor(UIColor.red.cgColor)
      ctx.fill(
        CGRect(
          origin: CGPoint(
            x: firstLine.baselineOrigin.x,
            y: firstBaseline
              - CGFloat(info.firstLineHeightAboveBaseline) - d),
          size: CGSize(width: firstLine.width, height: d)))
      ctx.fill(
        CGRect(
          origin: CGPoint(
            x: lastLine.baselineOrigin.x,
            y: lastBaseline + CGFloat(info.lastLineHeightBelowBaseline)),
          size: CGSize(width: lastLine.width, height: d)))
    }

    assertSnapshot(of: label, as: .image, named: "tl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "tc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "tr")

    label.verticalAlignment = .center
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "cl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "cc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "cr")

    label.verticalAlignment = .centerXHeight
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "xl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "xc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "xr")

    label.verticalAlignment = .centerCapHeight
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "al")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "ac")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "ar")

    label.verticalAlignment = .bottom
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "bl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "bc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "br")

    let font2 = font1.withSize(fontSize / 2)
    label.attributedText = NSAttributedString([("Lxj\n", [.font: font1]), ("Lxj", [.font: font2])])

    label.maximumNumberOfLines = 0
    size = label.sizeThatFits(CGSize(width: 100, height: 100))
    size.width = ceil(size.width * 1.5)
    size.height = ceil(size.height * 1.5)
    label.frame = CGRect(origin: .zero, size: size)

    label.verticalAlignment = .top
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "2_tl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "2_tc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "2_tr")

    label.verticalAlignment = .center
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "2_cl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "2_cc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "2_cr")

    label.verticalAlignment = .centerXHeight
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "2_xl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "2_xc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "2_xr")

    label.verticalAlignment = .centerCapHeight
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "2_al")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "2_ac")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "2_ar")

    label.verticalAlignment = .bottom
    label.textAlignment = .left
    assertSnapshot(of: label, as: .image, named: "2_bl")
    label.textAlignment = .center
    assertSnapshot(of: label, as: .image, named: "2_bc")
    label.textAlignment = .right
    assertSnapshot(of: label, as: .image, named: "2_br")
  }

}
