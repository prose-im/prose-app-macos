//
//  SidebarSectionOtherContactsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionOtherContactsComponent: View {
    @State var selection: SidebarID?
    
    let otherContactsAtomOptions: [SidebarOption] = [
        .init(
            id: .otherContactsAtom("id-xx"),
            title: "James",
            image: "avatar-valerian",
            count: 0
        ),
    ]
    
    let otherContactsActionOptions: [SidebarOption] = [
        .init(
            id: .otherContactsAdd,
            title: "sidebar_other_contacts_add".localized(),
            image: "plus.square.fill",
            count: 0
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_other_contacts".localized())) {
            ForEach(otherContactsAtomOptions, id: \.self) { option in
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
            
            ForEach(otherContactsActionOptions, id: \.self) { option in
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

struct SidebarSectionOtherContactsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionOtherContactsComponent()
    }
}
