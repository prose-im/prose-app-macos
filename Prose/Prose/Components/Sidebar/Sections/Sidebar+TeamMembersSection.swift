//
//  Sidebar+TeamMembersSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

extension SidebarView {
    
    struct TeamMembersSection: View {
        
        @Binding var selection: SidebarID?
        
        let items: [SidebarOption] = [
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
            Section("sidebar_section_team_members".localized()) {
                ForEach(items) { item in
                    NavigationLink(tag: item.id, selection: $selection) {
                        ContentView(selection: item.id)
                    } label: {
                        SidebarContactRow(
                            title: item.title,
                            avatar: item.image,
                            count: item.count
                        )
                    }
                }
                
                SidebarActionRow(
                    title: "sidebar_team_members_add",
                    systemImage: "plus.square.fill"
                ) {
                    // TODO: [Rémi Bardon] Add action
                    print("Add member tapped")
                }
            }
        }
        
    }
    
}

struct Sidebar_TeamMembersSection_Previews: PreviewProvider {
    
    static var previews: some View {
        List {
            SidebarView.TeamMembersSection(
                selection: .constant(nil)
            )
        }
    }
    
}
