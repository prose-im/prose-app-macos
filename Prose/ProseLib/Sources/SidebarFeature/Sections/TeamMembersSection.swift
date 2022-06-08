//
//  Sidebar+TeamMembersSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import PreviewAssets
import SwiftUI

private let l10n = L10n.Sidebar.TeamMembers.self

// MARK: - View

struct TeamMembersSection: View {
    typealias State = TeamMembersSectionState
    typealias Action = TeamMembersSectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    @Binding var route: SidebarRoute?

    var body: some View {
        Section(l10n.title) {
            WithViewStore(self.store.scope(state: \State.items)) { items in
                ForEach(items.state) { item in
                    NavigationLink(tag: item.id, selection: $route) {
                        IfLetStore(
                            self.store.scope(state: \State.destination, action: Action.destination),
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
            ) { actions.send(.addTeamMemberTapped) }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

let teamMembersSectionReducer: Reducer<
    TeamMembersSectionState,
    TeamMembersSectionAction,
    Void
> = Reducer.combine([
    navigationDestinationReducer.optional().pullback(
        state: \TeamMembersSectionState.destination,
        action: /TeamMembersSectionAction.destination,
        environment: { _ in NavigationDestinationEnvironment() }
    ),
    Reducer { _, action, _ in
        switch action {
        case .addTeamMemberTapped:
            // TODO: [Rémi Bardon] Handle action
            print("Add team member tapped")

        case .navigate, .destination:
            break
        }

        return .none
    },
])

// MARK: State

public struct TeamMembersSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .chat(id: .person(id: "antoine@crisp.chat")),
            title: "Antoine",
            image: PreviewImages.Avatars.antoine.rawValue,
            count: 0
        ),
        .init(
            id: .chat(id: .person(id: "eliott@crisp.chat")),
            title: "Eliott",
            image: PreviewImages.Avatars.eliott.rawValue,
            count: 3
        ),
        .init(
            id: .chat(id: .person(id: "camille@crisp.chat")),
            title: "Camille",
            image: PreviewImages.Avatars.camille.rawValue,
            count: 2
        ),
    ]
    var destination: NavigationDestinationState?

    public init(
        destination: NavigationDestinationState? = nil
    ) {
        self.destination = destination
    }
}

// MARK: Actions

public enum TeamMembersSectionAction: Equatable {
    case addTeamMemberTapped
    case navigate(SidebarRoute?)
    case destination(NavigationDestinationAction)
}

// MARK: - Previews

struct TeamMembersSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: SidebarRoute?

        var body: some View {
            NavigationView {
                List {
                    TeamMembersSection(
                        store: Store(
                            initialState: .init(),
                            reducer: teamMembersSectionReducer,
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
