//
//  SidebarView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

public struct SidebarView: View {
    public typealias ViewState = SidebarState
    public typealias ViewAction = SidebarAction

    typealias Tag = SidebarState.Selection

    let store: Store<ViewState, ViewAction>
    let viewStore: ViewStore<Void, ViewAction>

    @Environment(\.redactionReasons) private var redactionReasons

    public init(store: Store<ViewState, ViewAction>) {
        self.store = store
        self.viewStore = ViewStore(store.stateless)
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            List(selection: viewStore.binding(
                get: \.selection,
                send: SidebarAction.selection
            )) {
                self.spotlightSection
                self.contactsSection
                self.groupsSection
            }
            .listStyle(.sidebar)
            .frame(minWidth: 280)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Footer(store: self.store.scope(state: \.footer, action: ViewAction.footer))
                    // Make sure accessibility frame isn't inset by the window's rounded corners
                    .contentShape(Rectangle())
                    // Make footer have a higher priority, to be accessible over the scroll view
                    .accessibilitySortPriority(1)
            }
            .toolbar {
                Toolbar(store: self.store.scope(state: \.toolbar, action: ViewAction.toolbar))
            }
        }
        .disabled(redactionReasons.contains(.placeholder))
    }

    private var spotlightSection: some View {
        Section(L10n.Sidebar.Spotlight.title) {
            IconRow(title: L10n.Sidebar.Spotlight.unreadStack, icon: .unread)
                .tag(Tag.unreadStack)
            IconRow(title: L10n.Sidebar.Spotlight.replies, icon: .reply)
                .tag(Tag.replies)
            IconRow(title: L10n.Sidebar.Spotlight.directMessages, icon: .directMessage)
                .tag(Tag.directMessages)
            IconRow(title: L10n.Sidebar.Spotlight.peopleAndGroups, icon: .group)
                .tag(Tag.peopleAndGroups)
        }
    }

    private var contactsSection: some View {
        Section(L10n.Sidebar.TeamMembers.title) {
            ContactRow(title: "John Doe", avatar: .placeholder).tag(Tag.chat("john@prose.org"))
            ActionButton(title: L10n.Sidebar.TeamMembers.Add.label) {
                self.viewStore.send(.addContactButtonTapped)
            }
        }
    }

    private var groupsSection: some View {
        Section(L10n.Sidebar.Groups.title) {
            IconRow(title: "My group", icon: .group)
            ActionButton(title: L10n.Sidebar.Groups.Add.label) {
                self.viewStore.send(.addGroupButtonTapped)
            }
        }.opacity(0.5)
    }
}
