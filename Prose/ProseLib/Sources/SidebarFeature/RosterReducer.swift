//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
import ProseCoreTCA

struct RosterState: Equatable {
  var roster: Roster = .init(groups: [])
  var unreadCounts = [JID: Int]()
  var presences = [JID: Presence]()
}

extension RosterState {
  var sidebar: SidebarRoster {
    SidebarRoster(groups: self.roster.groups.map { group in
      SidebarRoster.Group(
        name: group.name,
        items: group.items.map { item in
          SidebarRoster.Group.Item(
            jid: item.jid,
            numberOfUnreadMessages: self.unreadCounts[item.jid] ?? 0,
            status: self.presences[item.jid]?.onlineStatus ?? .offline
          )
        }
      )
    })
  }
}

private extension Presence {
  var onlineStatus: OnlineStatus {
    self.kind == .unavailable ? .offline : .online
  }
}

struct SidebarRoster: Equatable {
  var groups = [Group]()
}

extension SidebarRoster {
  struct Group: Equatable {
    var name: String
    var items = [Item]()
  }
}

extension SidebarRoster.Group {
  struct Item: Equatable {
    var jid: JID
    var numberOfUnreadMessages: Int
    var status: OnlineStatus
  }
}

extension Reducer where
  State == SidebarState,
  Action == SidebarAction,
  Environment == SidebarEnvironment
{
  func roster() -> Self {
    .combine(
      self,
      Reducer { state, action, environment in
        switch action {
        case .onAppear:
          return .merge(
            environment.proseClient.roster()
              .receive(on: environment.mainQueue)
              .catchToEffect()
              .map(SidebarAction.rosterResult)
              .cancellable(
                id: SidebarEffectToken.rosterSubscription,
                cancelInFlight: true
              ),
            environment.proseClient.presence()
              .receive(on: environment.mainQueue)
              .catchToEffect()
              .map(SidebarAction.presencesResult)
              .cancellable(
                id: SidebarEffectToken.presenceSubscription,
                cancelInFlight: true
              ),
            environment.proseClient.activeChats()
              .receive(on: environment.mainQueue)
              .catchToEffect()
              .map(SidebarAction.activeChatsResult)
              .cancellable(
                id: SidebarEffectToken.activeChatsSubscription,
                cancelInFlight: true
              )
          )

        case let .rosterResult(.success(roster)):
          state.roster.roster = roster
          return .none

        case let .rosterResult(.failure(error)):
          logger.error(
            "Could not load roster. \(error.localizedDescription, privacy: .public)"
          )
          return .none

        case let .activeChatsResult(.success(chats)):
          state.roster.unreadCounts =
            chats.mapValues(\.numberOfUnreadMessages)
          return .none

        case let .activeChatsResult(.failure(error)):
          logger.error(
            "Could not load active chats. \(error.localizedDescription, privacy: .public)"
          )
          return .none

        case let .presencesResult(.success(presences)):
          state.roster.presences = presences
          return .none

        case let .presencesResult(.failure(error)):
          logger.error(
            "Could not load presences. \(error.localizedDescription, privacy: .public)"
          )
          return .none

        case .onDisappear, .selection, .addContactButtonTapped, .addGroupButtonTapped,
             .footer, .toolbar:
          return .none
        }
      }
    )
  }
}
