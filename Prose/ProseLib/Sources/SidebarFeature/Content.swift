//
//  Content.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import ComposableArchitecture
import SwiftUI

// swiftlint:disable file_types_order

struct Content: View {
    typealias State = ContentState
    typealias Action = ContentAction

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
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

private let contentCoreReducer: Reducer<
    ContentState,
    ContentAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .spotlight, .favorites, .teamMembers, .otherContacts, .groups, .binding:
        break
    }

    return .none
}.binding()
public let contentReducer: Reducer<
    ContentState,
    ContentAction,
    Void
> = Reducer.combine([
    spotlightSectionReducer.pullback(
        state: \ContentState.spotlight,
        action: /ContentAction.spotlight,
        environment: { $0 }
    ),
    favoritesSectionReducer.pullback(
        state: \ContentState.favorites,
        action: /ContentAction.favorites,
        environment: { $0 }
    ),
    teamMembersSectionReducer.pullback(
        state: \ContentState.teamMembers,
        action: /ContentAction.teamMembers,
        environment: { $0 }
    ),
    otherContactsSectionReducer.pullback(
        state: \ContentState.otherContacts,
        action: /ContentAction.otherContacts,
        environment: { $0 }
    ),
    groupsSectionReducer.pullback(
        state: \ContentState.groups,
        action: /ContentAction.groups,
        environment: { $0 }
    ),
    contentCoreReducer,
])

// MARK: State

public struct ContentState: Equatable {
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

public enum ContentAction: Equatable, BindableAction {
    case spotlight(SpotlightSectionAction)
    case favorites(FavoritesSectionAction)
    case teamMembers(TeamMembersSectionAction)
    case otherContacts(OtherContactsSectionAction)
    case groups(GroupsSectionAction)
    case binding(BindingAction<ContentState>)
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Content(store: Store(
                initialState: .init(),
                reducer: contentReducer,
                environment: ()
            ))
            .frame(width: 256)
        }
    }
}
