import ComposableArchitecture
import Foundation
import ProseBackend
import ProseCore

public struct AccountBookmark: Codable {
  public var jid: BareJid

  public init(jid: BareJid) {
    self.jid = jid
  }
}

public struct AccountBookmarksClient {
  public var loadBookmarks: () throws -> [AccountBookmark]
  public var saveBookmark: (AccountBookmark) throws -> Void
  public var removeBookmark: (BareJid) throws -> Void
}

public extension DependencyValues {
  var accountBookmarksClient: AccountBookmarksClient {
    get { self[AccountBookmarksClient.self] }
    set { self[AccountBookmarksClient.self] = newValue }
  }
}

extension AccountBookmarksClient: TestDependencyKey {
  public static var testValue = AccountBookmarksClient(
    loadBookmarks: unimplemented("\(Self.self).loadBookmarks"),
    saveBookmark: unimplemented("\(Self.self).saveBookmark"),
    removeBookmark: unimplemented("\(Self.self).removeBookmark")
  )
}
