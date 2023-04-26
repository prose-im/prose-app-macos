//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import CredentialsClient
import Foundation
import ProseCore

public struct AccountSettingsMenuReducer: ReducerProtocol {
  public typealias State = SessionState<AccountSettingsMenuState>

  public struct AccountSettingsMenuState: Equatable {
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
        return .fireAndForget { [jid = state.currentUser] in
          try? await self.accountBookmarks.removeBookmark(jid)
          try? self.credentials.deleteCredentials(jid)
          self.accounts.removeAccount(jid)
        }

      case .accountSettingsTapped:
        return .none

      case let .changeAvailabilityTapped(availability):
        state.selectedAccount.availability = availability
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
