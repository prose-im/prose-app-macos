//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import JoinChatFeature
import SwiftUI
import SwiftUINavigation

public struct SidebarView: View {
  typealias Tag = SidebarReducer.Selection

  struct ViewState: Equatable {
    let selection: SidebarReducer.Selection?
    let route: SidebarReducer.Route.Tag?
  }

  private let store: StoreOf<SidebarReducer>
  @ObservedObject private var viewStore: ViewStore<ViewState, SidebarReducer.Action>

  public init(store: StoreOf<SidebarReducer>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  public var body: some View {
    List(selection: self.viewStore.binding(
      get: \.selection,
      send: SidebarReducer.Action.selection
    )) {
      self.spotlightSection
      self.contactsSection
      self.groupsSection
    }
    .listStyle(.sidebar)
    .frame(minWidth: 280)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      FooterView(
        store: self.store
          .scope(state: \.footer, action: SidebarReducer.Action.footer)
      )
      // Make sure accessibility frame isn't inset by the window's rounded corners
      .contentShape(Rectangle())
      // Make footer have a higher priority, to be accessible over the scroll view
      .accessibilitySortPriority(1)
    }
    .toolbar {
      self.toolbar
    }
    .sheet(
      unwrapping: self.viewStore
        .binding(get: \.route, send: SidebarReducer.Action.setRoute)
    ) { _ in
      IfLetStore(self.store.scope(state: \.route)) { store in
        SwitchStore(store) {
          CaseLet(
            state: /SidebarReducer.Route.addMember,
            action: SidebarReducer.Action.addMember,
            then: AddMemberSheet.init(store:)
          )
          CaseLet(
            state: /SidebarReducer.Route.joinGroup,
            action: SidebarReducer.Action.joinGroup,
            then: JoinGroupSheet.init(store:)
          )
        }
      }
    }
    .onAppear { self.viewStore.send(.onAppear) }
    .onDisappear { self.viewStore.send(.onDisappear) }
  }

  private var spotlightSection: some View {
    Section(L10n.Sidebar.Spotlight.title) {
      IconRow(title: L10n.Sidebar.Spotlight.unreadStack, icon: .unread)
//        .tag(Tag.unreadStack)
        .opacity(0.5)
      IconRow(title: L10n.Sidebar.Spotlight.replies, icon: .reply)
//        .tag(Tag.replies)
        .opacity(0.5)
      IconRow(title: L10n.Sidebar.Spotlight.directMessages, icon: .directMessage)
//        .tag(Tag.directMessages)
        .opacity(0.5)
      IconRow(title: L10n.Sidebar.Spotlight.peopleAndGroups, icon: .group)
//        .tag(Tag.peopleAndGroups)
        .opacity(0.5)
    }
    // https://github.com/prose-im/prose-app-macos/issues/45
    .disabled(true)
  }

  private var contactsSection: some View {
    WithViewStore(self.store.scope(state: \.roster.groups)) { viewStore in
      ForEach(viewStore.state, id: \.name) { group in
        Section(group.name) {
          ForEach(group.items, id: \.jid) { item in
            ContactRow(
              title: item.name,
              avatar: .init(url: item.avatarURL),
              count: item.numberOfUnreadMessages,
              status: item.status
            ).tag(Tag.chat(item.jid))
          }
          ActionButton(title: L10n.Sidebar.TeamMembers.Add.label) {
            viewStore.send(.addContactButtonTapped)
          }
        }
      }
    }
  }

  private var groupsSection: some View {
    Section(L10n.Sidebar.Groups.title) {
      IconRow(title: "My group", icon: .group)
        // https://github.com/prose-im/prose-app-macos/issues/45
        .opacity(0.5)
        .disabled(true)
      ActionButton(title: L10n.Sidebar.Groups.Add.label) {
        self.viewStore.send(.addGroupButtonTapped)
      }
    }
  }

  private var toolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .primaryAction) {
      Button {} label: {
        Label(L10n.Sidebar.Toolbar.Actions.StartCall.label, systemImage: "phone.bubble.left")
      }
      .accessibilityHint(L10n.Sidebar.Toolbar.Actions.StartCall.hint)
      Toggle(isOn: .constant(false)) {
        Label(L10n.Sidebar.Toolbar.Actions.WriteMessage.label, systemImage: "square.and.pencil")
      }
      .toggleStyle(.button)
      .accessibilityHint(L10n.Sidebar.Toolbar.Actions.WriteMessage.hint)
    }
  }
}

private extension SidebarView.ViewState {
  init(_ state: SidebarReducer.State) {
    self.selection = state.selection
    self.route = state.route?.tag
  }
}
