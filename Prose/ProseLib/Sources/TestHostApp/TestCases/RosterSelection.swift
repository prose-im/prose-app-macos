//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

@testable import App
import Combine
import ComposableArchitecture
@testable import ProseCore
import SwiftUI
import Toolbox

struct RosterSelection: View {
  let store: StoreOf<AppReducer>

  init() {
    var coreClient = ProseCoreClient.noop
    coreClient.loadLatestMessages = { jid, _, _ in
      // Only take the node so that the WebView doesn't highlight the URL which creates a separate
      // accessiblity element (a link).
      let name = String(jid.rawValue.prefix(while: { $0 != "@" }))
      return [Message.mock(from: jid, body: "Hello from \(name)")]
    }

    var accountsClient = AccountsClient.noop
    accountsClient.client = { _ in coreClient }

    self.store = .init(
      initialState: .authenticated,
      reducer: AppReducer(),
      prepareDependencies: { deps in
        deps.accountBookmarksClient = .testValue
        deps.accountsClient = accountsClient
        deps.connectivityClient = .previewValue
        deps.credentialsClient = .noop
        deps.openURL = .init(handler: { url in
          logger.info("Not opening url \(url.absoluteString) in UITest.")
          return true
        })
      }
    )
  }

  public var body: some View {
    AppView(store: self.store)
  }
}
