//
//  CommonToolbarNavigation.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

public struct CommonToolbarNavigation: View {
    @Environment(\.redactionReasons) private var redactionReasons

    public init() {}

    public var body: some View {
        Group {
            Button { logger.info("Navigation back tapped") } label: {
                Label("Back", systemImage: "chevron.backward")
            }
            Button { logger.info("Navigation forward tapped") } label: {
                Label("Forward", systemImage: "chevron.forward")
            }
            Menu {
                // TODO: Add actions
                Text("TODO")
            } label: {
                Label("History", systemImage: "clock")
            }
        }
        .unredacted()
        .disabled(redactionReasons.contains(.placeholder))
    }
}

// MARK: - Previews

struct CommonToolbarNavigation_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            HStack {
                CommonToolbarNavigation()
            }
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
