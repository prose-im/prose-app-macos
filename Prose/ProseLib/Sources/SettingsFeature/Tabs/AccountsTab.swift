//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import ProseUI
import SwiftUI

private let l10n = L10n.Settings.Accounts.self

struct AccountsTab: View {
  enum Tab {
    case account, security, features
  }

  typealias Account = AccountPickerRow.ViewModel

  @State var accounts = [
    Account(
      teamLogo: "logo-crisp",
      teamDomain: "crisp.chat",
      userName: "Baptiste"
    ),
    Account(
      teamLogo: "logo-makair",
      teamDomain: "makair.life",
      userName: "Baptiste"
    ),
  ]
  @State var sortOrder = [KeyPathComparator(
    \Account.teamDomain,
    comparator: String.Comparator(options: [.caseInsensitive, .diacriticInsensitive, .numeric])
  )]
  @State private var selectedAccount: Account.ID? = "crisp.chat"

  @State private var selectedTab: Tab = .account

  var sortedAccounts: [Account] {
    self.accounts.sorted(using: self.sortOrder)
  }

  var body: some View {
    NavigationView {
      Table(
        self.sortedAccounts,
        selection: self.$selectedAccount,
        sortOrder: self.$sortOrder
      ) {
        TableColumn("Accounts", value: \.teamDomain) {
          AccountPickerRow(viewModel: $0)
        }
      }
      .frame(minWidth: 196)
      .safeAreaInset(edge: .bottom, spacing: 0) {
        VStack(spacing: 0) {
          Divider()
          HStack(spacing: 0) {
            TableFooterButton(
              systemImage: "plus",
              trailingDivider: true
            ) { logger.debug("Plus button tapped") }
            TableFooterButton(
              systemImage: "minus",
              trailingDivider: true
            ) { logger.debug("Minus button tapped") }
            Spacer()
          }
        }
        .frame(height: 22)
        .background(.thickMaterial)
      }

      TabView(selection: self.$selectedTab) {
        AccountSettingsAccountView()
          .tabItem { Text(l10n.Tabs.account) }
          .tag(Tab.account)
        AccountSettingsSecurityView()
          .tabItem { Text(l10n.Tabs.security) }
          .tag(Tab.security)
        AccountSettingsFeaturesView()
          .tabItem { Text(l10n.Tabs.features) }
          .tag(Tab.features)
      }
      // NOTE: Very important, otherwise the `TabView` disappears!
      .tabViewStyle(DefaultTabViewStyle())
      .padding()
    }
  }
}

struct AccountsSettingsView_Previews: PreviewProvider {
  private struct Preview: View {
    var body: some View {
      AccountsTab(
        accounts: [
          .init(
            teamLogo: "logo-crisp",
            teamDomain: "crisp.chat",
            userName: "Baptiste"
          ),
          .init(
            teamLogo: "logo-makair",
            teamDomain: "makair.life",
            userName: "Baptiste"
          ),
        ] + Array(repeating: { AccountPickerRow.ViewModel(
          teamLogo: "",
          teamDomain: "\(UUID().uuidString.prefix(6).lowercased()).com",
          userName: "Baptiste"
        ) }, count: 20).map { $0() }
      )
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
