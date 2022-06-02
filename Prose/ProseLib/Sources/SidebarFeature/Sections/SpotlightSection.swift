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

// swiftlint:disable file_types_order

private let l10n = L10n.Sidebar.Spotlight.self

// MARK: - View

struct SpotlightSection: View {
    typealias State = SpotlightSectionState
    typealias Action = SpotlightSectionAction

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
        .init(id: .unread, title: l10n.unreadStack, image: Icon.unread.rawValue, count: 0),
        .init(id: .replies, title: l10n.replies, image: Icon.reply.rawValue, count: 5),
        .init(id: .directMessages, title: l10n.directMessages, image: Icon.directMessage.rawValue, count: 0),
        .init(id: .peopleAndGroups, title: l10n.peopleAndGroups, image: Icon.group.rawValue, count: 2),
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
