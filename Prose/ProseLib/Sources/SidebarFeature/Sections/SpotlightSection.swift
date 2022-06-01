//
//  SpotlightSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import ComposableArchitecture
import SwiftUI

// swiftlint:disable file_types_order

// MARK: - View

struct SpotlightSection: View {
    typealias State = SpotlightSectionState
    typealias Action = SpotlightSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    @Binding var route: Route?

    var body: some View {
        Section("sidebar_section_spotlight".localized()) {
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
        }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

let spotlightSectionReducer: Reducer<
    SpotlightSectionState,
    SpotlightSectionAction,
    Void
> = Reducer.empty

// MARK: State

public struct SpotlightSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .unread,
            title: "sidebar_spotlight_unread_stack".localized(),
            image: "tray.2",
            count: 0
        ),
        .init(
            id: .replies,
            title: "sidebar_spotlight_replies".localized(),
            image: "arrowshape.turn.up.left.2",
            count: 5
        ),
        .init(
            id: .directMessages,
            title: "sidebar_spotlight_direct_messages".localized(),
            image: "message",
            count: 0
        ),
        .init(
            id: .peopleAndGroups,
            title: "sidebar_spotlight_people_and_groups".localized(),
            image: "text.book.closed",
            count: 2
        ),
    ]

    public init() {}
}

// MARK: Actions

public enum SpotlightSectionAction: Equatable {}

// MARK: - Previews

struct SpotlightSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: Route?

        var body: some View {
            NavigationView {
                List {
                    SpotlightSection(
                        store: Store(
                            initialState: .init(),
                            reducer: spotlightSectionReducer,
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
