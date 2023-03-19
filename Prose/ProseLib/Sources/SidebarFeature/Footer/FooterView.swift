import AppDomain
import AppLocalization
import Assets
import AuthenticationFeature
import ComposableArchitecture
import EditProfileFeature
import ProseCoreTCA
import ProseUI
import SwiftUI
import SwiftUINavigation

/// The small bar at the bottom of the left sidebar.
struct FooterView: View {
  struct ViewState: Equatable {
    var availability: Availability
    var avatar: URL?
    var jid: BareJid
    var route: Footer.Route.Tag?
    var statusIcon: Character
    var statusMessage: String
  }

  static let height: CGFloat = 64

  private let store: StoreOf<Footer>
  @ObservedObject private var viewStore: ViewStore<ViewState, Footer.Action>

  public init(store: StoreOf<Footer>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  var body: some View {
    VStack(spacing: 0) {
      Divider()

      HStack(spacing: 12) {
        // User avatar
        self.accountSettingsButton
          .popover(
            unwrapping: self.viewStore.binding(get: \.route, send: .dismiss(.accountSettingsMenu)),
            case: /Footer.Route.Tag.accountSettingsMenu
          ) { _ in
            IfLetStore(self.store.scope(state: \.route)) { store in
              SwitchStore(store) {
                CaseLet(
                  state: /Footer.Route.accountSettingsMenu,
                  action: Footer.Action.accountSettingsMenu,
                  then: AccountSettingsMenuView.init(store:)
                )
              }
            }
          }

        // Team name + user status
        FooterDetails(
          teamName: self.viewStore.jid.rawValue,
          statusIcon: self.viewStore.statusIcon,
          statusMessage: self.viewStore.statusMessage
        )
        .layoutPriority(1)

        // Quick actions button
        self.accountSwitcherButton
          .popover(
            unwrapping: self.viewStore.binding(get: \.route, send: .dismiss(.accountSwitcherMenu)),
            case: /Footer.Route.Tag.accountSwitcherMenu
          ) { _ in
            IfLetStore(self.store.scope(state: \.route)) { store in
              SwitchStore(store) {
                CaseLet(
                  state: /Footer.Route.accountSwitcherMenu,
                  action: Footer.Action.accountSwitcherMenu,
                  then: AccountSwitcherMenuView.init(store:)
                )
              }
            }
          }
      }
      .padding(.leading, 20.0)
      .padding(.trailing, 14.0)
      .frame(maxHeight: 64)
    }
    .frame(height: Self.height)
    .accessibilityElement(children: .contain)
    .accessibilityLabel(L10n.Sidebar.Footer.label)
    .sheet(
      unwrapping: self.viewStore.binding(get: \.route, send: .dismiss(.editProfile)),
      case: /Footer.Route.Tag.editProfile
    ) { _ in
      IfLetStore(self.store.scope(state: \.route)) { store in
        SwitchStore(store) {
          CaseLet(
            state: /Footer.Route.editProfile,
            action: Footer.Action.editProfile,
            then: EditProfileScreen.init(store:)
          )
        }
      }
    }
    .sheet(
      unwrapping: self.viewStore.binding(get: \.route, send: .dismiss(.auth)),
      case: /Footer.Route.Tag.auth
    ) { _ in
      IfLetStore(self.store.scope(state: \.route)) { store in
        SwitchStore(store) {
          CaseLet(
            state: /Footer.Route.auth,
            action: Footer.Action.auth,
            then: AuthenticationScreen.init(store:)
          )
        }
      }
    }
  }

  var accountSettingsButton: some View {
    Button(action: { self.viewStore.send(.setRoute(.accountSettingsMenu)) }) {
      Avatar(self.viewStore.avatar.map(AvatarImage.init) ?? .placeholder, size: 32)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(L10n.Sidebar.Footer.label)
    .overlay(alignment: .bottomTrailing) {
      AvailabilityIndicator(availability: self.viewStore.availability)
        // Offset of half the size minus 2 points (otherwise it looks odd)
        .alignmentGuide(.trailing) { d in d.width / 2 + 2 }
        .alignmentGuide(.bottom) { d in d.height / 2 + 2 }
    }
  }

  var accountSwitcherButton: some View {
    Button(action: { self.viewStore.send(.setRoute(.accountSwitcherMenu)) }) {
      ZStack {
        Image(systemName: "ellipsis")
          .rotationEffect(.degrees(90))
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(Colors.Text.secondary.color)

        RoundedRectangle(cornerRadius: 4, style: .continuous)
          .fill(Color.secondary.opacity(0.125))
          .frame(width: 24, height: 32)
      }
    }
    .buttonStyle(.plain)
    .accessibilityLabel(L10n.Sidebar.Footer.Actions.Server.label)
  }
}

extension FooterView.ViewState {
  init(_ state: Footer.State) {
    self.availability = state.availability
    self.avatar = state.selectedAccount.avatar
    self.jid = state.currentUser
    self.route = state.route?.tag
    self.statusIcon = state.statusIcon
    self.statusMessage = state.statusMessage
  }
}
