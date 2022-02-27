//
//  SidebarSectionTeamMembersComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionTeamMembersComponent: View {
    @Binding var selection: SidebarID?
    
    let teamMembersOptions: [SidebarOption] = [
        .init(
            id: .person(id: "id-elison"),
            title: "Elison",
            image: "avatar-valerian",
            count: 0
        ),
        .init(
            id: .person(id: "id-elisa"),
            title: "Elisa",
            image: "avatar-valerian",
            count: 3
        ),
        .init(
            id: .person(id: "id-david"),
            title: "David",
            image: "avatar-valerian",
            count: 2
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_team_members".localized())) {
            ForEach(teamMembersOptions) { option in
                NavigationLink(tag: option.id, selection: $selection) {
                    ContentView(selection: option.id)
                } label: {
                    SidebarContactComponent(
                        title: option.title,
                        avatar: option.image,
                        count: option.count
                    )
                }
            }
            
            SidebarActionComponent(
                title: "sidebar_team_members_add",
                systemImage: "plus.square.fill"
            ) {
                // TODO: [Rémi Bardon] Add action
                print("Add member tapped")
            }
        }
    }
}

struct SidebarSectionTeamMembersComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionTeamMembersComponent(
            selection: .constant(nil)
        )
    }
}
