//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseUI
import SwiftUI

struct AccountSwitcherMenuView: View {
  private let store: StoreOf<AccountSwitcherMenuReducer>
  @ObservedObject private var viewStore: ViewStoreOf<AccountSwitcherMenuReducer>

  init(store: StoreOf<AccountSwitcherMenuReducer>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
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

      GroupBox(L10n.Sidebar.Footer.Actions.Server.SwitchAccount.title) {
        VStack(spacing: 4) {
          ForEach(self.viewStore.accounts) { account in
            Button { self.viewStore.send(.accountSelected(account.jid)) } label: {
              Label {
                Text(verbatim: account.jid.rawValue)
                if account.jid == self.viewStore.selectedAccount.jid {
                  Spacer()
                  Image(systemName: "checkmark").padding(.horizontal, 4)
                }
              } icon: {
                Avatar(.placeholder, size: 24)
              }
              // Make hit box full width
              .frame(maxWidth: .infinity, alignment: .leading)
              .contentShape([.interaction, .focusEffect], Rectangle())
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(L10n.Server.ConnectedTo.label("Crisp (crisp.chat)"))
          }

//          Button { self.viewStore.send(.switchAccountTapped(account: "makair.life")) } label: {
//            Label {
//              Text(verbatim: "MakAir – makair.life")
//            } icon: {
//              // TODO: [Rémi Bardon] Change this to MakAir icon
//              Avatar(.placeholder, size: 24)
//            }
//            // Make hit box full width
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .contentShape([.interaction, .focusEffect], Rectangle())
//          }
//          .accessibilityLabel(
//            L10n.Sidebar.Footer.Actions.Server.SwitchAccount.label("MakAir (makair.life)")
//          )

          Button { self.viewStore.send(.connectAccountTapped) } label: {
            Label {
              Text(L10n.Sidebar.Footer.Actions.Server.SwitchAccount.New.label)
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

      GroupBox(L10n.Sidebar.Footer.Actions.Server.ServerSettings.title) {
        Link(destination: URL(string: "https://crisp.chat")!) {
          HStack {
            Text(L10n.Sidebar.Footer.Actions.Server.ServerSettings.Manage.label)
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
      // https://github.com/prose-im/prose-app-macos/issues/45
      .disabled(true)
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
