//
//  SettingsView.swift
//  Prose
//
//  Created by Rémi Bardon on 23/06/2022.
//

import AppLocalization
import SwiftUI

public struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, accounts, notifications, messages, calls, advanced
    }

    @State private var tab: Tabs = .general

    public init() {}
    public var body: some View {
        TabView(selection: $tab) {
            GeneralTab()
                .tabItem { Label(L10n.Settings.Tabs.general, systemImage: "gearshape") }
                .tag(Tabs.general)
                .frame(width: SettingsConstants.contentWidth)
                .fixedSize(horizontal: true, vertical: false)
            AccountsTab()
                .tabItem { Label(L10n.Settings.Tabs.accounts, systemImage: "person.2") }
                .tag(Tabs.accounts)
            NotificationsTab()
                .tabItem { Label(L10n.Settings.Tabs.notifications, systemImage: "bell") }
                .tag(Tabs.notifications)
                .frame(width: SettingsConstants.contentWidth)
                .fixedSize(horizontal: true, vertical: false)
            MessagesTab()
                .tabItem { Label(L10n.Settings.Tabs.messages, systemImage: "bubble.left.and.bubble.right") }
                .tag(Tabs.messages)
                .frame(width: SettingsConstants.contentWidth)
                .fixedSize(horizontal: true, vertical: false)
            CallsTab(
                // TODO:
                videoInputStreamPath: "webcam-valerian"
            )
            .tabItem { Label(L10n.Settings.Tabs.calls, systemImage: "phone.arrow.up.right") }
            .tag(Tabs.calls)
            .frame(width: SettingsConstants.contentWidth)
            .fixedSize(horizontal: true, vertical: false)
            AdvancedTab()
                .tabItem { Label(L10n.Settings.Tabs.advanced, systemImage: "dial.min") }
                .tag(Tabs.advanced)
                .frame(width: SettingsConstants.contentWidth)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
