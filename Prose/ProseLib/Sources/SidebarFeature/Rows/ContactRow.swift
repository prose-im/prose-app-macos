//
//  ContactRow.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import PreviewAssets
import ProseUI
import SharedModels
import SwiftUI

struct ContactRow: View {
    var title: String
    var avatar: AvatarImage
    var count = 0

    var body: some View {
        HStack {
            Avatar(avatar, size: 18)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(title)

                OnlineStatusIndicator(status: .offline)
            }

            Spacer()

            Counter(count: count)
        }
    }
}

struct ContactRow_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            ContactRow(
                title: "Valerian",
                avatar: AvatarImage(url: PreviewAsset.Avatars.valerian.customURL),
                count: 3
            )
            .frame(width: 196)
            .padding()
        }
    }

    static var previews: some View {
        Preview()
            .preferredColorScheme(.light)
            .previewDisplayName("Light")

        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
    }
}
