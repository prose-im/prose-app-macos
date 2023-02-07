//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import EditProfileFeature
import ProseCoreTCA
import SwiftUI
import TcaHelpers

private let l10n = L10n.Sidebar.Footer.self

// MARK: - View

/// The small bar at the bottom of the left sidebar.
struct Footer: View {
  typealias State = SessionState<FooterState>
  typealias Action = FooterAction

  struct ViewState: Equatable {
    let isShowingSheet: Bool
    let jidString: String
    let statusIcon: Character
    let statusMessage: String
    let currentUser: UserInfo
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
          state: { route in
            CasePath(FooterState.Sheet.editProfile).extract(from: route)
              .map { SessionState(currentUser: self.viewStore.currentUser, childState: $0) }
          },
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
    self.jidString = state.currentUser.jid.rawValue
    self.statusIcon = state.childState.statusIcon
    self.statusMessage = state.childState.statusMessage
    self.currentUser = state.currentUser
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let footerReducer: AnyReducer<
  SessionState<FooterState>,
  FooterAction,
  SidebarEnvironment
> = AnyReducer.combine([
  footerActionMenuReducer.pullback(
    state: \.actionButton,
    action: CasePath(FooterAction.actionButton),
    environment: { _ in () }
  ),
  footerAvatarReducer.pullback(
    state: \.avatar,
    action: CasePath(FooterAction.avatar),
    environment: { _ in () }
  ),
  editProfileReducer.optional().pullback(
    state: \.editProfile,
    action: CasePath(FooterAction.editProfile),
    environment: { $0.editProfile }
  ),
  AnyReducer { state, action, _ in
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
  let teamName: String
  let statusIcon: Character
  let statusMessage: String

  var avatar = FooterAvatarState()
  var actionButton: FooterActionMenuState

  @BindingState var sheet: Sheet?

  init(
    teamName: String = "Crisp",
    statusIcon: Character = "🚀",
    statusMessage: String = "Building new features.",
    actionButton: FooterActionMenuState = .init()
  ) {
    self.teamName = teamName
    self.statusIcon = statusIcon
    self.statusMessage = statusMessage
    self.actionButton = actionButton
  }
}

private extension SessionState where ChildState == FooterState {
  var avatar: SessionState<FooterAvatarState> {
    get { self.get(\.avatar) }
    set { self.set(\.avatar, newValue) }
  }

  var editProfile: SessionState<EditProfileState>? {
    get { self.get(FooterState.Sheet.Paths.editProfile) }
    set { self.set(FooterState.Sheet.Paths.editProfile, newValue) }
  }
}

public extension FooterState {
  enum Sheet: Equatable {
    case editProfile(EditProfileState)
  }
}

extension FooterState.Sheet {
  enum Paths {
    static let editProfile: OptionalPath = (\FooterState.sheet)
      .case(CasePath(FooterState.Sheet.editProfile))
  }
}

// MARK: Actions

public enum FooterAction: Equatable, BindableAction {
  case dismissSheet
  case avatar(FooterAvatarAction)
  case actionButton(FooterActionMenuAction)
  case editProfile(EditProfileAction)
  case binding(BindingAction<SessionState<FooterState>>)
}

// MARK: Environment

extension SidebarEnvironment {
  var editProfile: EditProfileEnvironment {
    EditProfileEnvironment(proseClient: self.proseClient, mainQueue: self.mainQueue)
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
      let state = SessionState.mock(FooterState())
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
