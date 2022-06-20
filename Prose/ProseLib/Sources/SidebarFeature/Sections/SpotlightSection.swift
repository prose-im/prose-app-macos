//
//  SpotlightSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import Assets
import ComposableArchitecture
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Spotlight.self

// MARK: - View

struct SpotlightSection: View {
    typealias State = SpotlightSectionState
    typealias Action = SpotlightSectionAction

    @Environment(\.redactionReasons) private var redactionReasons

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
                        HStack {
                            switch item.image {
                            case let .symbol(systemName):
                                Label(item.title, systemImage: systemName)
                                    .unredacted()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            default:
                                // TODO: Get rid of `SidebarItem` which forces us to handle such cases.
                                fatalError("This case should never happen.")
                            }
                            Counter(count: item.count)
                        }
                    }
                }
            }
        } header: {
            Text(l10n.title)
                .unredacted()
        }
        .disabled(redactionReasons.contains(.placeholder))
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
    action: CasePath(SpotlightSectionAction.destination),
    environment: { $0.destination }
)

// MARK: State

public struct SpotlightSectionState: Equatable {
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
                            initialState: .init(items: [
                                .unread(),
                                .replies(5),
                                .directMessages(),
                                .peopleAndGroups(2),
                            ]),
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
        Preview(route: nil)
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
