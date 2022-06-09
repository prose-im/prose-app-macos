//
//  SpotlightSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Spotlight.self

// MARK: - View

struct SpotlightSection: View {
    typealias State = SpotlightSectionState
    typealias Action = SpotlightSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    @Binding var route: SidebarRoute?

    var body: some View {
        Section(l10n.title) {
            WithViewStore(self.store.scope(state: \State.items)) { items in
                ForEach(items.state) { item in
                    NavigationLink(tag: item.id, selection: $route) {
                        IfLetStore(
                            self.store.scope(state: \State.route, action: Action.destination),
                            then: NavigationDestinationView.init(store:)
                        )
                    } label: {
                        NavigationRow(
                            title: item.title,
                            image: item.image,
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

let spotlightSectionReducer: Reducer<
    SpotlightSectionState,
    SpotlightSectionAction,
    SidebarEnvironment
> = navigationDestinationReducer.optional().pullback(
    state: \SpotlightSectionState.route,
    action: /SpotlightSectionAction.destination,
    environment: { $0.destination }
)

// MARK: State

public struct SpotlightSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(id: .unread(.init()), title: l10n.unreadStack, image: Icon.unread.rawValue, count: 0),
        .init(id: .replies, title: l10n.replies, image: Icon.reply.rawValue, count: 5),
        .init(id: .directMessages, title: l10n.directMessages, image: Icon.directMessage.rawValue, count: 0),
        .init(id: .peopleAndGroups, title: l10n.peopleAndGroups, image: Icon.group.rawValue, count: 2),
    ]
    var route: SidebarRoute?

    public init(
        route: SidebarRoute? = nil
    ) {
        self.route = route
    }
}

// MARK: Actions

public enum SpotlightSectionAction: Equatable {
    case navigate(SidebarRoute?)
    case destination(NavigationDestinationAction)
}

// MARK: - Previews

struct SpotlightSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: SidebarRoute?

        var body: some View {
            NavigationView {
                List {
                    SpotlightSection(
                        store: Store(
                            initialState: .init(),
                            reducer: spotlightSectionReducer,
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
    }
}
