//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI
import SwiftUINavigation

private let l10n = L10n.Sidebar.Footer.Actions.Account.self

// MARK: - View

/// User avatar in the left sidebar footer
struct FooterAvatar: View {
  typealias State = SessionState<FooterAvatarState>
  typealias Action = FooterAvatarAction

  struct ViewState: Equatable {
    let avatar: AvatarImage
    let availability: Availability
    let isShowingPopover: Bool
    let fullName: String
    let jid: String
    let statusIcon: Character
  }

  @Environment(\.redactionReasons) private var redactionReasons

  private let store: Store<State, Action>
  @ObservedObject private var viewStore: ViewStore<ViewState, Action>

  public init(store: Store<State, Action>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  var body: some View {
    Button(action: { self.viewStore.send(.avatarTapped) }) {
      Avatar(self.viewStore.avatar, size: 32)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(l10n.label)
    .overlay(alignment: .bottomTrailing) {
      AvailabilityIndicator(availability: self.viewStore.availability)
        // Offset of half the size minus 2 points (otherwise it looks odd)
        .alignmentGuide(.trailing) { d in d.width / 2 + 2 }
        .alignmentGuide(.bottom) { d in d.height / 2 + 2 }
    }
    .popover(
      isPresented: self.viewStore.binding(get: \.isShowingPopover, send: .dismissPopover),
      content: self.popover
    )
  }

  private func popover() -> some View {
    Self.popover(viewStore: self.viewStore, redactionReasons: self.redactionReasons)
  }

  fileprivate static func popover(
    viewStore: ViewStore<ViewState, Action>,
    redactionReasons: RedactionReasons
  ) -> some View {
    VStack(alignment: .leading, spacing: 16) {
      // TODO: [Rémi Bardon] Refactor this view out
      HStack {
        Avatar(viewStore.avatar, size: 32)
        VStack(alignment: .leading) {
          Text(verbatim: viewStore.fullName)
            .font(.headline)
          Text(verbatim: viewStore.jid)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .foregroundColor(.primary)
      }
      // Make hit box full width
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(Rectangle())
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(l10n.Header.label(viewStore.fullName, viewStore.jid))

      GroupBox {
        Button { viewStore.send(.updateMoodTapped) } label: {
          HStack(spacing: 4) {
            Text(String(viewStore.statusIcon))
              .accessibilityHidden(true)
            Text(verbatim: l10n.UpdateMood.title)
              .unredacted()
          }
          .disclosureIndicator()
        }
        Menu(l10n.ChangeAvailability.title) {
          Self.availabilityMenu(
            viewStore: viewStore,
            redactionReasons: redactionReasons
          )
        }
        // NOTE: [Rémi Bardon] This inverted padding fixes the padding SwiftUI adds for `Menu`s.
        .padding(.leading, -3)
        // NOTE: [Rémi Bardon] Having the disclosure indicator outside the menu label
        //       reduces the hit box, but we can't have it inside, otherwise SwiftUI
        //       places the `Image` on the leading edge.
        .disclosureIndicator()
        .unredacted()
        Button { viewStore.send(.pauseNotificationsTapped) } label: {
          Text(verbatim: l10n.PauseNotifications.title)
            .disclosureIndicator()
        }
        .unredacted()
      }
      GroupBox {
        Button(l10n.EditProfile.title) { viewStore.send(.editProfileTapped) }
          .unredacted()
        Button(l10n.AccountSettings.title) { viewStore.send(.accountSettingsTapped) }
          .unredacted()
      }
      GroupBox {
        Button { viewStore.send(.offlineModeTapped) } label: {
          Text(verbatim: l10n.OfflineMode.title)
            .disclosureIndicator()
        }
        .unredacted()
      }
      GroupBox {
        Button(l10n.SignOut.title, role: .destructive) { viewStore.send(.signOutTapped) }
          .unredacted()
      }
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .buttonStyle(SidebarFooterPopoverButtonStyle())
    .groupBoxStyle(VStackGroupBoxStyle(alignment: .leading, spacing: 6))
    .multilineTextAlignment(.leading)
    .padding(12)
    .frame(width: 196)
    .disabled(redactionReasons.contains(.placeholder))
  }

  static func availabilityMenu(
    viewStore: ViewStore<ViewState, Action>,
    redactionReasons: RedactionReasons
  ) -> some View {
    ForEach(Availability.allCases, id: \.self) { availability in
      Button { viewStore.send(.changeAvailabilityTapped(availability)) } label: {
        HStack {
          // NOTE: [Rémi Bardon] We could use a `Label` or `HStack` here,
          //       to add the colored dot, but `Menu`s don't display it.
          Text(availability.localizedDescription)
          if viewStore.availability == availability {
            Spacer()
            Image(systemName: "checkmark")
          }
        }
      }
      .tag(availability)
      .disabled(viewStore.availability == availability)
    }
    .unredacted()
    .disabled(redactionReasons.contains(.placeholder))
  }
}

extension FooterAvatar.ViewState {
  init(_ state: FooterAvatar.State) {
    self.avatar = state.currentUser.avatar.map(AvatarImage.init) ?? .placeholder
    self.availability = state.availability
    self.isShowingPopover = state.isShowingPopover
    self.fullName = state.currentUser.name
    self.jid = state.currentUser.jid.rawValue
    self.statusIcon = state.statusIcon
  }
}

struct VStackGroupBoxStyle: GroupBoxStyle {
  let alignment: HorizontalAlignment
  let spacing: CGFloat?

  func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: self.alignment, spacing: self.spacing) { configuration.content }
  }
}

struct SidebarFooterPopoverButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .opacity((configuration.isPressed || !self.isEnabled) ? 0.5 : 1)
      .foregroundColor(Self.color(for: configuration.role))
      // Make hit box full width
      // NOTE: [Rémi Bardon] We could avoid making the hit box full width for destructive actions.
      .frame(maxWidth: .infinity, alignment: .leading)
      // Allow hits in the transparent areas
      .contentShape(Rectangle())
  }

