//
//  SettingsFormFieldComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/11/21.
//

import SwiftUI

struct SettingsFormFieldComponent<Content: View>: View {
    var label: String
    let viewBuilder: () -> Content
    
    var body: some View {
        HStack {
            SettingsFormFieldLabelComponent(
                label: label
            )
            
            viewBuilder()
        }
    }
}

struct SettingsFormFieldComponent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFormFieldComponent(label: "Label") {
            Text("Content")
        }
    }
}
