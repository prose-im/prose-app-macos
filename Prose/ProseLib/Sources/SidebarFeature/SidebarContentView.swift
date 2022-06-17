//
//  SidebarContentView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import ComposableArchitecture
import SwiftUI

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
                    store: self.store.scope(state: \State.spotlight, action: Action.spotlight),
                    route: routeBinding
                )
                FavoritesSection(
                    store: self.store.scope(state: \State.favorites, action: Action.favorites),
                    route: routeBinding
                )
                TeamMembersSection(
                    store: self.store.scope(state: \State.teamMembers, action: Action.teamMembers),
                    route: routeBinding
                )
                OtherContactsSection(
                    store: self.store.scope(state: \State.otherContacts, action: Action.otherContacts),
                    route: routeBinding
                )
                GroupsSection(
                    store: self.store.scope(state: \State.groups, action: Action.groups),
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
        switch action {
        case .binding(\.$route):
            let route = state.route
            state.spotlight.route = route
            state.favorites.route = route
            state.teamMembers.route = route
            state.otherContacts.route = route
            state.groups.route = route

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

    @BindableState var route: SidebarRoute?

    public init(
        route: SidebarRoute? = .unread(.init()),
        spotlight: SpotlightSectionState? = nil,
        favorites: FavoritesSectionState? = nil,
        teamMembers: TeamMembersSectionState? = nil,
        otherContacts: OtherContactsSectionState? = nil,
        groups: GroupsSectionState? = nil
    ) {
        self.route = route
        self.spotlight = spotlight ?? .init(route: route)
        self.favorites = favorites ?? .init(route: route)
        self.teamMembers = teamMembers ?? .init(route: route)
        self.otherContacts = otherContacts ?? .init(route: route)
        self.groups = groups ?? .init(route: route)
    }
}

public extension SidebarContentState {
    static var placeholder: SidebarContentState {
        SidebarContentState(
            route: .unread(.init())
        )
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
    private struct Preview: View {
        var body: some View {
            NavigationView {
                SidebarContentView(store: Store(
                    initialState: .init(),
                    reducer: sidebarContentReducer,
                    environment: .stub
                ))
                .frame(width: 200)
            }
            .frame(width: 700)
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")
        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
        Preview()
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
