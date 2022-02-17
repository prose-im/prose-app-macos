//
//  SidebarPartSectionsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarPartSectionsComponent: View {
    @State var selection: SidebarID?
    
    var body: some View {
        List(selection: $selection) {
            SidebarSectionSpotlightComponent(
                selection: selection
            )
            
            SidebarSectionFavoritesComponent(
                selection: selection
            )
            
            SidebarSectionTeamMembersComponent(
                selection: selection
            )
            
            SidebarSectionOtherContactsComponent(
                selection: selection
            )
            
            SidebarSectionGroupsComponent(
                selection: selection
            )
        }
    }
}

struct SidebarPartSectionsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarPartSectionsComponent()
    }
}
