//
//  SidebarSectionTeamMembersComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionTeamMembersComponent: View {
    @State var selection: SidebarID?
    
    let teamMembersAtomOptions: [SidebarOption] = [
        .init(
            id: .teamMembersAtom("id-xx"),
            title: "Antoine",
            image: "avatar-valerian",
            count: 0
        ),
        .init(
            id: .teamMembersAtom("id-xx"),
            title: "Eliott",
            image: "avatar-valerian",
            count: 3
        ),
        .init(
            id: .teamMembersAtom("id-xx"),
            title: "Camille",
            image: "avatar-valerian",
            count: 2
        ),
    ]
    
    let teamMembersActionOptions: [SidebarOption] = [
        .init(
            id: .teamMembersAdd,
            title: "sidebar_team_members_add".localized(),
            image: "plus.square.fill",
            count: 0
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_team_members".localized())) {
            ForEach(teamMembersAtomOptions, id: \.self) { option in
                NavigationLink(
                    destination: ContentView(), tag: option.id, selection: $selection
                ) {
                    SidebarContactComponent(
                        title: option.title,
                        avatar: option.image,
                        count: option.count
                    )
                }
                .tag(option.id)
            }
            
            ForEach(teamMembersActionOptions, id: \.self) { option in
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

struct SidebarSectionTeamMembersComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionTeamMembersComponent()
    }
}
