//
//  CommonButtonActionComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import SwiftUI

struct CommonButtonActionComponent: View {
    var icon: String
    var label: String
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(Color.buttonActionGradientFromText)
                        .frame(width: 24, height: 24)
                        .shadow(color: .buttonActionShadow.opacity(0.14), radius: 1, x: 0, y: 1)
                    
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white)
                }
                
                Text(verbatim: label)
                    .font(.system(size: 9.5))
                    .foregroundColor(.buttonActionText)
            }
        }
            .buttonStyle(PlainButtonStyle())
    }
}

struct CommonButtonActionComponent_Previews: PreviewProvider {
    static var previews: some View {
        CommonButtonActionComponent(
            icon: "phone.fill",
            label: "phone"
        )
    }
}
