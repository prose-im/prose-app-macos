//
//  SidebarNavigationComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SwiftUI

struct SidebarNavigationComponent: View {
    var title: String
    var image: String
    var count: UInt16? = 0
    
    var body: some View {
        HStack {
            Label(title, systemImage: image)
            
            Spacer()
            
            SidebarCounterComponent(
                count: count
            )
        }
    }
}

struct SidebarNavigationComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarNavigationComponent(
            title: "Label",
            image: "trash"
        )
    }
}
