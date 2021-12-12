//
//  SidebarSectionFavoritesComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionFavoritesComponent: View {
    @State var selection: SidebarID?
    
    let favoritesOptions: [SidebarOption] = [
        .init(
            id: .favoritesAtom("id-xx"),
            title: "Valerian",
            image: "avatar-valerian",
            count: 0
        ),
        .init(
            id: .favoritesAtom("id-xx"),
            title: "Julian",
            image: "avatar-valerian",
            count: 0
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_favorites".localized())) {
            ForEach(favoritesOptions, id: \.self) { option in
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
        }
    }
}

struct SidebarSectionFavoritesComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionFavoritesComponent()
    }
}
