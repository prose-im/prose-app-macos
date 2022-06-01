//
//  FooterAvatar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import AppLocalization
import PreviewAssets
import ProseUI
import SharedModels
import SwiftUI

private let l10n = L10n.Sidebar.Footer.Actions.Account.self

/// User avatar in the left sidebar footer
struct FooterAvatar: View {
    private let avatar: String
    private let status: OnlineStatus
    private let size: CGFloat

    init(
        avatar: String,
        status: OnlineStatus = .offline,
        size: CGFloat = 32
    ) {
        self.avatar = avatar
        self.status = status
        self.size = size
    }

    var body: some View {
        Button(action: {}) {
            Avatar(avatar, size: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(l10n.label)
        .overlay(alignment: .bottomTrailing) {
            statusIndicator()
                // Offset of half the size minus 2 points (otherwise it looks odd)
                .alignmentGuide(.trailing) { d in d.width / 2 + 2 }
                .alignmentGuide(.bottom) { d in d.height / 2 + 2 }
        }
    }

    @ViewBuilder
    private func statusIndicator() -> some View {
        if self.status != .offline {
            OnlineStatusIndicator(status: self.status)
                .padding(2)
                .background {
                    Circle()
                        .fill(Color.white)
                }
        }
    }
}

struct FooterAvatar_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            HStack {
                ForEach(OnlineStatus.allCases, id: \.self) { status in
                    FooterAvatar(
                        avatar: PreviewImages.Avatars.valerian.rawValue,
                        status: status
                    )
                }
            }
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
