import AppLocalization
import ComposableArchitecture
import ProseUI
import SwiftUI

struct AccountSwitcherMenuView: View {
  private let store: StoreOf<AccountSwitcherMenu>
  @ObservedObject private var viewStore: ViewStoreOf<AccountSwitcherMenu>

  init(store: StoreOf<AccountSwitcherMenu>) {
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
          ForEach(Array(self.viewStore.accounts.values)) { account in
            Button { self.viewStore.send(.switchAccountTapped(account: "crisp.chat")) } label: {
              Label {
                Text(verbatim: account.jid.rawValue)
                Spacer()
                Image(systemName: "checkmark")
                  .padding(.horizontal, 4)
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
