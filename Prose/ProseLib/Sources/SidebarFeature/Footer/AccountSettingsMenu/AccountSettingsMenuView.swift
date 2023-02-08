import AppDomain
import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI

struct AccountSettingsMenuView: View {
  let store: StoreOf<AccountSettingsMenu>
  @ObservedObject var viewStore: ViewStoreOf<AccountSettingsMenu>

  init(store: StoreOf<AccountSettingsMenu>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // TODO: [Rémi Bardon] Refactor this view out
      HStack {
        Avatar(viewStore.avatar.map(AvatarImage.init) ?? .placeholder, size: 32)
        VStack(alignment: .leading) {
          Text(verbatim: viewStore.fullName)
            .font(.headline)
          Text(verbatim: viewStore.jid.rawValue)
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .foregroundColor(.primary)
      }
      // Make hit box full width
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(Rectangle())
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(
        L10n.Sidebar.Footer.Actions.Account.Header.label(viewStore.fullName, viewStore.jid.rawValue)
      )

      GroupBox {
        Button { viewStore.send(.updateMoodTapped) } label: {
          HStack(spacing: 4) {
            Text(String(viewStore.statusIcon))
              .accessibilityHidden(true)
            Text(verbatim: L10n.Sidebar.Footer.Actions.Account.UpdateMood.title)
          }
          .disclosureIndicator()
        }
        Menu(L10n.Sidebar.Footer.Actions.Account.ChangeAvailability.title) {
          self.availabilityMenu
        }
        // NOTE: [Rémi Bardon] This inverted padding fixes the padding SwiftUI adds for `Menu`s.
        .padding(.leading, -3)
        // NOTE: [Rémi Bardon] Having the disclosure indicator outside the menu label
        //       reduces the hit box, but we can't have it inside, otherwise SwiftUI
        //       places the `Image` on the leading edge.
        .disclosureIndicator()
        Button { viewStore.send(.pauseNotificationsTapped) } label: {
          Text(verbatim: L10n.Sidebar.Footer.Actions.Account.PauseNotifications.title)
            .disclosureIndicator()
        }
      }
      GroupBox {
        Button(L10n.Sidebar.Footer.Actions.Account.EditProfile.title) {
          viewStore.send(.editProfileTapped)
        }
        Button(L10n.Sidebar.Footer.Actions.Account.AccountSettings.title) {
          viewStore.send(.accountSettingsTapped)
        }
      }
      GroupBox {
        Button { viewStore.send(.offlineModeTapped) } label: {
          Text(verbatim: L10n.Sidebar.Footer.Actions.Account.OfflineMode.title)
            .disclosureIndicator()
        }
      }
      GroupBox {
        Button(L10n.Sidebar.Footer.Actions.Account.SignOut.title, role: .destructive) {
          viewStore.send(.signOutTapped)
        }
      }
    }
    .menuStyle(.borderlessButton)
    .menuIndicator(.hidden)
    .buttonStyle(SidebarFooterPopoverButtonStyle())
    .groupBoxStyle(VStackGroupBoxStyle(alignment: .leading, spacing: 6))
    .multilineTextAlignment(.leading)
    .padding(12)
    .frame(width: 196)
  }

  var availabilityMenu: some View {
    ForEach(Availability.allCases, id: \.self) { availability in
      Button { self.viewStore.send(.changeAvailabilityTapped(availability)) } label: {
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
  }
}

private extension View {
  func disclosureIndicator() -> some View {
    HStack(spacing: 4) {
      self.frame(maxWidth: .infinity, alignment: .leading)
      Image(systemName: "chevron.forward").padding(.trailing, 2)
    }
  }
}
