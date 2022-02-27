//
//  SidebarContextAvatarComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarContextAvatarComponent: View {
    var avatar: String
    var status: OnlineStatus = .offline
    var size: CGFloat = 34
    
    var body: some View {
        ZStack {
            let statusOffset: CGFloat = size / 2
            let statusBorderSize: CGFloat = 2
            let statusWithBorderSize: CGFloat = 8 + 2 * statusBorderSize
            
            ZStack {
                OnlineStatusIndicator(
                    status: status
                )
                    .zIndex(2)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: statusWithBorderSize, height: statusWithBorderSize)
                    .zIndex(1)
            }
                .offset(x: statusOffset - 1, y: statusOffset - 3)
                .zIndex(2)
            
            Image(avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .cornerRadius(4.0)
                .clipped()
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                .zIndex(1)
        }
    }
}

struct SidebarContextAvatarComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContextAvatarComponent(
            avatar: "avatar-valerian",
            status: .online
        )
    }
}
