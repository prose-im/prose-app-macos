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
        Button { print("Add contact tapped") } label: {
            Label("Add contact", systemImage: "person.crop.circle.badge.plus")
        }
        Button { print("Stack plus tapped") } label: {
            Label("Add group", systemImage: "rectangle.stack.badge.plus")
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
