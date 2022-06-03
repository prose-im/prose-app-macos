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
    let entries: [ContentMessageDetailsEntryOption] = [
        .init(
            value: l10n.identityVerified,
            image: .system("checkmark.seal.fill"),
            imageColor: .stateGreen,
            informationAction: true
        ),
        .init(
            value: l10n.encrypted("C648A"),
            image: .system("lock.fill"),
            imageColor: .stateBlue,
            informationAction: true
        ),
    ]

    var body: some View {
        GroupBox(l10n.title) {
            EntriesView(entries: entries)
        }
    }
}

struct ConversationInfoView_SecuritySection_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySection()
    }
}
