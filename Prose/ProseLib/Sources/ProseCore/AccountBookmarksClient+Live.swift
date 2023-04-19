//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
import Foundation
import ProseCoreFFI

extension AccountBookmarksClient {
  static func live(
    bookmarksURL: URL = URL.documentsDirectory
      .appending(component: "accounts.json")
  ) -> Self {
    let client = ProseCoreFFI.AccountBookmarksClient(bookmarksPath: bookmarksURL)

    return .init(
      loadBookmarks: {
        try client.loadBookmarks()
      },
      addBookmark: { jid in
        try await Task {
          try client.addBookmark(jid: jid, selectBookmark: true)
        }.result.get()
      },
      removeBookmark: { jid in
        try await Task {
          try client.removeBookmark(jid: jid)
        }.result.get()
      },
      selectBookmark: { jid in
        try await Task {
          try client.selectBookmark(jid: jid)
        }.result.get()
      }
    )
  }
}

extension AccountBookmarksClient: DependencyKey {
  public static var liveValue: AccountBookmarksClient = .live()
}
