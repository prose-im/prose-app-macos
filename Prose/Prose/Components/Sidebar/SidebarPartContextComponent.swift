//
//  SidebarPartContextComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarPartContextComponent: View {
    var avatar: String = "avatar-valerian"
    var teamName: String = "Crisp"
    var statusIcon: Character = "🚀"
    var statusMessage: String = "Building new features."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            
            HStack(alignment: .center, spacing: 12) {
                // User avatar
                SidebarContextAvatarComponent(
                    avatar: avatar
                )
                
                // Team name + user status
                HStack {
                    SidebarContextCurrentComponent(
                        teamName: teamName,
                        statusIcon: statusIcon,
                        statusMessage: statusMessage
                    )
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                // Quick action button
                SidebarContextActionsComponent()
            }
            .padding(.leading, 20.0)
            .padding(.trailing, 14.0)
            .padding([.top, .bottom], 14.0)
        }
    }
}

struct SidebarPartContextComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarPartContextComponent()
    }
}
