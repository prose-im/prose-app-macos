//
//  SidebarSectionOtherContactsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionOtherContactsComponent: View {
    @Binding var selection: SidebarID?
    
    let otherContactsOptions: [SidebarOption] = [
        .init(
            id: .person(id: "id-james"),
            title: "James",
            image: "avatar-valerian",
            count: 0
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_other_contacts".localized())) {
            ForEach(otherContactsOptions) { option in
                NavigationLink(tag: option.id, selection: $selection) {
                    ContentView()
                } label: {
                    SidebarContactComponent(
                        title: option.title,
                        avatar: option.image,
                        count: option.count
                    )
                }
            }
            
            SidebarActionComponent(
                title: "sidebar_other_contacts_add",
                systemImage: "plus.square.fill"
            ) {
                // TODO: [Rémi Bardon] Add action
                print("Add contact tapped")
            }
        }
    }
}

struct SidebarSectionOtherContactsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionOtherContactsComponent(
            selection: .constant(nil)
        )
    }
}
