//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import EditProfileFeature
import SwiftUI

@main
struct EditProfileFeaturePreviewApp: App {
  var body: some Scene {
    WindowGroup {
      EditProfileScreen(store: Store(
        initialState: .mock(EditProfileState(
          sidebarHeader: .init(),
          route: .profile(.init())
        )),
        reducer: editProfileReducer,
        environment: EditProfileEnvironment(proseClient: .noop, mainQueue: .main)
      ))
    }
  }
}
