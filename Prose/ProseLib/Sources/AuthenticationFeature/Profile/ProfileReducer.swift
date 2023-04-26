//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import AppLocalization
import ComposableArchitecture
import Foundation
import ProseCore

public struct ProfileReducer: ReducerProtocol {
  public struct State: Equatable {
    let credentials: Credentials
    let userProfile: UserProfile?

    @BindingState var fullName: String
    @BindingState var title: String
    var avatar: URL?

    var isLoading = false
    var alert: AlertState<Action>?
    @BindingState var focusedField: Field?

    init(userData: UserData) {
      self.userProfile = userData.profile
      self.credentials = userData.credentials

      self.fullName = userData.profile?.fullName ?? ""
      self.title = userData.profile?.title ?? ""
      self.avatar = userData.avatar
    }
  }

  public enum Action: Equatable, BindableAction {
    case submitButtonTapped
    case alertDismissed
    case fieldSubmitted(Field)

    case binding(BindingAction<State>)

    case saveProfileResult(TaskResult<Credentials>)
  }

  public enum Field: String, Hashable {
    case fullName
    case title
  }

  private enum EffectToken: Hashable, CaseIterable {
    case save
  }

  @Dependency(\.accountsClient) var accounts

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .submitButtonTapped where state.isLoading:
        return .cancel(id: EffectToken.save)

      case .submitButtonTapped, .fieldSubmitted(.title):
        state.isLoading = true
        state.focusedField = nil

        return .task { [state] in
          await .saveProfileResult(
            TaskResult {
              try await withTaskCancellation(id: EffectToken.save) {
                var profile = state.userProfile ?? UserProfile()
                profile.fullName = state.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
                profile.title = state.title.trimmingCharacters(in: .whitespacesAndNewlines)

                try await self.accounts.ephemeralClient(state.credentials.jid).saveProfile(profile)
                return state.credentials
              }
            }
          )
        }

      case .fieldSubmitted(.fullName):
        state.focusedField = .title
        return .none

      case .alertDismissed:
        state.alert = nil
        return .none

      case let .saveProfileResult(.failure(error)):
        state.isLoading = false
        state.alert = .init(
          title: TextState(L10n.Authentication.Profile.Error.title),
          message: TextState(error.localizedDescription)
        )
        return .none

      case .binding, .saveProfileResult:
        return .none
      }
    }
  }
}