  static func color(for role: ButtonRole?) -> Color? {
    switch role {
    case .some(.destructive):
      return .red
    default:
      return nil
    }
  }
}

extension View {
  func disclosureIndicator() -> some View {
    HStack(spacing: 4) {
      self
        .frame(maxWidth: .infinity, alignment: .leading)
      Image(systemName: "chevron.forward")
        .padding(.trailing, 2)
        .unredacted()
    }
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let footerAvatarReducer = AnyReducer<
  SessionState<FooterAvatarState>,
  FooterAvatarAction,
  Void
> { state, action, _ in
  switch action {
  case .avatarTapped:
    state.isShowingPopover = true
    return .none

  case let .changeAvailabilityTapped(availability):
    state.availability = availability
    return .none

  case .signOutTapped:
    state.isShowingPopover = false
    return .none

  case .dismissPopover:
    state.isShowingPopover = false
    return .none

  case .binding:
    return .none

  case .updateMoodTapped, .pauseNotificationsTapped, .editProfileTapped, .accountSettingsTapped,
       .offlineModeTapped:
    // TODO: [Rémi Bardon] Handle actions
    logger.notice("Received unhandled action: \(String(describing: action))")
    return .none
  }
}.binding()

// MARK: State

public struct FooterAvatarState: Equatable {
  var availability: Availability
  var statusIcon: Character
  var statusMessage: String

  @BindingState var isShowingPopover: Bool

  public init(
    availability: Availability = .available,
    statusIcon: Character = "🚀",
    statusMessage: String = "Building new features.",
    isShowingPopover: Bool = false
  ) {
    self.availability = availability
    self.isShowingPopover = isShowingPopover
    self.statusIcon = statusIcon
    self.statusMessage = statusMessage
    self.isShowingPopover = isShowingPopover
  }
}

// MARK: Actions

public enum FooterAvatarAction: Equatable, BindableAction {
  case avatarTapped
  case updateMoodTapped
  case changeAvailabilityTapped(Availability)
  case pauseNotificationsTapped
  case editProfileTapped
  case accountSettingsTapped
  case offlineModeTapped
  case signOutTapped
  case dismissPopover
  case binding(BindingAction<SessionState<FooterAvatarState>>)
}

// MARK: - Previews

#if DEBUG
  import PreviewAssets

  struct FooterAvatar_Previews: PreviewProvider {
    private struct Preview: View {
      @Environment(\.redactionReasons) private var redactionReasons

      var body: some View {
        VStack {
          HStack {
            ForEach(Availability.allCases, id: \.self) { availability in
              content(state: FooterAvatarState(
                availability: availability
              ))
            }
          }
          .padding()
          let store = Store(
            initialState: .mock(FooterAvatarState(
              availability: .available
            )),
            reducer: footerAvatarReducer,
            environment: ()
          )
          Text("The popover 👇")
          Text("(Previews can't display it)")
          FooterAvatar.popover(
            viewStore: ViewStore(store.scope(state: FooterAvatar.ViewState.init)),
            redactionReasons: redactionReasons
          )
          .border(Color.gray)
          Text("The availability menu 👇")
          Text("(Previews can't display it)")
          VStack(alignment: .leading) {
            FooterAvatar.availabilityMenu(
              viewStore: ViewStore(store.scope(state: FooterAvatar.ViewState.init)),
              redactionReasons: redactionReasons
            )
          }
          .padding()
          .frame(width: 256)
          .border(Color.gray)
          .buttonStyle(.plain)
        }
        .padding()
      }

      private func content(state: FooterAvatarState) -> some View {
        FooterAvatar(store: Store(
          initialState: .mock(state),
          reducer: footerAvatarReducer,
          environment: ()
        ))
      }
    }

    static var previews: some View {
      Preview()
        .preferredColorScheme(.light)
        .previewDisplayName("Light")
      Preview()
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark")
      Preview()
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
