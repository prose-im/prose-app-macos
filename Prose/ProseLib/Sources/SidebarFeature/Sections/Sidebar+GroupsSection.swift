//
//  Sidebar+GroupsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

extension SidebarView {
    struct GroupsSection: View {
        @Binding var selection: SidebarID?

        let items: [SidebarOption] = [
            .init(
                id: .group(id: "group-bugs"),
                title: "bugs",
                image: "circle.grid.2x2",
                count: 0
            ),
            .init(
                id: .group(id: "group-constellation"),
                title: "constellation",
                image: "circle.grid.2x2",
                count: 7
            ),
            .init(
                id: .group(id: "group-general"),
                title: "general",
                image: "circle.grid.2x2",
                count: 0
            ),
            .init(
                id: .group(id: "group-support"),
                title: "support",
                image: "circle.grid.2x2",
                count: 0
            ),
        ]

        var body: some View {
            Section("sidebar_section_groups".localized()) {
                ForEach(items) { item in
                    NavigationLink(tag: item.id, selection: $selection) {
                        ContentView(selection: item.id)
                    } label: {
                        SidebarNavigationRow(
                            title: item.title,
                            image: item.image,
                            count: item.count
                        )
                    }
                }

                SidebarActionRow(
                    title: "sidebar_groups_add",
                    systemImage: "plus.square.fill"
                ) {
                    // TODO: [Rémi Bardon] Add action
                    print("Add group tapped")
                }
            }
        }
    }
}

struct Sidebar_GroupsSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SidebarView.GroupsSection(
                selection: .constant(nil)
            )
        }
    }
}
