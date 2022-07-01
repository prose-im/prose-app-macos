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
          .frame(width: 10, height: 10)
          .clipShape(RoundedRectangle(cornerRadius: 2))
        Text("Very long text")
          .font(.system(size: 10))
          .foregroundColor(.white)
      }
      .padding(.horizontal, 3)
      .padding(.vertical, 1)
      .frame(width: 128, height: 8)
      .background {
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.blue.opacity(0.25))
      }
    }
    .buttonStyle(.plain)
    .fixedSize()
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
    let rect = super.attachmentBounds(
      for: attributes,
      location: location,
      textContainer: textContainer,
      proposedLineFragment: proposedLineFragment,
      position: position
    )
    return rect
  }
}

class MyTextAttachmentViewProvider: NSTextAttachmentViewProvider {
//  override init(textAttachment: NSTextAttachment, parentView: NSView?, textLayoutManager: NSTextLayoutManager?, location: NSTextLocation) {
//    super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
//
//    let view = NSHostingView(rootView: TokenView())
  ////    view.setFrameSize(NSSize(width: 24, height: 8))
  ////    view.backgroundColor = .systemRed
//    self.view = view
//
//    textAttachment.bounds = CGRect(x: 0, y: 0, width: 15, height: 15)
//  }

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
//    view.setFrameSize(NSSize(width: 24, height: 4))
    self.view = view
  }

  override func attachmentBounds(
    for _: [NSAttributedString.Key: Any],
    location _: NSTextLocation,
    textContainer _: NSTextContainer?,
    proposedLineFragment _: CGRect,
    position _: CGPoint
  ) -> CGRect {
    fatalError()
  }

//  override func loadView() {
//    let view = NSView()
//    view.wantsLayer = true
//    view.layer?.backgroundColor = NSColor.purple.cgColor
//    view.setFrameSize(NSSize(width: 4, height: 4))
//    self.view = view
//  }
}
