//
//  Toolbar.swift
//  Prose
//
//  Created by Rémi Bardon on 02/06/2022.
//

import ProseUI
import SwiftUI

struct Toolbar: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            CommonToolbarNavigation()

            ToolbarDivider()

            ToolbarTitle(
                name: "Valerian Saliou",
                status: .online
            )
        }

        ToolbarItemGroup {
            ToolbarSecurity()

            ToolbarDivider()

            actions()

            ToolbarDivider()

            CommonToolbarActions()
        }
    }

    @ViewBuilder
    private func actions() -> some View {
        Button { print("Video tapped") } label: {
            Label("Video", systemImage: "video")
        }

        Button { print("Info tapped") } label: {
            Label("Info", systemImage: "info.circle")
        }
    }
}
