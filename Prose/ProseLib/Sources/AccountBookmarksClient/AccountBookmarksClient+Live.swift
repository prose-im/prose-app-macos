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
      saveBookmark: { bookmark in
        var bookmarks = try loadBookmarks()
        bookmarks.removeAll(where: { $0.jid == bookmark.jid })
        bookmarks.append(bookmark)
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
