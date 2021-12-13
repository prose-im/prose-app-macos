//
//  SidebarCounterComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/30/21.
//

import SwiftUI

struct SidebarCounterComponent: View {
    var count: UInt16? = 0
    
    var body: some View {
        let countOrDefault = count ?? 0
        
        if countOrDefault > 0 {
            let cornerRadius: CGFloat = 10
            
            Text(String(countOrDefault))
                .font(.system(size: 11))
                .fontWeight(.semibold)
                .padding(.vertical, 2)
                .padding(.horizontal, 5)
                .foregroundColor(.secondary)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(lineWidth: 0)
                        .background(.quaternary)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

struct SidebarCounterComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarCounterComponent(
            count: 2
        )
    }
}
