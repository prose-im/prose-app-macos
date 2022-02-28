//
//  Sidebar+Content.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

extension SidebarView {
    
    struct Content: View {
        
        @Binding var selection: SidebarID?
        
        var body: some View {
            List {
                SpotlightSection(selection: $selection)
                FavoritesSection(selection: $selection)
                TeamMembersSection(selection: $selection)
                OtherContactsSection(selection: $selection)
                GroupsSection(selection: $selection)
            }
        }
        
    }
    
}

struct Sidebar_Content_Previews: PreviewProvider {
    
    private struct Preview: View {
        
        @State private var selection: SidebarID?
        
        var body: some View {
            SidebarView.Content(selection: $selection)
        }
        
    }
    
    static var previews: some View {
        Preview()
    }
    
}
