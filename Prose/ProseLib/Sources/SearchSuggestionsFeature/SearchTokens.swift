//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI
import UniformTypeIdentifiers

struct JIDTokenView: View {
  let name: String

  var body: some View {
    Button { print("Tapped token '\(name)'") } label: {
      HStack(spacing: 3) {
        Color.white
          .frame(width: 13, height: 13)
          .clipShape(RoundedRectangle(cornerRadius: 2))
          .frame(alignment: .leadingLastTextBaseline)
        Text(verbatim: self.name)
      }
      .padding(.horizontal, 3)
      .padding(.vertical, 1)
      .background {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.blue.opacity(0.375))
      }
    }
//    .font(.system(size: 12))
//    .padding(.horizontal, 2)
    .buttonStyle(.plain)
//    .foregroundColor(.white)
    .fixedSize()
//    .frame(alignment: .leadingLastTextBaseline)
  }
}

public final class JIDAttachment: NSTextAttachment {
  static let fileType: UTType = .utf8PlainText

  public let jid: String
  let displayName: String

  public init(jid: String, displayName: String) {
    self.jid = jid
    self.displayName = displayName

    let data: Data = jid.data(using: .utf8)!
    super.init(data: data, ofType: Self.fileType.identifier)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func attachmentBounds(
    for attributes: [NSAttributedString.Key: Any],
    location: NSTextLocation,
    textContainer: NSTextContainer?,
    proposedLineFragment: CGRect,
    position: CGPoint
  ) -> CGRect {
    let bounds = super.attachmentBounds(
      for: attributes,
      location: location,
      textContainer: textContainer,
      proposedLineFragment: proposedLineFragment,
      position: position
    )
    // NOTE: SwiftUI's `.frame(alignment: .leadingLastTextBaseline)` aligns the baselines perfectly,
    //       but it causes line height issues. The `-4` magic number seems to align pretty well.
    return bounds.offsetBy(dx: 0, dy: -4)
  }

  override public func attachmentBounds(
    for textContainer: NSTextContainer?,
    proposedLineFragment lineFrag: CGRect,
    glyphPosition position: CGPoint,
    characterIndex charIndex: Int
  ) -> CGRect {
    assertionFailure("This should not be called, but let's make sure")
    let bounds = super.attachmentBounds(
      for: textContainer,
      proposedLineFragment: lineFrag,
      glyphPosition: position,
      characterIndex: charIndex
    )
    // NOTE: SwiftUI's `.frame(alignment: .leadingLastTextBaseline)` aligns the baselines perfectly,
    //       but it causes line height issues. The `-4` magic number seems to align pretty well.
    return bounds.offsetBy(dx: 0, dy: -4)
  }
}

class MyTextAttachmentViewProvider: NSTextAttachmentViewProvider {
  override init(
    textAttachment: NSTextAttachment,
    parentView: NSView?,
    textLayoutManager: NSTextLayoutManager?,
    location: NSTextLocation
  ) {
    super.init(
      textAttachment: textAttachment,
      parentView: parentView,
      textLayoutManager: textLayoutManager,
      location: location
    )
    // NOTE: [Rémi Bardon] This is a `{ get set }` property, so I couldn't simply override it.
    self.tracksTextAttachmentViewBounds = true
  }

  override func loadView() {
    guard let attachment: JIDAttachment = self.textAttachment as? JIDAttachment
    else { fatalError() }
    let view = NSHostingView(rootView: JIDTokenView(name: attachment.displayName))
    self.view = view
  }
}

extension NSAttributedString {
  /// Initializes a new `NSAttributedString` with the given `NSTextAttachment` and applies
  /// `attributes` to it.
  convenience init(attachment: NSTextAttachment, attributes: [NSAttributedString.Key: Any]) {
    var attributes = attributes
    attributes[.attachment] = attachment
    self.init(
      string: String(Character(UnicodeScalar(NSTextAttachment.character)!)),
      attributes: attributes
    )
  }

  /// Appends a space to the receiver.
  func appendingSpace() -> NSAttributedString {
    let mutableCopy = NSMutableAttributedString(attributedString: self)
    mutableCopy.append(NSAttributedString(string: " ", attributes: defaultTextAttributes))
    return mutableCopy
  }
}
