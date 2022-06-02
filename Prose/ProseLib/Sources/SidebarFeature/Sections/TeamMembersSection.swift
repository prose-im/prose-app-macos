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

            ActionRow(
                title: l10n.Add.label,
                systemImage: "plus.square.fill"
            ) { actions.send(.addTeamMemberTapped) }
        }
    }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

let teamMembersSectionReducer: Reducer<
    TeamMembersSectionState,
    TeamMembersSectionAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .addTeamMemberTapped:
        // TODO: [Rémi Bardon] Handle action
        print("Add team member tapped")
    }

    return .none
}

// MARK: State

public struct TeamMembersSectionState: Equatable {
    let items: [SidebarItem] = [
        .init(
            id: .chat(id: .person(id: "id-antoine")),
            title: "Antoine",
            image: PreviewImages.Avatars.antoine.rawValue,
            count: 0
        ),
        .init(
            id: .chat(id: .person(id: "id-eliott")),
            title: "Eliott",
            image: PreviewImages.Avatars.eliott.rawValue,
            count: 3
        ),
        .init(
            id: .chat(id: .person(id: "id-camille")),
            title: "Camille",
            image: PreviewImages.Avatars.camille.rawValue,
            count: 2
        ),
    ]

    public init() {}
}

// MARK: Actions

public enum TeamMembersSectionAction: Equatable {
    case addTeamMemberTapped
}

// MARK: - Previews

struct TeamMembersSection_Previews: PreviewProvider {
    private struct Preview: View {
        @State var route: Route?

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
