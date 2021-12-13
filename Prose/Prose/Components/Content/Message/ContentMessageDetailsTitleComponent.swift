//
//  ContentMessageDetailsTitleComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import SwiftUI

struct ContentMessageDetailsTitleComponent: View {
    var title: String
    var paddingSides: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: title)
                .font(.system(size: 11))
                .fontWeight(.semibold)
                .foregroundColor(Color.black.opacity(0.25))
                .padding(.horizontal, paddingSides)
            
            Divider()
        }
    }
}

struct ContentMessageDetailsTitleComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsTitleComponent(
            title: "Title",
            paddingSides: 15
        )
    }
}
