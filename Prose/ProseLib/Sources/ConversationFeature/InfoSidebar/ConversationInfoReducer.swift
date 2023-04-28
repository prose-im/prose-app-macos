//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation
import ProseCore

public struct ConversationInfoReducer: ReducerProtocol {
  public typealias State = ChatSessionState<ConversationInfoState>

  public struct ConversationInfoState: Equatable {
    @BindingState var identityPopover: IdentityPopoverState?

    var userProfile: UserProfile?

    public init() {}
  }

  public enum Action: Equatable, BindableAction {
    case onAppear
    case onDisappear

    case startCallButtonTapped
    case sendEmailButtonTapped

    case showIdVerificationInfoTapped
    case showEncryptionInfoTapped
    case identityPopover(IdentityPopoverAction)
    case binding(BindingAction<State>)

    case viewSharedFilesTapped
    case encryptionSettingsTapped
    case removeContactTapped
    case blockContactTapped

    case userProfileResult(TaskResult<UserProfile?>)
  }

  private enum EffectToken: Hashable, CaseIterable {
    case loadUserProfile
  }

  public init() {}

  @Dependency(\.openURL) var openURL
  @Dependency(\.accountsClient) var accounts

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .task { [accountId = state.selectedAccountId, userId = state.chatId] in
          await .userProfileResult(
            TaskResult {
              try await self.accounts.client(accountId).loadProfile(userId, .default)
            }
          )
        }.cancellable(id: EffectToken.loadUserProfile)

      case .onDisappear:
        return .cancel(token: EffectToken.self)

      case .startCallButtonTapped:
        guard let tel = state.userProfile?.email, let url = URL(string: "tel:\(tel)") else {
          return .none
        }
        return .fireAndForget {
          await self.openURL(url)
        }

      case .sendEmailButtonTapped:
        guard let email = state.userProfile?.email, let url = URL(string: "mailto:\(email)") else {
          return .none
        }
        return .fireAndForget {
          await self.openURL(url)
        }

      case .showIdVerificationInfoTapped:
        state.identityPopover = IdentityPopoverState()
        return .none

      case .showEncryptionInfoTapped:
        logger.info("Show encryption info tapped")
        return .none

      case .identityPopover, .binding:
        return .none

      case .viewSharedFilesTapped:
        logger.info("View shared files tapped")
        return .none

      case .encryptionSettingsTapped:
        logger.info("Encryption settings tapped")
        return .none

      case .removeContactTapped:
        logger.info("Remove contact tapped")
        return .none

      case .blockContactTapped:
        logger.info("Block tapped")
        return .none

      case let .userProfileResult(.success(profile)):
        state.userProfile = profile
        return .none

      case let .userProfileResult(.failure(error)):
        logger.error("Failed to load user profile. \(error.localizedDescription)")
        return .none
      }
    }
  }
}
