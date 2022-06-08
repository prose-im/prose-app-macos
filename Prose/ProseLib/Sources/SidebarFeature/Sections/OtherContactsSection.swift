//
//  OtherContactsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import PreviewAssets
import SwiftUI
import TcaHelpers

private let l10n = L10n.Sidebar.OtherContacts.self

// MARK: - View

struct OtherContactsSection: View {
    typealias State = OtherContactsSectionState
    typealias Action = OtherContactsSectionAction

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

            ActionRow(
                title: l10n.Add.label,
                systemImage: "plus.square.fill"
            ) { actions.send(.addContactTapped) }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let otherContactsSectionReducer: Reducer<
    OtherContactsSectionState,
    OtherContactsSectionAction,
    SidebarEnvironment
> = Reducer.combine([
    navigationDestinationReducer.optional().pullback(
        state: \OtherContactsSectionState.destination.wrappedValue,
        action: /OtherContactsSectionAction.destination,
        environment: {
            NavigationDestinationEnvironment(
                messageStore: $0.messageStore
            )
        }
    ),
    Reducer { _, action, _ in
        switch action {
        case .addContactTapped:
            // TODO: [Rémi Bardon] Handle action
            print("Add contact tapped")

        case .navigate, .destination:
            break
        }

        return .none
    },
])

// MARK: State

public struct OtherContactsSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .chat(id: .person(id: "julien@thefamily.com")),
            title: "Julien",
            image: PreviewImages.Avatars.julien.rawValue,
            count: 2
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

public enum OtherContactsSectionAction: Equatable {
    case addContactTapped
    case navigate(SidebarRoute?)
    case destination(NavigationDestinationAction)
}

// MARK: - Previews

struct OtherContactsSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: SidebarRoute?

        var body: some View {
            NavigationView {
                List {
                    OtherContactsSection(
                        store: Store(
                            initialState: .init(),
                            reducer: otherContactsSectionReducer,
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
