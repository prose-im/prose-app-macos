//
//  ActionsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Actions.self

struct ActionsSection: View {
    var body: some View {
        GroupBox(l10n.title) {
            ActionRow(
                name: l10n.sharedFiles,
                deployTo: true,
                action: { print("View shared files tapped") }
            )
            ActionRow(
                name: l10n.encryptionSettings,
                deployTo: true,
                action: { print("Encryption settings tapped") }
            )
            // TODO: [Rémi Bardon] We should make this red, as it's a destructive action (using the `role` parameter of `Button`)
            ActionRow(
                name: l10n.removeContact,
                action: { print("Remove contact tapped") }
            )
            // TODO: [Rémi Bardon] We should make this red, as it's a destructive action (using the `role` parameter of `Button`)
            ActionRow(
                name: l10n.block,
                action: { print("Block tapped") }
            )
        }
        .unredacted()
    }
}

struct ActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        ActionsSection()
    }
}
