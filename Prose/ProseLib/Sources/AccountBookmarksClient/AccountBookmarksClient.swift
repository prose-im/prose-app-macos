import ComposableArchitecture
import Foundation
import ProseBackend
import ProseCore

public struct AccountBookmark: Codable {
  public var jid: BareJid
  public var isSelected: Bool

  public init(jid: BareJid, isSelected: Bool) {
    self.jid = jid
    self.isSelected = isSelected
  }
}

public struct AccountBookmarksClient {
  public var loadBookmarks: () throws -> [AccountBookmark]
  public var saveBookmark: (BareJid, _ select: Bool) throws -> Void
  public var selectBookmark: (BareJid) throws -> Void
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
    selectBookmark: unimplemented("\(Self.self).selectBookmark"),
    removeBookmark: unimplemented("\(Self.self).removeBookmark")
  )
}
