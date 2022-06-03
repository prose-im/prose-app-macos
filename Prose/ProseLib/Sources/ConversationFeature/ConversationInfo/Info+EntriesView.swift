//
//  ConversationInfo+EntriesView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import SwiftUI

extension ConversationInfoView {
    struct EntriesView: View {
        var entries: [ContentMessageDetailsEntryOption]

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(entries, id: \.self) { entry in
                    ConversationInfoView.EntryRow(
                        entry: entry
                    )
                }
            }
        }
    }
}

struct ConversationInfoView_EntriesView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationInfoView.EntriesView(
            entries: [
                .init(
                    value: "Email address",
                    image: .system("envelope.fill")
                ),
                .init(
                    value: "Phone number",
                    image: .system("iphone")
                ),
            ]
        )
    }
}
