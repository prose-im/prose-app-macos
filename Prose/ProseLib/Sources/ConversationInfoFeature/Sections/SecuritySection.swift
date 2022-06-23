//
//  SecuritySection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import Assets
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Security.self

// MARK: - View

struct SecuritySection: View {
    typealias State = SecuritySectionState
    typealias Action = SecuritySectionAction

    @Environment(\.redactionReasons) private var redactionReasons

    let store: Store<State, Action>
    private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

    var body: some View {
        GroupBox(l10n.title) {
            identityVerified()
            encryption()
        }
    }

    private func identityVerified() -> some View {
        HStack(spacing: 8) {
            WithViewStore(self.store.scope(state: \State.isIdentityVerified)) { isIdentityVerified in
                if isIdentityVerified.state {
                    Label {
                        Text("Identity verified")
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Colors.State.green.color)
                    }
                } else {
                    Label {
                        Text("Identity not verified")
                    } icon: {
                        Image(systemName: "xmark.seal.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
            infoButton(action: { actions.send(.showIdVerificationInfoTapped) })
        }
    }

    private func encryption() -> some View {
        HStack(spacing: 8) {
            WithViewStore(self.store.scope(state: \State.encryptionFingerprint)) { fingerprint in
                if let fingerprint = fingerprint.state {
                    Label {
                        Text("Encrypted (\(fingerprint))")
                    } icon: {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Colors.State.blue.color)
                    }
                } else {
                    Label {
                        Text("Not encrypted")
                    } icon: {
                        Image(systemName: "lock.slash")
                            .foregroundColor(.red)
                    }
                }
            }
            infoButton(action: { actions.send(.showEncryptionInfoTapped) })
        }
    }

    func infoButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "info.circle")
                .foregroundColor(Color.primary.opacity(0.50))
        }
        .buttonStyle(.plain)
        .unredacted()
        .disabled(self.redactionReasons.contains(.placeholder))
    }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let securitySectionReducer: Reducer<
    SecuritySectionState,
    SecuritySectionAction,
    Void
> = Reducer { _, action, _ in
    switch action {
    case .showIdVerificationInfoTapped:
        logger.info("Show ID verification info tapped")

    case .showEncryptionInfoTapped:
        logger.info("Show encryption info tapped")
    }

    return .none
}

// MARK: State

public struct SecuritySectionState: Equatable {
    let isIdentityVerified: Bool
    let encryptionFingerprint: String?

    public init(
        isIdentityVerified: Bool,
        encryptionFingerprint: String?
    ) {
        self.isIdentityVerified = isIdentityVerified
        self.encryptionFingerprint = encryptionFingerprint
    }
}

extension SecuritySectionState {
    static var placeholder: SecuritySectionState {
        SecuritySectionState(
            isIdentityVerified: false,
            encryptionFingerprint: nil
        )
    }
}

// MARK: Actions

public enum SecuritySectionAction: Equatable {
    case showIdVerificationInfoTapped
    case showEncryptionInfoTapped
}

// MARK: - Previews

struct SecuritySection_Previews: PreviewProvider {
    private struct Preview: View {
        let state: SecuritySectionState

        var body: some View {
            SecuritySection(store: Store(
                initialState: state,
                reducer: securitySectionReducer,
                environment: ()
            ))
        }
    }

    static var previews: some View {
        Preview(state: .init(
            isIdentityVerified: true,
            encryptionFingerprint: "NW6DB"
        ))
        Preview(state: .init(
            isIdentityVerified: false,
            encryptionFingerprint: nil
        ))
    }
}
