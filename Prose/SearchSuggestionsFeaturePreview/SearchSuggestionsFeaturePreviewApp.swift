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
//      AutoSuggestListPreview(.init(
      AutoSuggestWindowPreview(.init(
        content: .loaded([
          .init(title: "Section 1", items: AutoSuggestWindowPreview.items(4)),
          .init(title: "Section 2", items: AutoSuggestWindowPreview.items(1)),
          .init(title: "Section 3", items: []),
          .init(title: "Section 4", items: AutoSuggestWindowPreview.items(3)),
        ])
      ))
    }
  }
}
