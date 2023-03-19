import ComposableArchitecture
import Foundation
import ProseCoreFFI
import ProseCoreTCA

struct RosterState: Equatable {
  var roster: Roster = .init(groups: [])
  var unreadCounts = [BareJid: Int]()
  var presences = [BareJid: Presence]()
  var userInfos = [BareJid: UserInfo]()
}

extension SessionState<RosterState> {
  var sidebar: SidebarRoster {
    var groups = [String: [SidebarRoster.Group.Item]]()
    for item in self.selectedAccount.roster {
      for group in item.groups {
        groups[group, default: []].append(.init(
          jid: item.jid,
          numberOfUnreadMessages: 0,
          status: .offline
        ))
      }
    }

    return SidebarRoster(groups: groups.map { groupName, items in
      SidebarRoster.Group(name: groupName, items: items)
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
    var jid: BareJid
    var avatarURL: URL?
    var numberOfUnreadMessages: Int
    var status: OnlineStatus
  }
}

// struct RosterReducer: ReducerProtocol {
//  typealias State = Sidebar.State
//  typealias Action = Sidebar.Action
//
//  public init() {}
//
//  @Dependency(\.legacyProseClient) var proseClient
//  @Dependency(\.mainQueue) var mainQueue
//
//  public var body: some ReducerProtocol<State, Action> {
//    Reduce { state, action in
//      switch action {
//      case .onAppear:
//        return .merge(
//          self.proseClient.roster()
//            .receive(on: self.mainQueue)
//            .catchToEffect(Action.rosterResult)
//            .cancellable(
//              id: SidebarEffectToken.rosterSubscription,
//              cancelInFlight: true
//            ),
//          self.proseClient.presence()
//            .receive(on: self.mainQueue)
//            .catchToEffect(Action.presencesResult)
//            .cancellable(
//              id: SidebarEffectToken.presenceSubscription,
//              cancelInFlight: true
//            ),
//          self.proseClient.activeChats()
//            .receive(on: self.mainQueue)
//            .catchToEffect(Action.activeChatsResult)
//            .cancellable(
//              id: SidebarEffectToken.activeChatsSubscription,
//              cancelInFlight: true
//            )
//        )
//
//      case let .rosterResult(.success(roster)):
//        state.roster.roster = roster
//
//        return self.proseClient
//          .userInfos(Set(roster.groups.flatMap { $0.items.map(\.jid) }))
//          .receive(on: self.mainQueue)
//          .catchToEffect(Action.userInfosResult)
//          .cancellable(id: SidebarEffectToken.userInfosSubscription, cancelInFlight: true)
//
//      case let .rosterResult(.failure(error)):
//        logger.error(
//          "Could not load roster. \(error.localizedDescription, privacy: .public)"
//        )
//        return .none
//
//      case let .activeChatsResult(.success(chats)):
//        state.roster.unreadCounts =
//          chats.mapValues(\.numberOfUnreadMessages)
//        return .none
//
//      case let .activeChatsResult(.failure(error)):
//        logger.error(
//          "Could not load active chats. \(error.localizedDescription, privacy: .public)"
//        )
//        return .none
//
//      case let .presencesResult(.success(presences)):
//        state.roster.presences = presences
//        return .none
//
//      case let .presencesResult(.failure(error)):
//        logger.error(
//          "Could not load presences. \(error.localizedDescription, privacy: .public)"
//        )
//        return .none
//
//      case let .userInfosResult(.success(userInfos)):
//        state.roster.userInfos = userInfos
//        return .none
//
//      case let .userInfosResult(.failure(error)):
//        logger.error(
//          "Could not load user infos. \(error.localizedDescription, privacy: .public)"
//        )
//        return .none
//
//      case .onDisappear, .selection, .addContactButtonTapped, .addGroupButtonTapped,
//           .footer, .addMember, .joinGroup, .setRoute:
//        return .none
//      }
//    }
//  }
// }
