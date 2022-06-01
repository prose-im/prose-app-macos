//
//  ConversationDetails+SecuritySection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

extension ConversationDetailsView {
    struct SecuritySection: View {
        let entries: [ContentMessageDetailsEntryOption] = [
            .init(
                value: "content_message_details_security_identity_verified".localized(),
                image: .system("checkmark.seal.fill"),
                imageColor: .stateGreen,
                informationAction: true
            ),
            .init(
                value: "content_message_details_security_encrypted".localized() + " (C648A)",
                image: .system("lock.fill"),
                imageColor: .stateBlue,
                informationAction: true
            ),
        ]

        var body: some View {
            GroupBox("content_message_details_security_title".localized()) {
                EntriesView(entries: entries)
            }
        }
    }
}

struct ConversationDetailsView_SecuritySection_Previews: PreviewProvider {
    static var previews: some View {
        ConversationDetailsView.SecuritySection()
    }
}
