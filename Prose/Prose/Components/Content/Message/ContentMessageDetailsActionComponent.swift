//
//  ContentMessageDetailsActionComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import SwiftUI

struct ContentMessageDetailsActionOption: Hashable {
    let name: String
    var deployTo: Bool = false
}

struct ContentMessageDetailsActionComponent: View {
    let paddingSides: CGFloat
    var action: ContentMessageDetailsActionOption
    
    var body: some View {
        HStack(spacing: 6) {
            Text(verbatim: action.name)
                .font(.system(size: 12))
                .fontWeight(.medium)
                .foregroundColor(.textPrimaryLight)
            
            Spacer()
            
            if action.deployTo {
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.textPrimary)
            }
        }
            .padding([.leading, .trailing], paddingSides)
            .padding([.top, .bottom], 4.0)
    }
}

struct ContentMessageDetailsActionComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsActionComponent(
            paddingSides: 15,
            action: .init(
                name: "View full profile",
                deployTo: true
            )
        )
    }
}
