//
//  FavoritesSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import PreviewAssets
import SwiftUI
import TcaHelpers

private let l10n = L10n.Sidebar.Favorites.self

// MARK: - View

struct FavoritesSection: View {
    typealias State = FavoritesSectionState
    typealias Action = FavoritesSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    @Binding var route: SidebarRoute?

    var body: some View {
        Section(l10n.title) {
            WithViewStore(self.store.scope(state: \State.items)) { items in
                ForEach(items.state) { item in
                    NavigationLink(tag: item.id, selection: $route) {
                        IfLetStore(
                            self.store.scope(state: \.destination.wrappedValue, action: Action.destination),
                            then: NavigationDestinationView.init(store:)
                        )
                    } label: {
                        ContactRow(
                            title: item.title,
                            avatar: item.image,
                            count: item.count
                        )
                    }
                }
            }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let favoritesSectionReducer: Reducer<
    FavoritesSectionState,
    FavoritesSectionAction,
    SidebarEnvironment
> = navigationDestinationReducer.optional().pullback(
    state: \FavoritesSectionState.destination.wrappedValue,
    action: /FavoritesSectionAction.destination,
    environment: {
        NavigationDestinationEnvironment(
            messageStore: $0.messageStore
        )
    }
)

// MARK: State

public struct FavoritesSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .chat(id: .person(id: "valerian@crisp.chat")),
            title: "Valerian",
            image: PreviewImages.Avatars.valerian.rawValue,
            count: 0
        ),
        .init(
            id: .chat(id: .person(id: "alexandre@crisp.chat")),
            title: "Alexandre",
            image: PreviewImages.Avatars.alexandre.rawValue,
            count: 0
        ),
        .init(
            id: .chat(id: .person(id: "baptiste@crisp.chat")),
            title: "Baptiste",
            image: PreviewImages.Avatars.baptiste.rawValue,
            count: 0
        ),
    ]
    var destination: Box<NavigationDestinationState?>

    public init(
        destination: Box<NavigationDestinationState?> = Box()
    ) {
        self.destination = destination
    }
}

// MARK: Actions

public enum FavoritesSectionAction: Equatable {
    case navigate(SidebarRoute?)
    case destination(NavigationDestinationAction)
}

// MARK: - Previews

internal struct FavoritesSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: SidebarRoute?

        var body: some View {
            NavigationView {
                List {
                    FavoritesSection(
                        store: Store(
                            initialState: .init(),
                            reducer: favoritesSectionReducer,
                            environment: .init(
                                messageStore: .stub
                            )
                        ),
                        route: $route
                    )
                }
                .frame(width: 256)
            }
        }
    }

    static var previews: some View {
        Preview(route: nil)
    }
}
