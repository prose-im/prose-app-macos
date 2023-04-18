//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import ComposableArchitecture
import Foundation
import JoinChatFeature
import Toolbox

public struct Sidebar: ReducerProtocol {
  public typealias State = SessionState<SidebarState>

  public struct SidebarState: Equatable {
    public internal(set) var selection: Selection?

    var route: Route?

    var rosterState = RosterState()
    var footer = Footer.FooterState()

    public init() {}
  }

  public enum Action: Equatable {
    case onAppear
    case onDisappear

    case selection(Selection?)

    case addContactButtonTapped
    case addGroupButtonTapped

    case footer(Footer.Action)

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
      Footer()
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
        return .cancel(token: SidebarEffectToken.self)

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

public extension Sidebar.Route {
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

private extension Sidebar.State {
  var footer: Footer.State {
    get { self.get(\.footer) }
    set { self.set(\.footer, newValue) }
  }

  var roster: SessionState<RosterState> {
    get { self.get(\.rosterState) }
    set { self.set(\.rosterState, newValue) }
  }
}

enum SidebarEffectToken: CaseIterable, Hashable {
  case rosterSubscription
  case presenceSubscription
  case activeChatsSubscription
  case userInfosSubscription
}
