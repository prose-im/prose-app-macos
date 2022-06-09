//
//  GroupsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Groups.self

// MARK: - View

struct GroupsSection: View {
    typealias State = GroupsSectionState
    typealias Action = GroupsSectionAction

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

            ActionRow(
                title: l10n.Add.label,
                systemImage: "plus.square.fill"
            ) { actions.send(.addGroupTapped) }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let groupsSectionReducer: Reducer<
    GroupsSectionState,
    GroupsSectionAction,
    SidebarEnvironment
> = Reducer.combine([
    navigationDestinationReducer.optional().pullback(
        state: \GroupsSectionState.route,
        action: /GroupsSectionAction.destination,
        environment: { $0.destination }
    ),
    Reducer { _, action, _ in
        switch action {
        case .addGroupTapped:
            // TODO: [Rémi Bardon] Handle action
            print("Add group tapped")

        case .navigate, .destination:
            break
        }

        return .none
    },
])

// MARK: State

public struct GroupsSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .chat(.init(chatId: .group(id: "bugs@crisp.chat"))),
            title: "bugs",
            image: Icon.group.rawValue,
            count: 0
        ),
        .init(
            id: .chat(.init(chatId: .group(id: "constellation@crisp.chat"))),
            title: "constellation",
            image: Icon.group.rawValue,
            count: 7
        ),
        .init(
            id: .chat(.init(chatId: .group(id: "general@crisp.chat"))),
            title: "general",
            image: Icon.group.rawValue,
            count: 0
        ),
        .init(
            id: .chat(.init(chatId: .group(id: "support@crisp.chat"))),
            title: "support",
            image: Icon.group.rawValue,
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

public enum GroupsSectionAction: Equatable {
    case addGroupTapped
    case navigate(SidebarRoute?)
    case destination(NavigationDestinationAction)
}

// MARK: - Previews

struct GroupsSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: SidebarRoute?

        var body: some View {
            NavigationView {
                List {
                    GroupsSection(
                        store: Store(
                            initialState: .init(),
                            reducer: groupsSectionReducer,
                            environment: .shared
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
