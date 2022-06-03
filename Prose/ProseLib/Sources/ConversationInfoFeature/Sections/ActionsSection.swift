//
//  Info+ActionsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Actions.self

struct ActionsSection: View {
    let actions: [ContentMessageDetailsActionOption] = [
        .init(name: l10n.sharedFiles, deployTo: true),
        .init(name: l10n.encryptionSettings, deployTo: true),
        .init(name: l10n.removeContact),
        .init(name: l10n.block),
    ]

    var body: some View {
        GroupBox(l10n.title) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(actions, id: \.self, content: ActionRow.init(action:))
                    .unredacted()
            }
        }
    }
}

struct ConversationInfoView_ActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        ActionsSection()
    }
}
