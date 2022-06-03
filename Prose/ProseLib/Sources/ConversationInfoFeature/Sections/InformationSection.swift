//
//  Info+InformationSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import AppLocalization
import Assets
import SwiftUI

private let l10n = L10n.Content.MessageDetails.Information.self

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
        GroupBox(l10n.title) {
            EntriesView(entries: entries)
        }
    }
}

struct ConversationInfoView_InformationSection_Previews: PreviewProvider {
    static var previews: some View {
        InformationSection()
    }
}
