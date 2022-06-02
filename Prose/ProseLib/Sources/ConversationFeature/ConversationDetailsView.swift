//
//  ConversationDetailsView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import PreviewAssets
import SwiftUI

struct ConversationDetailsView: View {
    struct SectionGroupStyle: GroupBoxStyle {
        private static let sidesPadding: CGFloat = 15

        func makeBody(configuration: Configuration) -> some View {
            VStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    configuration.label
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.primary.opacity(0.25))
                        .padding(.horizontal, Self.sidesPadding)

                    Divider()
                }

                configuration.content
                    .padding(.horizontal, Self.sidesPadding)
            }
        }
    }

    var avatar: String
    var name: String

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    IdentitySection(
                        avatar: avatar,
                        name: name
                    )
                    QuickActionsSection()
                }
                .padding(.horizontal)

                InformationSection()
                SecuritySection()
                ActionsSection()
            }
            .padding(.vertical)
        }
        .groupBoxStyle(SectionGroupStyle())
        .background(.background)
    }
}

struct ConversationDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationDetailsView(
            avatar: PreviewImages.Avatars.valerian.rawValue,
            name: "Valerian Saliou"
        )
        .frame(width: 220.0, height: 720, alignment: .top)
    }
}
