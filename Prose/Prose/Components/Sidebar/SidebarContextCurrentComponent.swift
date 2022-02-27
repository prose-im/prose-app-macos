//
//  SidebarContextCurrentComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarContextCurrentComponent: View {
    var teamName: String
    var statusIcon: Character
    var statusMessage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: teamName)
                .font(.system(size: 12).bold())
                .foregroundColor(.textPrimary)
            
            Text(verbatim: "\(statusIcon) “\(statusMessage)”")
                .font(.system(size: 11))
                .foregroundColor(.textSecondary)
                .layoutPriority(1)
        }
    }
}

struct SidebarContextCurrentComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContextCurrentComponent(
            teamName: "Crisp",
            statusIcon: "🚀",
            statusMessage: "Building new features."
        )
    }
}
