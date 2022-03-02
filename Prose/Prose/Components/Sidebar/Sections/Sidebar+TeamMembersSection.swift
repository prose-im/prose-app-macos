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
                id: .person(id: "id-antoine"),
                title: "Antoine",
                image: PreviewImages.Avatars.antoine.rawValue,
                count: 0
            ),
            .init(
                id: .person(id: "id-eliott"),
                title: "Eliott",
                image: PreviewImages.Avatars.eliott.rawValue,
                count: 3
            ),
            .init(
                id: .person(id: "id-camille"),
                title: "Camille",
                image: PreviewImages.Avatars.camille.rawValue,
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
        NavigationView {
            List {
                SidebarView.TeamMembersSection(
                    selection: .constant(nil)
                )
            }
            .frame(width: 256)
        }
    }
    
}
