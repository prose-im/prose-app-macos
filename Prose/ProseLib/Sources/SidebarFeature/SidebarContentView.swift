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

// MARK: - The Composabe Architecture

// MARK: Reducer

private let sidebarContentCoreReducer: Reducer<
    SidebarContentState,
    SidebarContentAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .spotlight, .favorites, .teamMembers, .otherContacts, .groups, .binding:
        break
    }

    return .none
}.binding()
public let sidebarContentReducer: Reducer<
    SidebarContentState,
    SidebarContentAction,
    Void
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
    sidebarContentCoreReducer,
])

// MARK: State

public struct SidebarContentState: Equatable {
    public var spotlight: SpotlightSectionState
    public var favorites: FavoritesSectionState
    public var teamMembers: TeamMembersSectionState
    public var otherContacts: OtherContactsSectionState
    public var groups: GroupsSectionState

    @BindableState public var route: Route?

    public init(
        route: Route? = .unread,
        spotlight: SpotlightSectionState = .init(),
        favorites: FavoritesSectionState = .init(),
        teamMembers: TeamMembersSectionState = .init(),
        otherContacts: OtherContactsSectionState = .init(),
        groups: GroupsSectionState = .init()
    ) {
        self.route = route
        self.spotlight = spotlight
        self.favorites = favorites
        self.teamMembers = teamMembers
        self.otherContacts = otherContacts
        self.groups = groups
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
                environment: ()
            ))
            .frame(width: 256)
        }
    }
}
