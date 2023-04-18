//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import App
import Combine
import ComposableArchitecture
import SwiftUI
import Toolbox

struct RosterSelection: View {
  let store: Store<AppState, AppAction>

  init() {
    var env = AppEnvironment.test
    env.proseClient.roster = {
      Just(Roster.mock).eraseToFailingEffect()
    }
    env.proseClient.messagesInChat = { jid in
      // Only take the node so that the WebView doesn't highlight the URL which creates a separate
      // accessiblity element (a link).
      let name = String(jid.jidString.prefix(while: { $0 != "@" }))
      return Just([Message.mock(from: jid, body: "Hello from \(name)")]).eraseToFailingEffect()
    }

    self.store = .init(
      initialState: .authenticated,
      reducer: appReducer,
      environment: env
    )
  }

  public var body: some View {
    AppView(store: self.store)
  }
}
