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
    public typealias State = SidebarState
    public typealias Action = SidebarAction

    typealias Tag = SidebarState.Selection

    let store: Store<State, Action>
    @ObservedObject var viewStore: ViewStore<State, Action>

    @Environment(\.redactionReasons) private var redactionReasons

    public init(store: Store<State, Action>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    public var body: some View {
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
            Footer(store: self.store.scope(state: \.footer, action: Action.footer))
                // Make sure accessibility frame isn't inset by the window's rounded corners
                .contentShape(Rectangle())
                // Make footer have a higher priority, to be accessible over the scroll view
                .accessibilitySortPriority(1)
        }
        .toolbar {
            Toolbar(store: self.store.scope(state: \.toolbar, action: Action.toolbar))
        }
        .disabled(redactionReasons.contains(.placeholder))
        .onAppear { viewStore.send(.onAppear) }
        .onDisappear { viewStore.send(.onDisappear) }
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
        ForEach(viewStore.roster.groups, id: \.name) { group in
            Section(group.name) {
                ForEach(group.items, id: \.jid) { item in
                    ContactRow(
                        title: item.jid.jidString,
                        avatar: .placeholder,
                        count: item.numberOfUnreadMessages
                    ).tag(Tag.chat(item.jid))
                }
                ActionButton(title: L10n.Sidebar.TeamMembers.Add.label) {
                    self.viewStore.send(.addContactButtonTapped)
                }
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
