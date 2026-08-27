import STULabelSwift
import SnapshotTesting
import Testing
import UIKit

@MainActor
@Suite(.snapshots(record: .missing))
struct TextAttachmentTests {
  func createTestImage(
    _ size: CGSize,
    _ color1: UIColor = UIColor.yellow,
    _ color2: UIColor = UIColor.blue,
    format: STUCGImageFormat.Predefined = .rgb
  ) -> UIImage {
    return createImage(size, scale: displayScale, backgroundColor: color1, format) { (context) in
      context.setFillColor(color2.cgColor)
      context.fill(CGRect(x: 0, y: size.height / 2, width: size.width, height: size.height / 2))
    }
  }

  let displayScale: CGFloat = 2

  func image(_ tf: STUTextFrame) -> UIImage {
    let bounds = ceilToScale(tf.layoutBounds, displayScale)
    let format: STUCGImageFormat.Predefined =
      !tf.flags.contains(.mayNotBeGrayscale)
      ? .grayscale
      : tf.flags.contains(.usesExtendedColor)
        ? .extendedRGB
        : .rgb
    print(bounds, tf.imageBounds(frameOrigin: .zero, displayScale: 2))

    return createImage(
      bounds.size, scale: displayScale, backgroundColor: .white, format,
      { context in
        tf.draw(
          at: -bounds.origin, in: context, contextBaseCTM_d: 1,
          pixelAlignBaselines: true)
      })
  }

  let font = UIFont(name: "HelveticaNeue", size: 20)!

