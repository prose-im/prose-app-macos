//
//  ContentMessageDetailsIdentityComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct ContentMessageDetailsIdentityComponent: View {
    var avatar: String
    var name: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Image(avatar)
                .frame(width: 100.0, height: 100.0)
                .cornerRadius(10.0)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            
            Spacer()
            
            VStack(spacing: 4) {
                ContentCommonNameStatusComponent(
                    name: name,
                    status: .online
                )
                
                Text(verbatim: "CTO at Crisp")
                    .font(.system(size: 11.5))
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct ContentMessageDetailsIdentityComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsIdentityComponent(
            avatar: "avatar-valerian",
            name: "Valerian Saliou"
        )
    }
}
