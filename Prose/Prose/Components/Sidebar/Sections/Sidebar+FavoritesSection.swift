//
//  Sidebar+FavoritesSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

extension SidebarView {
    
    struct FavoritesSection: View {
        
        @Binding var selection: SidebarID?
        
        let items: [SidebarOption] = [
            .init(
                id: .person(id: "id-valerian"),
                title: "Valerian",
                image: PreviewImages.Avatars.valerian.rawValue,
                count: 0
            ),
            .init(
                id: .person(id: "id-alexandre"),
                title: "Alexandre",
                image: PreviewImages.Avatars.alexandre.rawValue,
                count: 0
            ),
        ]
        
        var body: some View {
            Section("sidebar_section_favorites".localized()) {
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
            }
        }
        
    }
    
}

struct Sidebar_FavoritesSection_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            List {
                SidebarView.FavoritesSection(
                    selection: .constant(nil)
                )
            }
            .frame(width: 256)
        }
    }
    
}
