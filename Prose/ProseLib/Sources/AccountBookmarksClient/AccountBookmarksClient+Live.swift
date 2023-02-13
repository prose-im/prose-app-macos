import ComposableArchitecture
import Foundation

public extension AccountBookmarksClient {
  static func live(bookmarksURL: URL = URL.documentsDirectory
    .appending(component: "accounts.plist")) -> Self
  {
    print("bookmarksURL", bookmarksURL)

    func loadBookmarks() throws -> [AccountBookmark] {
      guard FileManager.default.fileExists(atPath: bookmarksURL.path) else {
        return []
      }
      return try PropertyListDecoder().decode(
        [AccountBookmark].self,
        from: Data(contentsOf: bookmarksURL)
      )
    }

    func saveBookmarks(_ bookmarks: [AccountBookmark]) throws {
      try PropertyListEncoder().encode(bookmarks).write(to: bookmarksURL, options: [.atomic])
    }

    return .init(
      loadBookmarks: loadBookmarks,
      saveBookmark: { jid, selectBookmark in
        var bookmarks = try loadBookmarks()
        bookmarks.removeAll(where: { $0.jid == jid })

        if selectBookmark {
          for idx in bookmarks.indices {
            bookmarks[idx].isSelected = false
          }
        }

        bookmarks.append(.init(jid: jid, isSelected: selectBookmark))
        try saveBookmarks(bookmarks)
      },
      selectBookmark: { jid in
        var bookmarks = try loadBookmarks()
        for idx in bookmarks.indices {
          bookmarks[idx].isSelected = bookmarks[idx].jid == jid
        }
        try saveBookmarks(bookmarks)
      },
      removeBookmark: { jid in
        var bookmarks = try loadBookmarks()
        bookmarks.removeAll(where: { $0.jid == jid })
        try saveBookmarks(bookmarks)
      }
    )
  }
}

extension AccountBookmarksClient: DependencyKey {
  public static var liveValue: AccountBookmarksClient = .live()
}
