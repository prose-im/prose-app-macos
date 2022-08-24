//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
@testable import ProseUI
import SwiftUI

struct ContentView: View {
  struct Preview: View {
    let store: Store<TCATextView.ViewState, TCATextView.ViewAction>
    var body: some View {
      VStack(alignment: .leading) {
        TCATextView(store: self.store)
        WithViewStore(self.store) { viewStore in
          VStack(alignment: .leading) {
            let attributedString = NSAttributedString(viewStore.text)

            Text(
              "Text: \"\(attributedString.string.replacingOccurrences(of: "\n", with: #"\n"#))\""
            )
            Text("Length: \(attributedString.length)")
            Text(
              "Contains attachments: \(String(describing: attributedString.containsAttachments))"
            )

            Text("Selection range: \(String(describing: viewStore.selection))")

            let selectedText: String? = viewStore.selection
              .map(attributedString.attributedSubstring(from:))
              .map { $0.string.replacingOccurrences(of: "\n", with: #"\n"#) }
            Text("Selected text: \(String(describing: selectedText))")

//          let rangeFromLastAttachment: NSRange? = viewStore.selection
//            .map(attributedString.prose_rangeFromLastAttachmentToCaret(selectionRange:))
//          Text("Range to last attachment: \(String(describing: rangeFromLastAttachment))")

//          let textFromLastAttachment: NSAttributedString? = rangeFromLastAttachment
//            .map(attributedString.attributedSubstring(from:))
//          Text("Text to last attachment: \(String(describing: textFromLastAttachment?.string))")
          }
        }
        .frame(maxHeight: .infinity, alignment: .top)
      }
      .padding()
      .background(Color(nsColor: .textBackgroundColor))
      .frame(minWidth: 300)
//      .fixedSize()
    }
  }

  var body: some View {
    Preview(store: Store(
      initialState: TCATextViewState(),
      reducer: textViewReducer,
      environment: ()
    ))
    .previewDisplayName("Default")
//    Preview(store: Store(
//      initialState: TCATextViewState(
//        height: 24,
//        cornerRadius: 12,
//        textContainerInset: NSSize(width: 8, height: 5),
//        showFocusRing: false
//      ),
//      reducer: textViewReducer,
//      environment: ()
//    ))
//    .previewDisplayName("Rounded")
//    Preview(store: Store(
//      initialState: TCATextViewState(
//        height: 48,
//        borderWidth: 4,
//        cornerRadius: 0,
//        showFocusRing: false
//      ),
//      reducer: textViewReducer,
//      environment: ()
//    ))
//    .previewDisplayName("Squared")
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
