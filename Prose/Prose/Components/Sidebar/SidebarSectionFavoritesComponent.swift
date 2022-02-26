//
//  SidebarSectionFavoritesComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionFavoritesComponent: View {
    @Binding var selection: SidebarID?
    
    let favoritesOptions: [SidebarOption] = [
        .init(
            id: .person(id: "id-valerian"),
            title: "Valerian",
            image: "avatar-valerian",
            count: 0
        ),
        .init(
            id: .person(id: "id-julian"),
            title: "Julian",
            image: "avatar-valerian",
            count: 0
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_favorites".localized())) {
            ForEach(favoritesOptions) { option in
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
        }
    }
}

struct SidebarSectionFavoritesComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionFavoritesComponent(
            selection: .constant(nil)
        )
    }
}