  @Test
  func `Initializer and encoding`() throws {
    let attachment = STUTextAttachment(
      width: 1.25, ascent: 2, descent: 3, leading: 4,
      imageBounds: CGRect(x: 5, y: 6, width: 7, height: 8),
      colorInfo: [.isGrayscale, .usesExtendedColors],
      stringRepresentation: "test")
    #expect(attachment.width == 1.25)
    #expect(attachment.ascent == 2)
    #expect(attachment.descent == 3)
    #expect(attachment.leading == 4)
    #expect(attachment.typographicBounds == CGRect(x: 0, y: -4, width: 1.25, height: 9))
    #expect(attachment.imageBounds == CGRect(x: 5, y: 6, width: 7, height: 8))
    #expect(attachment.colorInfo == [.isGrayscale, .usesExtendedColors])
    #expect(attachment.stringRepresentation == "test")

    let data = try NSKeyedArchiver.archivedData(
      withRootObject: attachment, requiringSecureCoding: true)
    let attachment2 = try NSKeyedUnarchiver.unarchivedObject(
      ofClass: STUTextAttachment.self, from: data)!

    #expect(attachment2.width == 1.25)
    #expect(attachment2.ascent == 2)
    #expect(attachment2.descent == 3)
    #expect(attachment2.leading == 4)
    #expect(attachment2.imageBounds == CGRect(x: 5, y: 6, width: 7, height: 8))
    #expect(attachment2.colorInfo == [.isGrayscale, .usesExtendedColors])
    #expect(attachment2.stringRepresentation == "test")

    #expect(!attachment2.isAccessibilityElement)

    attachment2.isAccessibilityElement = true
    attachment2.accessibilityAttributedLabel = NSAttributedString(
      string: "label", attributes: [.baselineOffset: 1])
    attachment2.accessibilityAttributedHint = NSAttributedString(
      string: "hint", attributes: [.baselineOffset: 2])
    attachment2.accessibilityAttributedValue = NSAttributedString(
      string: "value", attributes: [.baselineOffset: 3])
    attachment2.accessibilityLanguage = "language"

    let data2 = try NSKeyedArchiver.archivedData(
      withRootObject: attachment2, requiringSecureCoding: true)
    let attachment3 = try NSKeyedUnarchiver.unarchivedObject(
      ofClass: STUTextAttachment.self, from: data2)!

    #expect(attachment3.isAccessibilityElement)

    #expect(
      attachment3.accessibilityAttributedLabel
        == NSAttributedString(string: "label", attributes: [.baselineOffset: 1]))
    #expect(
      attachment3.accessibilityAttributedHint
        == NSAttributedString(string: "hint", attributes: [.baselineOffset: 2]))
    #expect(
      attachment3.accessibilityAttributedValue
        == NSAttributedString(string: "value", attributes: [.baselineOffset: 3]))
    #expect(attachment3.accessibilityLanguage == "language")
  }

  @Test
  func `Image attachment initializer and encoding`() throws {
    let imageSize = CGSize(width: 30, height: 20)
    let grayscaleImage = createTestImage(imageSize, format: .grayscale)
    let extendedRGBImage = createTestImage(
      imageSize,
      UIColor(red: 1.5, green: 0, blue: 0, alpha: 1),
      UIColor(red: 0, green: 0, blue: 1.5, alpha: 1),
      format: .extendedRGB)

    let attachment1 = STUImageTextAttachment(
      image: grayscaleImage, verticalOffset: 0,
      stringRepresentation: "test")
    #expect(attachment1.width == imageSize.width)
    #expect(attachment1.ascent == imageSize.height)
    #expect(attachment1.descent == 0)
    #expect(attachment1.leading == 0)
    #expect(
      attachment1.imageBounds
        == CGRect(
          origin: CGPoint(x: 0, y: -imageSize.height),
          size: imageSize))
    #expect(attachment1.colorInfo == [.isGrayscale])
    #expect(attachment1.stringRepresentation == "test")
    #expect(attachment1.image == grayscaleImage)

    let offset = imageSize.height / 2

    let attachment2 = STUImageTextAttachment(
      image: extendedRGBImage,
      imageSize: imageSize,
      verticalOffset: offset,
      padding: UIEdgeInsets(
        top: 1, left: 2,
        bottom: 3, right: 4),
      leading: 5,
      stringRepresentation: "test 2")
    #expect(attachment2.width == imageSize.width + 2 + 4)
    #expect(attachment2.ascent == imageSize.height + 1 - offset)
    #expect(attachment2.descent == 3 + offset)
    #expect(attachment2.leading == 5)
    #expect(
      attachment2.imageBounds
        == CGRect(
          origin: CGPoint(x: 2, y: offset - imageSize.height),
          size: imageSize))
    #expect(attachment2.colorInfo == [.usesExtendedColors])
    #expect(attachment2.stringRepresentation == "test 2")
    #expect(attachment2.image == extendedRGBImage)

    let data = try NSKeyedArchiver.archivedData(
      withRootObject: attachment2, requiringSecureCoding: true)
    let attachment3 = try NSKeyedUnarchiver.unarchivedObject(
      ofClass: STUImageTextAttachment.self, from: data)!

    #expect(attachment3.width == imageSize.width + 2 + 4)
    #expect(attachment3.ascent == imageSize.height + 1 - offset)
    #expect(attachment3.descent == 3 + offset)
    #expect(attachment3.leading == 5)
    #expect(
      attachment3.imageBounds
        == CGRect(
          origin: CGPoint(x: 2, y: offset - imageSize.height),
          size: imageSize))
    #expect(attachment3.colorInfo == [.usesExtendedColors])
    #expect(attachment3.stringRepresentation == "test 2")
    #expect(attachment3.image.pngData() == extendedRGBImage.pngData())

    let tf = STUTextFrame(
      STUShapedString(
        NSAttributedString(stu_attachment: attachment3),
        defaultBaseWritingDirection: .leftToRight),
      size: CGSize(width: 100, height: 100), displayScale: 0)
    #expect(tf.lines.count == 1)
    #expect(tf.lines[0].nonTokenTextFlags.contains(.hasAttachment))
    #expect(tf.flags.contains(.usesExtendedColor))
    #expect(tf.lines[0].rangeInOriginalString == NSRange(0..<1))
    #expect(tf.lines[0].ascent == imageSize.height + 1 - offset)
    #expect(tf.lines[0].descent == 3 + offset)
    #expect(tf.lines[0].leading == 5)
    #expect(tf.lines[0].width == imageSize.width + 2 + 4)
    #expect(
      tf.imageBounds(frameOrigin: .zero)
        == CGRect(
          origin: CGPoint(
            x: 2,
            y: offset - imageSize.height
              + tf.lines[0].baselineOrigin.y),
          size: imageSize))

    assertSnapshot(of: image(tf), as: .image(perceptualPrecision: 0.99))
  }

  @Test
  func `Attachment conversion`() {
    let attachmentImage = createTestImage(CGSize(width: 10, height: 10))
    let attachment = NSTextAttachment()
    attachment.image = attachmentImage
    let attachmentString = NSAttributedString(attachment: attachment)
    let text = NSMutableAttributedString()
    text.append(attachmentString)
    text.append(NSAttributedString(string: "L", attributes: [.font: font]))
    text.append(attachmentString)
    text.append(attachmentString)
    let shapedString = STUShapedString(text)
    #expect(
      shapedString.attributedString.attribute(
        fixForRDAR36622225Key, at: 3,
        effectiveRange: nil) as! Int == 1)
    let tf = STUTextFrame(
      STUShapedString(text), size: CGSize(width: 100, height: 50),
      displayScale: displayScale, options: nil)

    assertSnapshot(of: image(tf), as: .image(perceptualPrecision: 0.99))
  }

  @Test
  func `Attachments in truncation token`() {
    let attachmentImage = createTestImage(CGSize(width: 10, height: 10))
    let attachment = NSTextAttachment()
    attachment.image = attachmentImage
    let attachmentString = NSAttributedString(attachment: attachment)
    let token = NSMutableAttributedString()
    token.append(attachmentString)
    token.append(NSAttributedString(string: "L", attributes: [.font: font]))
    token.append(attachmentString)
    token.append(attachmentString)
    let text = NSAttributedString(string: "This text doesn't fit", attributes: [.font: font])
    let options = STUTextFrameOptions { b in
      b.maximumNumberOfLines = 1
      b.truncationToken = token
    }
    let tf = STUTextFrame(
      STUShapedString(text), size: CGSize(width: 100, height: 50),
      displayScale: displayScale, options: options)

    assertSnapshot(of: image(tf), as: .image(perceptualPrecision: 0.99))
  }

  let ctRunDelegateKey = kCTRunDelegateAttributeName as NSAttributedString.Key
  let fixForRDAR36622225Key = NSAttributedString.Key(rawValue: "Fix for rdar://36622225")

  @Test
  func `Attributed string conversion from NSText attachments to STU text attachments`() {
    do {
      let string = NSAttributedString()
      #expect(
        string.stu_attributedStringByAddingCTRunDelegatesForSTUTextAttachments()
          === string)
    }

    do {
      let string = NSMutableAttributedString(string: "test")
      let result = string.stu_attributedStringByAddingCTRunDelegatesForSTUTextAttachments()
      #expect(result.isEqual(string))
      #expect(string !== result)
    }
    do {
      let nsAttachment = NSTextAttachment()
      let string = NSAttributedString(attachment: nsAttachment)
      #expect(
        string.stu_attributedStringByConvertingNSTextAttachmentsToSTUTextAttachments()
          .isEqual(string))

      nsAttachment.image = createTestImage(CGSize(width: 1, height: 1))
      let result = string.stu_attributedStringByConvertingNSTextAttachmentsToSTUTextAttachments()
      #expect(result.attribute(.stuAttachment, at: 0, effectiveRange: nil) != nil)
      #expect(result.attribute(ctRunDelegateKey, at: 0, effectiveRange: nil) != nil)
    }
    do {
      let nsAttachment = NSTextAttachment()
      nsAttachment.image = createTestImage(CGSize(width: 1, height: 1))
      let string = NSMutableAttributedString()
      string.append(NSAttributedString(string: "abc", attributes: [.attachment: nsAttachment]))
      string.append(NSAttributedString(string: "d", attributes: [:]))
      string.append(NSAttributedString(string: "e", attributes: [.attachment: nsAttachment]))
      string.append(NSAttributedString(string: "f", attributes: [.attachment: nsAttachment]))
      let result = string.stu_attributedStringByConvertingNSTextAttachmentsToSTUTextAttachments()
      for i in [0, 1, 2, 4, 5] {
        #expect(result.attribute(.stuAttachment, at: i, effectiveRange: nil) != nil)
        #expect(result.attribute(ctRunDelegateKey, at: i, effectiveRange: nil) != nil)
      }
      #expect(result.attribute(fixForRDAR36622225Key, at: 1, effectiveRange: nil) as! Int == 1)
      #expect(result.attribute(fixForRDAR36622225Key, at: 2, effectiveRange: nil) as! Int == 2)
      #expect(result.attribute(fixForRDAR36622225Key, at: 5, effectiveRange: nil) as! Int == 1)
    }
  }

  @Test
  func `Attributed string adds Core Text run delegates for STU text attachments`() {
    do {
      let string = NSAttributedString()
      #expect(
        string.stu_attributedStringByAddingCTRunDelegatesForSTUTextAttachments()
          === string)
    }

    do {
      let string = NSMutableAttributedString(string: "test")
      let result = string.stu_attributedStringByAddingCTRunDelegatesForSTUTextAttachments()
      #expect(result.isEqual(string))
      #expect(string !== result)
    }

    let attachment = STUTextAttachment(
      width: 1, ascent: 1, descent: 1, leading: 1,
      imageBounds: CGRect(), colorInfo: [],
      stringRepresentation: nil)
    let string = NSAttributedString([
      ("a", [.stuAttachment: attachment]),
      ("b", [:]),
      (
        "cde",
        [
          .stuAttachment: attachment,
          fixForRDAR36622225Key: 0,
        ]
      ),
    ])
    let result = string.stu_attributedStringByAddingCTRunDelegatesForSTUTextAttachments()
    let expected = NSAttributedString([
      (
        "a",
        [
          .stuAttachment: attachment,
          ctRunDelegateKey: attachment.newCTRunDelegate(),
        ]
      ),
      ("b", [:]),
      (
        "c",
        [
          .stuAttachment: attachment,
          ctRunDelegateKey: attachment.newCTRunDelegate(),
        ]
      ),
      (
        "d",
        [
          .stuAttachment: attachment,
          ctRunDelegateKey: attachment.newCTRunDelegate(),
          fixForRDAR36622225Key: 1,
        ]
      ),
      (
        "e",
        [
          .stuAttachment: attachment,
          ctRunDelegateKey: attachment.newCTRunDelegate(),
          fixForRDAR36622225Key: 2,
        ]
      ),
    ])
    #expect(result.string == expected.string)
    for i in 0..<expected.length {
      let attributes = expected.attributes(at: i, effectiveRange: nil)
      for (key, value) in attributes {
        #expect(
          (result.attribute(key, at: i, effectiveRange: nil) as! NSObject)
            .isEqual(value as! NSObject))
      }
    }
  }

  @Test
  func `Attributed string removes Core Text run delegates`() {
    do {
      let string = NSAttributedString()
      #expect(
        string.stu_attributedStringByRemovingCTRunDelegates()
          === string)
    }

    do {
      let string = NSMutableAttributedString(string: "test")
      let result = string.stu_attributedStringByRemovingCTRunDelegates()
      #expect(result.isEqual(string))
      #expect(string !== result)
    }

    let attachment = STUTextAttachment(
      width: 1, ascent: 1, descent: 1, leading: 1,
      imageBounds: CGRect(), colorInfo: [],
      stringRepresentation: nil)
    let delegate = attachment.newCTRunDelegate

    let string = NSAttributedString([
      ("a", [ctRunDelegateKey: delegate]),
      ("b", [:]),
      ("cde", [ctRunDelegateKey: delegate]),
    ])
    #expect(
      string.stu_attributedStringByRemovingCTRunDelegates()
        .isEqual(NSAttributedString(string: "abcde")))
  }

  @Test
  func `Attributed string replaces STU attachments with string representations`() {
    do {
      let string = NSAttributedString()
      #expect(
        string.stu_attributedStringByReplacingSTUAttachmentsWithStringRepresentations()
          === string)
    }

    do {
      let string = NSMutableAttributedString(string: "test")
      let result = string.stu_attributedStringByReplacingSTUAttachmentsWithStringRepresentations()
      #expect(result.isEqual(string))
      #expect(string !== result)
    }

    func attachment(_ stringRepresentation: String?) -> NSAttributedString {
      return NSAttributedString(
        stu_attachment:
          STUTextAttachment(
            width: 10, ascent: 5, descent: 5, leading: 0,
            imageBounds: CGRect(), colorInfo: [],
            stringRepresentation: stringRepresentation))
    }
    do {
      let string = attachment(nil)
      #expect(
        string.stu_attributedStringByReplacingSTUAttachmentsWithStringRepresentations()
          .isEqual(NSAttributedString()))
    }
    do {
      let string = NSMutableAttributedString()
      let a = attachment(nil)
      string.append(a)
      string.append(a)
      string.append(a)
      string.append(NSAttributedString(string: "x", attributes: [.font: font]))
      string.append(a)
      string.append(a)
      string.append(a)
      let result = string.stu_attributedStringByReplacingSTUAttachmentsWithStringRepresentations()
      let expected = NSAttributedString(string: "x", attributes: [.font: font])
      #expect(result.string == expected.string)
      #expect(result.isEqual(expected))
    }
    do {
      let string = NSMutableAttributedString()
      let a = attachment("a")
      string.append(a)
      string.append(a)
      string.append(a)
      string.append(NSAttributedString(string: "test", attributes: [.font: font]))
      let result = string.stu_attributedStringByReplacingSTUAttachmentsWithStringRepresentations()
      let expected = NSAttributedString(string: "aaatest", attributes: [.font: font])
      #expect(result.isEqual(expected))
    }
    do {
      let string = NSMutableAttributedString()
      let a = attachment("a")
      let b = attachment("b")
      string.append(a)
      string.append(a)
      string.append(a)
      string.append(b)
      string.append(b)
      string.append(b)
      let result = string.stu_attributedStringByReplacingSTUAttachmentsWithStringRepresentations()
      let expected = NSAttributedString(string: "aaabbb")
      #expect(result.isEqual(expected))
    }
    do {
      let string = NSMutableAttributedString()
      string.append(NSAttributedString(string: "a", attributes: [.font: font]))
      string.append(attachment(nil))
      string.append(NSAttributedString(string: "b ", attributes: [.font: font]))
      string.append(attachment(nil))
      string.append(NSAttributedString(string: "c", attributes: [.font: font]))
      string.append(attachment(nil))
      string.append(NSAttributedString(string: " d", attributes: [.font: font]))
      string.append(attachment(nil))
      string.append(attachment(nil))
      string.append(NSAttributedString(string: "e", attributes: [.font: font]))
      string.append(attachment("<"))
      string.append(attachment(">"))
      string.append(NSAttributedString(string: "f", attributes: [.font: font]))
      let result = string.stu_attributedStringByReplacingSTUAttachmentsWithStringRepresentations()
      let expected = NSAttributedString(string: "a b c d e<>f", attributes: [.font: font])
      #expect(result.string == expected.string)
      #expect(result.isEqual(expected))
    }

  }
}
