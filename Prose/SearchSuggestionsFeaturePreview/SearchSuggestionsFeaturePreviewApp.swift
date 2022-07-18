//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

@main
struct SearchSuggestionsFeaturePreviewApp: App {
  var body: some Scene {
    WindowGroup {
//      NaivePreview()
//        .frame(maxWidth: 512)
      AutoSuggestListPreview(.init(
        content: .loaded([
          .init(
            title: "Section 1",
            items: Array(repeating: AutoSuggestListPreview.State.Item.init, count: 4).map { $0() }
          ),
          .init(
            title: "Section 2",
            items: Array(repeating: AutoSuggestListPreview.State.Item.init, count: 1).map { $0() }
          ),
          .init(title: "Section 3", items: []),
          .init(
            title: "Section 4",
            items: Array(repeating: AutoSuggestListPreview.State.Item.init, count: 3).map { $0() }
          ),
        ])
      ))
    }
  }
}
