//
//  SectionGroupStyle.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import SwiftUI

struct SectionGroupStyle: GroupBoxStyle {
    private static let sidesPadding: CGFloat = 15

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                configuration.label
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.primary.opacity(0.25))
                    .padding(.horizontal, Self.sidesPadding)
                    .unredacted()

                Divider()
            }

            configuration.content
                .padding(.horizontal, Self.sidesPadding)
        }
    }
}
