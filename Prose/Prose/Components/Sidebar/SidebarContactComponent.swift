//
//  SidebarContactComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarContactComponent: View {
    var title: String
    var avatar: String
    var count: UInt16? = 0
    
    var body: some View {
        HStack {
            let countOrDefault = count ?? 0
            
            Image(avatar)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 18.0, height: 18.0)
                .cornerRadius(2.0)
                .clipped()
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
            
            Text(title)
                .offset(x: -2, y: 0)
            
            CommonStatusComponent(
                status: .offline
            )
                .offset(x: -3, y: 1)
            
            Spacer()
            
            if countOrDefault > 0 {
                Text(String(countOrDefault))
                    .foregroundColor(Color.gray)
            }
        }
    }
}

struct SidebarContactComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContactComponent(
            title: "Valerian",
            avatar: "avatar-valerian"
        )
    }
}
