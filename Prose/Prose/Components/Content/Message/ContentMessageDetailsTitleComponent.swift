//
//  ContentMessageDetailsTitleComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import SwiftUI

struct ContentMessageDetailsTitleComponent<Label: View>: View {
    var label: Label
    var sidesPadding: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            label
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.primary.opacity(0.25))
                .padding(.horizontal, sidesPadding)
            
            Divider()
        }
    }
}

struct ContentMessageDetailsTitleComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsTitleComponent(
            label: Text("Title"),
            sidesPadding: 15
        )
    }
}
