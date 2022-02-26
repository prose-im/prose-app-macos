//
//  SidebarSectionGroupsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionGroupsComponent: View {
    @Binding var selection: SidebarID?
    
    let groupsOptions: [SidebarOption] = [
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
        Section(header: Text("sidebar_section_groups".localized())) {
            ForEach(groupsOptions) { option in
                NavigationLink(tag: option.id, selection: $selection) {
                    ContentView()
                } label: {
                    SidebarNavigationComponent(
                        title: option.title,
                        image: option.image,
                        count: option.count
                    )
                }
            }
            
            SidebarActionComponent(
                title: "sidebar_groups_add",
                systemImage: "plus.square.fill"
            ) {
                // TODO: [Rémi Bardon] Add action
                print("Add group tapped")
            }
        }
    }
}

struct SidebarSectionGroupsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionGroupsComponent(
            selection: .constant(nil)
        )
    }
}
