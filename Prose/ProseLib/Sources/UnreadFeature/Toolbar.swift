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
        }
        ToolbarItemGroup {
            actions()
            ToolbarDivider()
            CommonToolbarActions()
        }
    }

    @ViewBuilder
    private func actions() -> some View {
        Button { print("Mark as read tapped") } label: {
            Label("Mark as read", systemImage: "envelope.open")
        }

        ToolbarDivider()

        Menu {
            // TODO: Add actions
            Text("TODO")
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
}
