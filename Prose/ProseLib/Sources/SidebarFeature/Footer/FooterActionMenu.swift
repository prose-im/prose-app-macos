//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Assets
import ComposableArchitecture
import ProseUI
import SwiftUI

// MARK: - View

private let l10n = L10n.Sidebar.Footer.Actions.self

/// Quick actions button in the left sidebar footer.
struct FooterActionMenu: View {
  typealias State = FooterActionMenuState
  typealias Action = FooterActionMenuAction

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Button(action: { actions.send(.showMenuTapped) }) {
        ZStack {
          Image(systemName: "ellipsis")
            .rotationEffect(.degrees(90))
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Colors.Text.secondary.color)

          RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color.secondary.opacity(0.125))
            .frame(width: 24, height: 32)
        }
        .unredacted()
        .disabled(redactionReasons.contains(.placeholder))
      }
      .buttonStyle(.plain)
      .popover(isPresented: viewStore.binding(\State.$showingMenu), content: popover)
      .accessibilityLabel(l10n.Server.label)
      // FIXME: [Rémi Bardon] Custom actions don't show up in the Accessibility Inspector, is it working?
      .accessibilityAction(named: l10n.Server.SwitchAccount.New.label) {
        actions.send(.connectAccountTapped)
      }
      .accessibilityAction(named: l10n.Server.ServerSettings.Manage.label) {
        actions.send(.manageServerTapped)
      }
    }
  }

  private func popover() -> some View {
    Self.popover(store: self.store)
  }

  fileprivate static func popover(store: Store<State, Action>) -> some View {
    let actions: ViewStore<Void, Action> = ViewStore(store.stateless)
    return VStack(alignment: .leading, spacing: 16) {
      // TODO: [Rémi Bardon] Refactor this view out
      HStack {
        Avatar(.placeholder, size: 48)
        VStack(alignment: .leading) {
          Text("Crisp")
            .font(.title3.bold())
          Text("crisp.chat")
            .monospacedDigit()
            .foregroundColor(.secondary)
        }
        .foregroundColor(.primary)
      }
      // Make hit box full width
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape([.interaction, .focusEffect], Rectangle())
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(L10n.Server.ConnectedTo.label("Crisp (crisp.chat)"))

      GroupBox(l10n.Server.SwitchAccount.title) {
        VStack(spacing: 4) {
          Button { actions.send(.switchAccountTapped(account: "crisp.chat")) } label: {
            Label {
              Text(verbatim: "Crisp – crisp.chat")
              Spacer()
              Image(systemName: "checkmark")
                .padding(.horizontal, 4)
            } icon: {
              // TODO: [Rémi Bardon] Change this to Crisp icon
              Avatar(.placeholder, size: 24)
            }
            // Make hit box full width
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape([.interaction, .focusEffect], Rectangle())
          }
          .accessibilityElement(children: .ignore)
          .accessibilityLabel(L10n.Server.ConnectedTo.label("Crisp (crisp.chat)"))
          Button { actions.send(.switchAccountTapped(account: "makair.life")) } label: {
            Label {
              Text(verbatim: "MakAir – makair.life")
            } icon: {
              // TODO: [Rémi Bardon] Change this to MakAir icon
              Avatar(.placeholder, size: 24)
            }
            // Make hit box full width
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape([.interaction, .focusEffect], Rectangle())
          }
          .accessibilityLabel(l10n.Server.SwitchAccount.label("MakAir (makair.life)"))
          Button { actions.send(.connectAccountTapped) } label: {
            Label {
              Text(l10n.Server.SwitchAccount.New.label)
            } icon: {
              Image(systemName: "plus")
                .frame(width: 24, height: 24)
            }
            // Make hit box full width
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape([.interaction, .focusEffect], Rectangle())
          }
          .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
      }
      .groupBoxStyle(DefaultGroupBoxStyle())

      GroupBox(l10n.Server.ServerSettings.title) {
        Link(destination: URL(string: "https://crisp.chat")!) {
          HStack {
            Text(l10n.Server.ServerSettings.Manage.label)
              .foregroundColor(.primary)
            Spacer()
            Image(systemName: "arrow.up.forward.square")
              .foregroundColor(.secondary)
          }
          // Make hit box full width
          .frame(maxWidth: .infinity)
          .contentShape([.interaction, .focusEffect], Rectangle())
        }
        .foregroundColor(.accentColor)
      }
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .buttonStyle(SidebarFooterPopoverButtonStyle())
    .groupBoxStyle(VStackGroupBoxStyle(alignment: .leading, spacing: 6))
    .multilineTextAlignment(.leading)
    .padding(12)
    .frame(width: 256)
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let footerActionMenuReducer: Reducer<
  FooterActionMenuState,
  FooterActionMenuAction,
  Void
> = Reducer { state, action, _ in
  switch action {
  case .showMenuTapped:
    state.showingMenu = true

  case let .switchAccountTapped(account: account):
    // TODO: [Rémi Bardon] Handle action
    logger.info("Switch account to '\(account)' tapped")
    state.showingMenu = false

  case .connectAccountTapped:
    // TODO: [Rémi Bardon] Handle action
    logger.info("Connect account tapped")

  case .manageServerTapped:
    // TODO: [Rémi Bardon] Handle action (find a way to open a URL)
    logger.info("Manage server tapped")

  case .binding:
    break
  }

  return .none
}.binding()

// MARK: State

public struct FooterActionMenuState: Equatable {
  @BindableState var showingMenu: Bool

  public init(
    showingMenu: Bool = false
  ) {
    self.showingMenu = showingMenu
  }
}

// MARK: Actions

public enum FooterActionMenuAction: Equatable, BindableAction {
  case showMenuTapped
  case switchAccountTapped(account: String)
  case connectAccountTapped
  /// Only here for accessibility
  case manageServerTapped
  case binding(BindingAction<FooterActionMenuState>)
}

// MARK: - Previews

struct FooterActionMenu_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      VStack {
        FooterActionMenu(store: Store(
          initialState: FooterActionMenuState(),
          reducer: footerActionMenuReducer,
          environment: ()
        ))
        Text("The popover 👇")
        Text("(Previews can't display it)")
        FooterActionMenu.popover(store: Store(
          initialState: FooterActionMenuState(),
          reducer: footerActionMenuReducer,
          environment: ()
        ))
        .border(Color.gray)
      }
      .padding()
    }
  }

  static var previews: some View {
    Preview()
      .preferredColorScheme(.light)
      .previewDisplayName("Light")

    Preview()
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
  }
}
