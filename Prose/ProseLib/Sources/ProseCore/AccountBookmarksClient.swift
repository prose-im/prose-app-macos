//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation

public struct AccountBookmarksClient {
  public var loadBookmarks: () throws -> [AccountBookmark]
  public var addBookmark: (BareJid) async throws -> Void
  public var removeBookmark: (BareJid) async throws -> Void
  public var selectBookmark: (BareJid) async throws -> Void
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
    addBookmark: unimplemented("\(Self.self).saveBookmark"),
    removeBookmark: unimplemented("\(Self.self).removeBookmark"),
    selectBookmark: unimplemented("\(Self.self).selectBookmark")
  )
}
