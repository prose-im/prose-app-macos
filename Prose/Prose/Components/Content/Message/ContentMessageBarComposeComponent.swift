//
//  ContentMessageBarComposeComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import SwiftUI

struct ContentMessageBarComposeComponent: View {
    @State var firstName: String
    
    var body: some View {
        Text("content_message_bar_compose_typing".localized(withFormat: firstName))
            .padding([.top, .bottom], 4.0)
            .padding([.leading, .trailing], 16.0)
            .font(Font.system(size: 10.5, weight: .light))
            .foregroundColor(.textSecondary)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.borderTertiary, lineWidth: 1)
                    .background(.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.025), radius: 3, x: 0, y: 1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ContentMessageBarComposeComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageBarComposeComponent(
            firstName: "Valerian"
        )
    }
}
