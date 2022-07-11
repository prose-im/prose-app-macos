//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import JoinChatFeature
import SwiftUI
import SwiftUINavigation

public struct SidebarView: View {
  public typealias State = SidebarState
  public typealias Action = SidebarAction

  typealias Tag = SidebarState.Selection

  struct ViewState: Equatable {
    let selection: State.Selection?
    let sheet: State.Sheet?
  }

  @Environment(\.redactionReasons) private var redactionReasons

  private let store: Store<State, Action>
  @ObservedObject private var viewStore: ViewStore<ViewState, Action>

  public init(store: Store<State, Action>) {
    self.store = store
    self.viewStore = ViewStore(store.scope(state: ViewState.init))
  }

  public var body: some View {
    List(selection: self.viewStore.binding(
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
    .sheet(unwrapping: self.viewStore.binding(
      get: \.sheet,
      send: SidebarAction.showSheet
    )) { _ in
      IfLetStore(self.store.scope(state: \.sheet)) { store in
        SwitchStore(store) {
          CaseLet(
            state: CasePath(State.Sheet.addMember).extract(from:),
            action: Action.addMember,
            then: AddMemberSheet.init(store:)
          )
          CaseLet(
            state: CasePath(State.Sheet.joinGroup).extract(from:),
            action: Action.joinGroup,
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
    WithViewStore(store.scope(state: \.roster.sidebar.groups)) { viewStore in
      ForEach(viewStore.state, id: \.name) { group in
        Section(group.name) {
          ForEach(group.items, id: \.jid) { item in
            ContactRow(
              title: item.jid.jidString,
              avatar: .placeholder,
              count: item.numberOfUnreadMessages,
              status: item.status
            ).tag(Tag.chat(item.jid))
          }
          ActionButton(title: L10n.Sidebar.TeamMembers.Add.label) {
            viewStore.send(.addContactButtonTapped)
          }
          // https://github.com/prose-im/prose-app-macos/issues/45
          .disabled(true)
        }
      }
    }
  }

  private var groupsSection: some View {
    Section(L10n.Sidebar.Groups.title) {
      IconRow(title: "My group", icon: .group)
        .opacity(0.5)
      ActionButton(title: L10n.Sidebar.Groups.Add.label) {
        self.viewStore.send(.addGroupButtonTapped)
      }
    }
    // https://github.com/prose-im/prose-app-macos/issues/45
    .disabled(true)
  }
}

private extension SidebarView.ViewState {
  init(_ state: SidebarState) {
    self.selection = state.selection
    self.sheet = state.sheet
  }
}
