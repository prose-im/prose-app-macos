//
//  EntryRowLabelStyle.swift
//  Prose
//
//  Created by Rémi Bardon on 03/06/2022.
//

import Assets
import SwiftUI

struct EntryRowLabelStyle: LabelStyle {
    static let iconFrameMinWidth: CGFloat = 16

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            configuration.icon
                .foregroundColor(Asset.Color.State.grey.swiftUIColor)
                .frame(width: Self.iconFrameMinWidth, alignment: .center)

            configuration.title
                .foregroundColor(Asset.Color.Text.primaryLight.swiftUIColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
