//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation
import JoinChatFeature
import Toolbox

public struct SidebarReducer: ReducerProtocol {
  public typealias State = SessionState<SidebarState>

  public struct SidebarState: Equatable {
    public internal(set) var selection: Selection?

    var route: Route?
    var footer = FooterReducer.FooterState()

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case onDisappear

    case selection(Selection?)

    case addContactButtonTapped
    case addGroupButtonTapped

    case footer(FooterReducer.Action)

    case addMember(AddMemberSheetAction)
    case joinGroup(JoinGroupSheetAction)

    case setRoute(Route.Tag?)
  }

  public enum Selection: Hashable {
    case unreadStack
    case replies
    case directMessages
    case peopleAndGroups
    case chat(BareJid)
  }

  public enum Route: Equatable {
    case addMember(AddMemberSheetState)
    case joinGroup(JoinGroupSheetState)
  }

  public init() {}

  @Dependency(\.mainQueue) var mainQueue

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: \.footer, action: /Action.footer) {
      FooterReducer()
    }
    Scope(state: \.route, action: /.self) {
      EmptyReducer()
        .ifCaseLet(/Route.addMember, action: /Action.addMember) {
          Reduce(addMemberReducer, environment: .init(mainQueue: self.mainQueue))
        }
        .ifCaseLet(/Route.joinGroup, action: /Action.joinGroup) {
          Reduce(joinGroupReducer, environment: .init(mainQueue: self.mainQueue))
        }
    }
    // RosterReducer()

    self.core
  }

  @ReducerBuilder<State, Action>
  private var core: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none

      case .onDisappear:
        return .none

      case let .selection(selection):
        state.selection = selection
        return .none

      case .addContactButtonTapped:
        state.route = .addMember(AddMemberSheetState())
        return .none

      case .addGroupButtonTapped:
        state.route = .joinGroup(JoinGroupSheetState())
        return .none

      case .setRoute(.none):
        state.route = nil
        return .none

      case .setRoute(.joinGroup):
        state.route = .joinGroup(.init())
        return .none

      case .setRoute(.addMember):
        state.route = .addMember(.init())
        return .none

      case .addMember(.cancelTapped), .joinGroup(.cancelTapped):
        state.route = nil
        return .none

      case .addMember(.submitTapped), .joinGroup(.submitTapped):
        fatalError("\(action) not implemented yet.")

      case .footer, .addMember, .joinGroup:
        return .none
      }
    }
  }
}

public extension SidebarReducer.Route {
  enum Tag {
    case addMember
    case joinGroup
  }

  var tag: Tag {
    switch self {
    case .addMember:
      return .addMember
    case .joinGroup:
      return .joinGroup
    }
  }
}

private extension SidebarReducer.State {
  var footer: FooterReducer.State {
    get { self.get(\.footer) }
    set { self.set(\.footer, newValue) }
  }
}

extension SidebarReducer.State {
  var roster: SidebarReducer.Roster {
    var groups = [String: [SidebarReducer.Roster.Group.Item]]()
    for item in self.selectedAccount.contacts {
      for group in item.groups {
        groups[group, default: []].append(.init(
          jid: item.jid,
          name: item.name,
          avatarURL: item.avatar,
          numberOfUnreadMessages: 0,
          status: item.availability
        ))
      }
    }

    return SidebarReducer.Roster(groups: groups.map { groupName, items in
      SidebarReducer.Roster.Group(name: groupName, items: items)
    })
  }
}

extension SidebarReducer {
  struct Roster: Equatable {
    var groups = [Group]()
  }
}

extension SidebarReducer.Roster {
  struct Group: Equatable {
    var name: String
    var items = [Item]()
  }
}

extension SidebarReducer.Roster.Group {
  struct Item: Equatable {
    var jid: BareJid
    var name: String
    var avatarURL: URL?
    var numberOfUnreadMessages: Int
    var status: Availability
  }
}
