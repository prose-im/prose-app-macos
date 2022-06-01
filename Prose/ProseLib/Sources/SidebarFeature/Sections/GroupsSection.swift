//
//  GroupsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import ComposableArchitecture
import SwiftUI

// swiftlint:disable file_types_order

// MARK: - View

struct GroupsSection: View {
    typealias State = GroupsSectionState
    typealias Action = GroupsSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    @Binding var route: Route?

    var body: some View {
        Section("sidebar_section_groups".localized()) {
            WithViewStore(self.store.scope(state: \State.items)) { items in
                ForEach(items.state) { item in
                    NavigationLink(tag: item.id, selection: $route) {
                        NavigationDestinationView(selection: item.id)
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
                title: "sidebar_groups_add",
                systemImage: "plus.square.fill"
            ) { actions.send(.addGroupTapped) }
        }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

let groupsSectionReducer: Reducer<
    GroupsSectionState,
    GroupsSectionAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .addGroupTapped:
        // TODO: [Rémi Bardon] Handle action
        print("Add group tapped")
    }

    return .none
}

// MARK: State

public struct GroupsSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .group(id: "group-bugs"),
            title: "bugs",
            image: "circle.grid.2x2",
            count: 0
        ),
        .init(
            id: .group(id: "group-constellation"),
            title: "constellation",
            image: "circle.grid.2x2",
            count: 7
        ),
        .init(
            id: .group(id: "group-general"),
            title: "general",
            image: "circle.grid.2x2",
            count: 0
        ),
        .init(
            id: .group(id: "group-support"),
            title: "support",
            image: "circle.grid.2x2",
            count: 0
        ),
    ]

    public init() {}
}

// MARK: Actions

public enum GroupsSectionAction: Equatable {
    case addGroupTapped
}

// MARK: - Previews

struct GroupsSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: Route?

        var body: some View {
            NavigationView {
                List {
                    GroupsSection(
                        store: Store(
                            initialState: .init(),
                            reducer: groupsSectionReducer,
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
