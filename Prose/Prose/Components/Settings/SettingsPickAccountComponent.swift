//
//  SettingsPickAccountComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct SettingsPickAccountComponent: View {
    var teamLogo: String
    var teamDomain: String
    var userName: String
    
    var body: some View {
        let logoSize: CGFloat = 26
        
        HStack(spacing: 6) {
            Image(teamLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: logoSize, height: logoSize)
                .cornerRadius(2)
                .clipped()
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: userName)
                    .font(.system(size: 11).bold())
                    .foregroundColor(.textPrimary)
                
                Text(verbatim: teamDomain)
                    .font(.system(size: 10.5))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

struct SettingsPickAccountComponent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPickAccountComponent(
            teamLogo: "logo-crisp",
            teamDomain: "crisp.chat",
            userName: "Baptiste"
        )
    }
}
