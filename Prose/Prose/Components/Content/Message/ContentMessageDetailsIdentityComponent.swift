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
        VStack(alignment: .center, spacing: 10) {
            Image(avatar)
                .frame(width: 100.0, height: 100.0)
                .cornerRadius(10.0)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            
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
            avatar: PreviewImages.Avatars.valerian.rawValue,
            name: "Valerian Saliou"
        )
    }
}
