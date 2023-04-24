//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import ComposableArchitecture
@testable import EditProfileFeature
import Mocks
import ProseCore
import SwiftUI

@main
struct EditProfileFeaturePreviewApp: App {
  let store: StoreOf<EditProfileReducer>

  init() {
    var state = EditProfileReducer.EditProfileState()
    state.route = .profile(.init())

    self.store = Store(
      initialState: .mock(state),
      reducer: EditProfileReducer(),
      prepareDependencies: {
        var accountsClient = AccountsClient.noop
        accountsClient.client = { _ in .noop }
        $0.accountsClient = accountsClient
      }
    )
  }

  var body: some Scene {
    WindowGroup {
      EditProfileScreen(store: self.store)
    }
  }
}
