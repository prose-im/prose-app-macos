//
//  SidebarSectionGroupsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionGroupsComponent: View {
    @State var selection: SidebarID?
    
    let groupsOptions: [SidebarOption] = [
        .init(
            id: .groupsAtom,
            title: "bugs",
            image: "circle.grid.2x2",
            count: 0
        ),
        .init(
            id: .groupsAtom,
            title: "constellation",
            image: "circle.grid.2x2",
            count: 7
        ),
        .init(
            id: .groupsAtom,
            title: "general",
            image: "circle.grid.2x2",
            count: 0
        ),
        .init(
            id: .groupsAtom,
            title: "support",
            image: "circle.grid.2x2",
            count: 0
        ),
        .init(
            id: .groupsAdd,
            title: "sidebar_groups_add".localized(),
            image: "plus.square.fill",
            count: 0
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_groups".localized())) {
            ForEach(groupsOptions, id: \.self) { option in
                NavigationLink(
                    destination: ContentView(), tag: option.id, selection: $selection
                ) {
                    SidebarNavigationComponent(
                        title: option.title,
                        image: option.image,
                        count: option.count
                    )
                }
                .tag(option.id)
            }
        }
    }
}

struct SidebarSectionGroupsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionGroupsComponent()
    }
}
