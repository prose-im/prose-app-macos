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

    @Binding var route: Route?

    var body: some View {
        Section(l10n.title) {
            WithViewStore(self.store.scope(state: \State.items)) { items in
                ForEach(items.state) { item in
                    NavigationLink(tag: item.id, selection: $route) {
                        NavigationDestinationView(selection: item.id)
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

// MARK: - The Composabe Architecture

// MARK: Reducer

let favoritesSectionReducer: Reducer<
    FavoritesSectionState,
    FavoritesSectionAction,
    Void
> = Reducer.empty

// MARK: State

public struct FavoritesSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .chat(id: .person(id: "id-valerian")),
            title: "Valerian",
            image: PreviewImages.Avatars.valerian.rawValue,
            count: 0
        ),
        .init(
            id: .chat(id: .person(id: "id-alexandre")),
            title: "Alexandre",
            image: PreviewImages.Avatars.alexandre.rawValue,
            count: 0
        ),
    ]

    public init() {}
}

// MARK: Actions

public enum FavoritesSectionAction: Equatable {}

// MARK: - Previews

internal struct FavoritesSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: Route?

        var body: some View {
            NavigationView {
                List {
                    FavoritesSection(
                        store: Store(
                            initialState: .init(),
                            reducer: favoritesSectionReducer,
                            environment: ()
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
