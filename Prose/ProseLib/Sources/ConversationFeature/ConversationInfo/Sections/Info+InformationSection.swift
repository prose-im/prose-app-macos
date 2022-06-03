//
//  Info+InformationSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import Assets
import SwiftUI

extension ConversationInfoView {
    struct InformationSection: View {
        let entries: [ContentMessageDetailsEntryOption] = [
            .init(
                value: "valerian@crisp.chat",
                image: .system("envelope.fill")
            ),
            .init(
                value: "+33631210280",
                image: .system("iphone")
            ),
            .init(
                value: "Active 1 min ago",
                image: .system("hand.wave.fill")
            ),
            .init(
                value: "5:03pm (UTC+1)",
                image: .system("clock.fill")
            ),
            .init(
                value: "Lisbon, Portugal",
                image: .system("location.fill")
            ),
            .init(
                value: "Focusing on code",
                image: .literal("👨‍💻"),
                valueColor: .textSecondaryLight
            ),
        ]

        var body: some View {
            GroupBox("content_message_details_information_title".localized()) {
                EntriesView(entries: entries)
            }
        }
    }
}

struct ConversationInfoView_InformationSection_Previews: PreviewProvider {
    static var previews: some View {
        ConversationInfoView.InformationSection()
    }
}
