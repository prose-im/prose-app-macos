//
//  SidebarContextAvatarComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarContextAvatarComponent: View {
    var avatar: String
    
    var body: some View {
        Image(avatar)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 34.0, height: 34.0)
            .cornerRadius(4.0)
            .clipped()
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

struct SidebarContextAvatarComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContextAvatarComponent(
            avatar: "avatar-valerian"
        )
    }
}
