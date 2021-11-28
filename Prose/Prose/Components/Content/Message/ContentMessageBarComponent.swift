//
//  ContentMessageBarComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/21/21.
//

import SwiftUI

struct ContentMessageBarComponent: View {
    @State private var message: String = ""
    
    var firstName: String
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "textformat.alt")
                    }
                    
                    Spacer()
                    
                    ZStack {
                        ContentMessageBarComposeComponent(
                            firstName: firstName
                        )
                            .offset(x: 0, y: -32)
                            .zIndex(1.0)
                        
                        ContentMessageBarFieldComponent(
                            firstName: firstName,
                            message: message
                        )
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "paperclip")
                        Image(systemName: "face.smiling")
                    }
                    
                    Spacer()
                }
                .font(.title2)
            }
            .padding()
        }
        .foregroundColor(.secondary)
    }
}

struct ContentMessageBarComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageBarComponent(
            firstName: "Valerian"
        )
    }
}
