//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
import JoinChatFeature
import ProseCoreTCA
import TcaHelpers
import Toolbox

public typealias UserCredentials = JID

public struct SidebarState: Equatable {
  public internal(set) var selection: Selection?

  var credentials: UserCredentials
  var roster = RosterState()
  var footer: FooterState
  var toolbar = ToolbarState()

  var sheet: Sheet?

  public init(credentials: UserCredentials, selection: Selection? = nil) {
    self.credentials = credentials
    self.selection = selection
    self.footer = .init(credentials: credentials)
  }
}

public extension SidebarState {
  enum Selection: Hashable {
    case unreadStack
    case replies
    case directMessages
    case peopleAndGroups
    case chat(JID)
  }
}

public extension SidebarState {
  enum Sheet: Equatable {
    case addMember(AddMemberSheetState)
    case joinGroup(JoinGroupSheetState)
  }
}

public enum SidebarAction: Equatable {
  case onAppear
  case onDisappear

  case selection(SidebarState.Selection?)

  case addContactButtonTapped
  case addGroupButtonTapped

  case rosterResult(Result<Roster, EquatableError>)
  case activeChatsResult(Result<[JID: Chat], EquatableError>)
  case presencesResult(Result<[JID: Presence], EquatableError>)

  case footer(FooterAction)
  case toolbar(ToolbarAction)

  case addMember(AddMemberSheetAction)
  case joinGroup(JoinGroupSheetAction)

  case showSheet(SidebarState.Sheet?)
}

public struct SidebarEnvironment {
  var proseClient: ProseClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(proseClient: ProseClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.proseClient = proseClient
    self.mainQueue = mainQueue
  }
}

extension SidebarEnvironment {
  var addMember: AddMemberSheetEnvironment {
    AddMemberSheetEnvironment(mainQueue: self.mainQueue)
  }

  var joinGroup: JoinGroupSheetEnvironment {
    JoinGroupSheetEnvironment(mainQueue: self.mainQueue)
  }
}

enum SidebarEffectToken: CaseIterable, Hashable {
  case rosterSubscription
  case presenceSubscription
  case activeChatsSubscription
}

public let sidebarReducer: Reducer<
  SidebarState,
  SidebarAction,
  SidebarEnvironment
> = Reducer.combine([
  footerReducer.pullback(
    state: \SidebarState.footer,
    action: CasePath(SidebarAction.footer),
    environment: { $0 }
  ),
  toolbarReducer.pullback(
    state: \SidebarState.toolbar,
    action: CasePath(SidebarAction.toolbar),
    environment: { _ in () }
  ),
  addMemberReducer._pullback(
    state: (\SidebarState.sheet).case(CasePath(SidebarState.Sheet.addMember)),
    action: CasePath(SidebarAction.addMember),
    environment: \.addMember
  ),
  joinGroupReducer._pullback(
    state: (\SidebarState.sheet).case(CasePath(SidebarState.Sheet.joinGroup)),
    action: CasePath(SidebarAction.joinGroup),
    environment: \.joinGroup
  ),
  Reducer { state, action, _ in
    switch action {
    case .onAppear:
      return .none

    case .onDisappear:
      return .cancel(token: SidebarEffectToken.self)

    case let .selection(selection):
      state.selection = selection
      return .none

    case .addContactButtonTapped:
      state.sheet = .addMember(AddMemberSheetState())
      return .none

    case .addGroupButtonTapped:
      state.sheet = .joinGroup(JoinGroupSheetState())
      return .none

    case let .showSheet(sheet):
      state.sheet = sheet
      return .none

    case .addMember(.cancelTapped), .joinGroup(.cancelTapped):
      state.sheet = nil
      return .none

    default:
      return .none
    }
  },
])
.roster()
