//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import EditProfileFeature
import SwiftUI

private let l10n = L10n.Sidebar.Footer.self

// MARK: - View

/// The small bar at the bottom of the left sidebar.
struct Footer: View {
  typealias State = FooterState
  typealias Action = FooterAction

  struct ViewState: Equatable {
    let isShowingSheet: Bool
    let jidString: String
    let statusIcon: Character
    let statusMessage: String
  }

  static let height: CGFloat = 64

  private let store: Store<State, Action>
  @ObservedObject private var viewStore: ViewStore<ViewState, Action>

  public init(store: Store<State, Action>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  var body: some View {
    VStack(spacing: 0) {
      Divider()

      HStack(spacing: 12) {
        // User avatar
        FooterAvatar(store: self.store.scope(state: \.avatar, action: Action.avatar))

        // Team name + user status
        FooterDetails(
          teamName: self.viewStore.jidString,
          statusIcon: self.viewStore.statusIcon,
          statusMessage: self.viewStore.statusMessage
        )
        .layoutPriority(1)

        // Quick actions button
        FooterActionMenu(
          store: self.store.scope(state: \.actionButton, action: Action.actionButton)
        )
      }
      .padding(.leading, 20.0)
      .padding(.trailing, 14.0)
      .frame(maxHeight: 64)
    }
    .frame(height: Self.height)
    .accessibilityElement(children: .contain)
    .accessibilityLabel(l10n.label)
    .sheet(
      isPresented: self.viewStore.binding(get: \.isShowingSheet, send: .dismissSheet),
      content: self.sheet
    )
  }

  func sheet() -> some View {
    IfLetStore(self.store.scope(state: \.sheet)) { store in
      SwitchStore(store) {
        CaseLet(
          state: CasePath(State.Sheet.editProfile).extract(from:),
          action: Action.editProfile,
          then: EditProfileScreen.init(store:)
        )
      }
    }
  }
}

extension Footer.ViewState {
  init(_ state: Footer.State) {
    self.isShowingSheet = state.sheet != nil
    self.jidString = state.credentials.jidString
    self.statusIcon = state.statusIcon
    self.statusMessage = state.statusMessage
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let footerReducer: Reducer<
  FooterState,
  FooterAction,
  SidebarEnvironment
> = Reducer.combine([
  footerActionMenuReducer.pullback(
    state: \FooterState.actionButton,
    action: CasePath(FooterAction.actionButton),
    environment: { _ in () }
  ),
  footerAvatarReducer.pullback(
    state: \FooterState.avatar,
    action: CasePath(FooterAction.avatar),
    environment: { _ in () }
  ),
  editProfileReducer.pullback(
    state: CasePath(FooterState.Sheet.editProfile),
    action: .self,
    environment: { $0 }
  ).optional().pullback(
    state: \FooterState.sheet,
    action: CasePath(FooterAction.editProfile),
    environment: { (env: SidebarEnvironment) in env.editProfile }
  ),
  Reducer { state, action, _ in
    switch action {
    case .dismissSheet, .editProfile(.cancelTapped):
      state.sheet = nil
      return .none

    case .avatar(.editProfileTapped):
      state.sheet = .editProfile(EditProfileState(
        sidebarHeader: SidebarHeaderState(),
        route: .identity(IdentityState())
      ))
      return .none

    case .actionButton, .avatar, .editProfile, .binding:
      return .none
    }
  }.binding(),
])

// MARK: State

public struct FooterState: Equatable {
  let credentials: UserCredentials
  let teamName: String
  let statusIcon: Character
  let statusMessage: String

  var avatar: FooterAvatarState
  var actionButton: FooterActionMenuState

  @BindableState var sheet: Sheet?

  init(
    credentials: UserCredentials,
    teamName: String = "Crisp",
    statusIcon: Character = "🚀",
    statusMessage: String = "Building new features.",
    avatar: FooterAvatarState = .init(avatar: .placeholder),
    actionButton: FooterActionMenuState = .init(),
    sheet: Sheet? = nil
  ) {
    self.credentials = credentials
    self.teamName = teamName
    self.statusIcon = statusIcon
    self.statusMessage = statusMessage
    self.avatar = avatar
    self.actionButton = actionButton
    self.sheet = sheet
  }
}

public extension FooterState {
  enum Sheet: Equatable {
    case editProfile(EditProfileState)
  }
}

// MARK: Actions

public enum FooterAction: Equatable, BindableAction {
  case dismissSheet
  case avatar(FooterAvatarAction)
  case actionButton(FooterActionMenuAction)
  case editProfile(EditProfileAction)
  case binding(BindingAction<FooterState>)
}

// MARK: Environment

extension SidebarEnvironment {
  var editProfile: EditProfileEnvironment {
    EditProfileEnvironment()
  }
}

// MARK: - Previews

#if DEBUG
  import PreviewAssets

  struct Footer_Previews: PreviewProvider {
    private struct Preview: View {
      let state: Footer.State

      var body: some View {
        Footer(store: Store(
          initialState: state,
          reducer: footerReducer,
          environment: .init(proseClient: .noop, mainQueue: .main)
        ))
      }
    }

    static var previews: some View {
      let state = FooterState(credentials: "valerian@crisp.chat")
      Preview(state: state)
        .preferredColorScheme(.light)
        .previewDisplayName("Light")
      Preview(state: state)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark")
      Preview(state: state)
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
