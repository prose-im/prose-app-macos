//
//  FavoritesSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
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
                        switch item.image {
                        case let .avatar(avatar):
                            ContactRow(
                                title: item.title,
                                avatar: avatar,
                                count: item.count
                            )
                        default:
                            // TODO: Get rid of `SidebarItem` which forces us to handle such cases.
                            fatalError("This case should never happen.")
                        }
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
    var items: [SidebarItem]
    var route: SidebarRoute?

    public init(
        items: [SidebarItem],
        route: SidebarRoute? = nil
    ) {
        self.items = items
        self.route = route
    }
}

// MARK: Actions

public enum FavoritesSectionAction: Equatable {
    case navigate(SidebarRoute?)
    case destination(NavigationDestinationAction)
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    internal struct FavoritesSection_Previews: PreviewProvider {
        private struct Preview: View {
            @State var route: SidebarRoute?

            var body: some View {
                NavigationView {
                    List {
                        FavoritesSection(
                            store: Store(
                                initialState: .init(items: [
                                    .person(
                                        "valerian@crisp.chat",
                                        title: "Valerian",
                                        image: .init(url: PreviewAsset.Avatars.valerian.customURL)
                                    ),
                                    .person(
                                        "alexandre@crisp.chat",
                                        title: "Alexandre",
                                        image: .init(url: PreviewAsset.Avatars.alexandre.customURL)
                                    ),
                                    .person(
                                        "baptiste@crisp.chat",
                                        title: "Baptiste",
                                        image: .init(url: PreviewAsset.Avatars.baptiste.customURL)
                                    ),
                                ]),
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
#endif
