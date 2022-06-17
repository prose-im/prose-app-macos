//
//  IdentitySection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import Assets
import ComposableArchitecture
import ProseCoreStub
import ProseUI
import SharedModels
import SwiftUI

// MARK: - View

struct IdentitySection: View {
    typealias State = IdentitySectionState
    typealias Action = IdentitySectionAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            avatar()
                .frame(width: 100.0, height: 100.0)
                .cornerRadius(10.0)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

            VStack(spacing: 4) {
                WithViewStore(self.store) { viewStore in
                    ContentCommonNameStatusComponent(
                        name: viewStore.fullName,
                        status: viewStore.status
                    )

                    Text("\(viewStore.jobTitle) at \(viewStore.company)")
                        .font(.system(size: 11.5))
                        .foregroundColor(Asset.Color.Text.secondary.swiftUIColor)
                }
            }
        }
    }

    private func avatar() -> some View {
        WithViewStore(self.store.scope(state: \State.avatar)) { avatar in
            if let imageName = avatar.state {
                Image(imageName)
                    .resizable()
            } else {
                Image(systemName: "person.fill")
            }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let identitySectionReducer: Reducer<
    IdentitySectionState,
    IdentitySectionAction,
    Void
> = Reducer.empty

// MARK: State

public struct IdentitySectionState: Equatable {
    let avatar: String?
    let fullName: String
    let status: OnlineStatus
    let jobTitle: String
    let company: String

    public init(
        avatar: String?,
        fullName: String,
        status: OnlineStatus,
        jobTitle: String,
        company: String
    ) {
        self.avatar = avatar
        self.fullName = fullName
        self.status = status
        self.jobTitle = jobTitle
        self.company = company
    }
}

public extension IdentitySectionState {
    init(
        from user: User,
        status: OnlineStatus
    ) {
        self.init(
            avatar: user.avatar,
            fullName: user.fullName,
            status: status,
            jobTitle: user.jobTitle,
            company: user.company
        )
    }
}

extension IdentitySectionState {
    static var placeholder: IdentitySectionState {
        IdentitySectionState(
            from: .placeholder,
            status: .offline
        )
    }
}

extension IdentitySectionState {
    /// Only for previews
    static var valerian: Self {
        Self(
            avatar: "avatars/valerian",
            fullName: "Valerian Saliou",
            status: .online,
            jobTitle: "CTO",
            company: "Crisp"
        )
    }
}

// MARK: Actions

public enum IdentitySectionAction: Equatable {}

// MARK: - Previews

struct IdentitySection_Previews: PreviewProvider {
    private struct Preview: View {
        let state: IdentitySectionState

        var body: some View {
            IdentitySection(store: Store(
                initialState: state,
                reducer: identitySectionReducer,
                environment: ()
            ))
        }
    }

    static var previews: some View {
        Preview(state: .valerian)
    }
}
