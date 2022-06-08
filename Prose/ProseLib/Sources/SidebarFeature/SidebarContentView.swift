//
//  SidebarContentView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import ComposableArchitecture
import ProseCoreStub
import SwiftUI
import TcaHelpers

struct SidebarContentView: View {
    typealias State = SidebarContentState
    typealias Action = SidebarContentAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        List {
            WithViewStore(self.store) { viewStore in
                let routeBinding = viewStore.binding(\State.$route)
                SpotlightSection(
                    store: self.store.scope(state: \.spotlight, action: Action.spotlight),
                    route: routeBinding
                )
                FavoritesSection(
                    store: self.store.scope(state: \.favorites, action: Action.favorites),
                    route: routeBinding
                )
                TeamMembersSection(
                    store: self.store.scope(state: \.teamMembers, action: Action.teamMembers),
                    route: routeBinding
                )
                OtherContactsSection(
                    store: self.store.scope(state: \.otherContacts, action: Action.otherContacts),
                    route: routeBinding
                )
                GroupsSection(
                    store: self.store.scope(state: \.groups, action: Action.groups),
                    route: routeBinding
                )
            }
        }
        .listStyle(.sidebar)
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let sidebarContentReducer: Reducer<
    SidebarContentState,
    SidebarContentAction,
    SidebarEnvironment
> = Reducer.combine([
    spotlightSectionReducer.pullback(
        state: \SidebarContentState.spotlight,
        action: /SidebarContentAction.spotlight,
        environment: { $0 }
    ),
    favoritesSectionReducer.pullback(
        state: \SidebarContentState.favorites,
        action: /SidebarContentAction.favorites,
        environment: { $0 }
    ),
    teamMembersSectionReducer.pullback(
        state: \SidebarContentState.teamMembers,
        action: /SidebarContentAction.teamMembers,
        environment: { $0 }
    ),
    otherContactsSectionReducer.pullback(
        state: \SidebarContentState.otherContacts,
        action: /SidebarContentAction.otherContacts,
        environment: { $0 }
    ),
    groupsSectionReducer.pullback(
        state: \SidebarContentState.groups,
        action: /SidebarContentAction.groups,
        environment: { $0 }
    ),
    Reducer { state, action, _ in
        // Before route is updated, save the current state
        if case .binding(\.$route) = action, let route = state.route {
            state.states[route] = state.destination.wrappedValue
        }
        return .none
    },
    Reducer { state, action, _ in
        switch action {
        case .binding(\.$route):
            func createState(for route: SidebarRoute) -> NavigationDestinationState {
                let destination: NavigationDestinationState
                switch route {
                case .unread:
                    destination = NavigationDestinationState.unread(.init())
                case .replies:
                    destination = NavigationDestinationState.replies
                case .directMessages:
                    destination = NavigationDestinationState.directMessages
                case .peopleAndGroups:
                    destination = NavigationDestinationState.peopleAndGroups
                case let .chat(id):
                    destination = NavigationDestinationState.chat(.init(chatId: id))
                case .newMessage:
                    fatalError("Impossible")
                }
                print("Created a new `NavigationDestinationState`")
                return destination
            }
            if let route = state.route {
                let destination = state.states[route, default: createState(for: route)]
                state.states[route] = destination
                state.destination.wrappedValue = destination
            } else {
                state.destination.wrappedValue = nil
            }

        default:
            break
        }

        return .none
    }.binding(),
])

// MARK: State

public struct SidebarContentState: Equatable {
    var spotlight: SpotlightSectionState
    var favorites: FavoritesSectionState
    var teamMembers: TeamMembersSectionState
    var otherContacts: OtherContactsSectionState
    var groups: GroupsSectionState

    var states: [SidebarRoute: NavigationDestinationState]
    var destination: Box<NavigationDestinationState?>

    @BindableState var route: SidebarRoute?

    public init(
        route: SidebarRoute? = .unread,
        spotlight: SpotlightSectionState? = nil,
        favorites: FavoritesSectionState? = nil,
        teamMembers: TeamMembersSectionState? = nil,
        otherContacts: OtherContactsSectionState? = nil,
        groups: GroupsSectionState? = nil
    ) {
        self.route = route

        let states: [SidebarRoute: NavigationDestinationState] = [
            .unread: NavigationDestinationState.unread(.init()),
        ]
        self.states = states

        let destination = Box(route.flatMap { states[$0] })
        self.destination = destination
        self.spotlight = spotlight ?? .init(destination: destination)
        self.favorites = favorites ?? .init(destination: destination)
        self.teamMembers = teamMembers ?? .init(destination: destination)
        self.otherContacts = otherContacts ?? .init(destination: destination)
        self.groups = groups ?? .init(destination: destination)
    }
}

// MARK: Actions

public enum SidebarContentAction: Equatable, BindableAction {
    case spotlight(SpotlightSectionAction)
    case favorites(FavoritesSectionAction)
    case teamMembers(TeamMembersSectionAction)
    case otherContacts(OtherContactsSectionAction)
    case groups(GroupsSectionAction)
    case binding(BindingAction<SidebarContentState>)
}

struct SidebarContent_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SidebarContentView(store: Store(
                initialState: .init(),
                reducer: sidebarContentReducer,
                environment: .init(messageStore: .stub)
            ))
            .frame(width: 256)
        }
    }
}
