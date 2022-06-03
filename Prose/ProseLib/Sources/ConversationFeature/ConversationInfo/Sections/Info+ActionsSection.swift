//
//  Info+ActionsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

extension ConversationInfoView {
    struct ActionsSection: View {
        let actions: [ContentMessageDetailsActionOption] = [
            .init(
                name: "content_message_details_actions_shared_files".localized(),
                deployTo: true
            ),
            .init(
                name: "content_message_details_actions_encryption_settings".localized(),
                deployTo: true
            ),
            .init(
                name: "content_message_details_actions_remove_contact".localized()
            ),
            .init(
                name: "content_message_details_actions_block".localized()
            ),
        ]

        var body: some View {
            GroupBox("content_message_details_actions_title".localized()) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(actions, id: \.self, content: ActionRow.init(action:))
                        .unredacted()
                }
            }
        }
    }
}

struct ConversationInfoView_ActionsSection_Previews: PreviewProvider {
    static var previews: some View {
        ConversationInfoView.ActionsSection()
    }
}
