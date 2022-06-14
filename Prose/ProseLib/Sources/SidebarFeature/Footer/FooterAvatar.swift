//
//  FooterAvatar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import ComposableArchitecture
import ProseUI
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Footer.Actions.Account.self

// MARK: - View

/// User avatar in the left sidebar footer
struct FooterAvatar: View {
    typealias State = FooterAvatarState
    typealias Action = FooterAvatarAction

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            Button(action: { actions.send(.avatarTapped) }) {
                Avatar(viewStore.avatar, size: viewStore.size)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(l10n.label)
            .overlay(alignment: .bottomTrailing) {
                statusIndicator(viewStore: viewStore)
                    // Offset of half the size minus 2 points (otherwise it looks odd)
                    .alignmentGuide(.trailing) { d in d.width / 2 + 2 }
                    .alignmentGuide(.bottom) { d in d.height / 2 + 2 }
            }
        }
    }

    @ViewBuilder
    private func statusIndicator(viewStore: ViewStore<State, Action>) -> some View {
        if viewStore.status != .offline {
            OnlineStatusIndicator(status: viewStore.status)
                .padding(2)
                .background {
                    Circle()
                        .fill(Color.white)
                }
        }
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let footerAvatarReducer: Reducer<
    FooterAvatarState,
    FooterAvatarAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .avatarTapped:
        print("Avatar tapped")

    default:
        // TODO: [Rémi Bardon] Handle actions
        assertionFailure("Received unhandled action: \(String(describing: action))")
    }

    return .none
}

// MARK: State

public struct FooterAvatarState: Equatable {
    let avatar: String
    let status: OnlineStatus
    let size: CGFloat

    public init(
        avatar: String,
        status: OnlineStatus = .offline,
        size: CGFloat = 32
    ) {
        self.avatar = avatar
        self.status = status
        self.size = size
    }
}

// MARK: Actions

public enum FooterAvatarAction: Equatable {
    case avatarTapped
    case updateMoodTapped
    case changeAvailabilityTapped(Availability)
    case pauseNotificationsTapped
    case editProfileTapped
    case accountSettingsTapped
    case offlineModeTapped
    case signOutTapped
}

// MARK: - Previews

#if DEBUG
    import PreviewAssets

    struct FooterAvatar_Previews: PreviewProvider {
        private struct Preview: View {
            var body: some View {
                HStack {
                    ForEach(OnlineStatus.allCases, id: \.self) { status in
                        content(state: FooterAvatarState(
                            avatar: PreviewImages.Avatars.valerian.rawValue,
                            status: status
                        ))
                    }
                }
                .padding()
            }

            private func content(state: FooterAvatarState) -> some View {
                FooterAvatar(store: Store(
                    initialState: state,
                    reducer: footerAvatarReducer,
                    environment: ()
                ))
            }
        }

        static var previews: some View {
            Preview()
                .preferredColorScheme(.light)
                .previewDisplayName("Light")

            Preview()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark")
        }
    }
#endif
