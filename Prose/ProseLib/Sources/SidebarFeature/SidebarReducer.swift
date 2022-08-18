//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
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
}

public struct SidebarEnvironment {
  var proseClient: ProseClient
  var mainQueue: AnySchedulerOf<DispatchQueue>

  public init(proseClient: ProseClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
    self.proseClient = proseClient
    self.mainQueue = mainQueue
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
      logger.info("Add contact button tapped")
      return .none

    case .addGroupButtonTapped:
      logger.info("Add group button tapped")
      return .none

    case .footer, .toolbar, .rosterResult, .activeChatsResult, .presencesResult:
      return .none
    }
  },
])
.roster()
