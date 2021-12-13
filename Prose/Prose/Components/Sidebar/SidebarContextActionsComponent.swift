//
//  SidebarContextActionsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarContextActionsComponent: View {
    var body: some View {
        Button(action: {}) {
            ZStack {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .rotationEffect(.degrees(90))
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.black.opacity(0.05))
                    .frame(width: 24, height: 32)
            }
        }
            .buttonStyle(PlainButtonStyle())
    }
}

struct SidebarContextActionsComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContextActionsComponent()
    }
}
