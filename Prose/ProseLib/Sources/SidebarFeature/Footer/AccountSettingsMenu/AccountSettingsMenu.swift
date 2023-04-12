//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AccountBookmarksClient
import AppDomain
import ComposableArchitecture
import CredentialsClient
import Foundation
import ProseBackend
import ProseCoreTCA

public struct AccountSettingsMenu: ReducerProtocol {
  public struct State: Equatable {
    var availability: Availability
    var avatar: URL?
    var fullName: String
    var jid: BareJid
    var statusIcon: Character
  }

  public enum Action: Equatable {
    case accountSettingsTapped
    case changeAvailabilityTapped(Availability)
    case editProfileTapped
    case offlineModeTapped
    case pauseNotificationsTapped
    case signOutTapped
    case updateMoodTapped
  }

  @Dependency(\.accountBookmarksClient) var accountBookmarks
  @Dependency(\.accountsClient) var accounts
  @Dependency(\.credentialsClient) var credentials

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .signOutTapped:
        return .fireAndForget { [jid = state.jid] in
          try? self.accountBookmarks.removeBookmark(jid)
          try? self.credentials.deleteCredentials(jid)
          try await self.accounts.disconnectAccount(jid)
        }

      case .accountSettingsTapped:
        return .none

      case .changeAvailabilityTapped:
        return .none

      case .editProfileTapped:
        return .none

      case .offlineModeTapped:
        return .none

      case .pauseNotificationsTapped:
        return .none

      case .updateMoodTapped:
        return .none
      }
    }
  }
}
