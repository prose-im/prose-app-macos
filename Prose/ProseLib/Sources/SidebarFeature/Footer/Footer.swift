import ComposableArchitecture
import EditProfileFeature
import ProseCoreTCA

public struct Footer: ReducerProtocol {
  public typealias State = SessionState<FooterState>

  public struct FooterState: Equatable {
    var route: Route?
    var teamName = "<Unknown>"
    var availability = Availability.available
    var statusIcon = Character("🚀")
    var statusMessage = "<Unimplemented>"

    public init() {}
  }

  public enum Action: Equatable {
    case setRoute(Route.Tag?)

    case accountSettingsMenu(AccountSettingsMenu.Action)
    case accountSwitcherMenu(AccountSwitcherMenu.Action)
    case editProfile(EditProfileAction)
  }

  public enum Route: Equatable {
    case accountSettingsMenu(AccountSettingsMenu.State)
    case accountSwitcherMenu(AccountSwitcherMenu.State)
    case editProfile(SessionState<EditProfileState>)
  }

  public init() {}

  @Dependency(\.legacyProseClient) var legacyProseClient
  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.accountSettingsMenu, action: /Action.accountSettingsMenu) {
          AccountSettingsMenu()
        }
        .ifCaseLet(/Route.accountSwitcherMenu, action: /Action.accountSwitcherMenu) {
          AccountSwitcherMenu()
        }
        .ifCaseLet(/Route.editProfile, action: /Action.editProfile) {
          Reduce(
            editProfileReducer,
            environment: EditProfileEnvironment(
              proseClient: self.legacyProseClient,
              mainQueue: self.mainQueue
            )
          )
        }
    }

    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .setRoute(.none):
        state.route = nil
        return .none

      case .setRoute(.accountSettingsMenu):
        state.route = .accountSettingsMenu(.init(
          availability: state.availability,
          avatar: state.currentUser.avatar,
          fullName: state.currentUser.name,
          jid: state.currentUser.jid,
          statusIcon: state.statusIcon
        ))
        return .none

      case .setRoute(.accountSwitcherMenu):
        state.route = .accountSwitcherMenu(.init())
        return .none

      case .setRoute(.editProfile):
        state.route = .editProfile(state.get { _ in .init() })
        return .none

      case .accountSettingsMenu, .accountSwitcherMenu, .editProfile:
        return .none
      }
    }
  }
}

extension Footer.Route {
  public enum Tag: Equatable {
    case accountSettingsMenu
    case accountSwitcherMenu
    case editProfile
  }

  var tag: Tag {
    switch self {
    case .accountSettingsMenu:
      return .accountSettingsMenu
    case .accountSwitcherMenu:
      return .accountSwitcherMenu
    case .editProfile:
      return .editProfile
    }
  }
}
