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

private let l10n = L10n.Sidebar.Favorites.self

// MARK: - View

struct FavoritesSection: View {
    typealias State = FavoritesSectionState
    typealias Action = FavoritesSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    @Binding var route: SidebarRoute?

    var body: some View {
        Section {
            WithViewStore(self.store.scope(state: \State.items)) { items in
                ForEach(items.state) { item in
                    NavigationLink(tag: item.id, selection: $route) {
                        IfLetStore(
                            self.store.scope(state: \State.route, action: Action.destination),
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
        } header: {
            Text(l10n.title)
                .unredacted()
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
    state: \FavoritesSectionState.route,
    action: CasePath(FavoritesSectionAction.destination),
    environment: { $0.destination }
)

// MARK: State

public struct FavoritesSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .chat(.init(chatId: .person(id: "valerian@crisp.chat"))),
            title: "Valerian",
            image: .nsImage(PreviewAsset.Avatars.valerian.image),
            count: 0
        ),
        .init(
            id: .chat(.init(chatId: .person(id: "alexandre@crisp.chat"))),
            title: "Alexandre",
            image: .nsImage(PreviewAsset.Avatars.alexandre.image),
            count: 0
        ),
        .init(
            id: .chat(.init(chatId: .person(id: "baptiste@crisp.chat"))),
            title: "Baptiste",
            image: .nsImage(PreviewAsset.Avatars.baptiste.image),
            count: 0
        ),
    ]
    var route: SidebarRoute?

    public init(
        route: SidebarRoute? = nil
    ) {
        self.route = route
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
                            environment: .stub
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
        Preview(route: nil)
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
