//
//  CommonToolbarActions.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

public struct CommonToolbarActions: View {
    @Environment(\.redactionReasons) private var redactionReasons

    public init() {}

    public var body: some View {
        Button { print("Search tapped") } label: {
            Label("Search", systemImage: "magnifyingglass")
        }
        .unredacted()
        .disabled(redactionReasons.contains(.placeholder))
    }
}

// MARK: - Previews

struct CommonToolbarActions_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            CommonToolbarActions()
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }

    static var previews: some View {
        Preview()
        Preview()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark mode")
        Preview()
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
