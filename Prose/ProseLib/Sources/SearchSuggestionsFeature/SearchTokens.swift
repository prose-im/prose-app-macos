//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI
import UniformTypeIdentifiers

struct TokenView: View {
  var body: some View {
    Button { print("Test") } label: {
      HStack(spacing: 3) {
        Color.white
          .frame(width: 12, height: 12)
          .clipShape(RoundedRectangle(cornerRadius: 2))
          .frame(alignment: .leadingLastTextBaseline)
        Text("Very long text")
      }
      .padding(.horizontal, 3)
      .padding(.vertical, 1)
      .background {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.blue.opacity(0.25))
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

final class MyAttachment: NSTextAttachment {
  static let fileType: UTType = .utf8PlainText

  init(jid: String) {
    let data: Data = jid.data(using: .utf8)!
    super.init(data: data, ofType: Self.fileType.identifier)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func attachmentBounds(
    for attributes: [NSAttributedString.Key: Any],
    location: NSTextLocation,
    textContainer: NSTextContainer?,
    proposedLineFragment: CGRect,
    position: CGPoint
  ) -> CGRect {
    fatalError("This should not be called (or it should, but AppKit doesn't call this one)")
  }

  override func attachmentBounds(
    for textContainer: NSTextContainer?,
    proposedLineFragment lineFrag: CGRect,
    glyphPosition position: CGPoint,
    characterIndex charIndex: Int
  ) -> CGRect {
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
    self.tracksTextAttachmentViewBounds = true
  }

  override func loadView() {
    let view = NSHostingView(rootView: TokenView())
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
}

extension AttributedString {
  /// Appends a space to the receiver.
  func appendingSpace() -> AttributedString {
    var copy = self
    copy.append(AttributedString(" ", attributes: AttributeContainer(vanillaSearchSuggestionsFieldDefaultTextAttributes)))
    return copy
  }
}
