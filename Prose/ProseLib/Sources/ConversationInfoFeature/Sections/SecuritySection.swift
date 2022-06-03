//
//  Info+SecuritySection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Security.self

struct SecuritySection: View {
    @Environment(\.redactionReasons) private var redactionReasons

    let model: SecuritySectionModel

    var body: some View {
        GroupBox(l10n.title) {
            HStack(spacing: 8) {
                if model.isIdentityVerified {
                    Label {
                        Text("Identity verified")
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.stateGreen)
                    }
                } else {
                    Label {
                        Text("Identity not verified")
                    } icon: {
                        Image(systemName: "xmark.seal.fill")
                            .foregroundColor(.orange)
                    }
                }
                infoButton(action: { print("ID verification info tapped") })
            }
            HStack(spacing: 8) {
                if let encryptionFingerprint = model.encryptionFingerprint {
                    Label {
                        Text("Encrypted (\(encryptionFingerprint))")
                    } icon: {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.stateBlue)
                    }
                } else {
                    Label {
                        Text("Not encrypted")
                    } icon: {
                        Image(systemName: "lock.slash")
                            .foregroundColor(.red)
                    }
                }
                infoButton(action: { print("Encryption info tapped") })
            }
        }
    }

    @ViewBuilder
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

public struct SecuritySectionModel: Equatable {
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

extension SecuritySectionModel {
    static var placeholder: Self {
        Self(
            isIdentityVerified: false,
            encryptionFingerprint: nil
        )
    }
}

struct ConversationInfoView_SecuritySection_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySection(model: .init(
            isIdentityVerified: true,
            encryptionFingerprint: "NW6DB"
        ))
        SecuritySection(model: .init(
            isIdentityVerified: false,
            encryptionFingerprint: nil
        ))
    }
}
