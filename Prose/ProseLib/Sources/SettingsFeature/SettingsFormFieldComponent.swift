//
//  SettingsFormFieldComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/11/21.
//

import SwiftUI

struct SettingsFormFieldComponent<Content: View>: View {
    var label: String
    let content: () -> Content

    var body: some View {
        HStack {
            SettingsFormFieldLabelComponent(
                label: label
            )

            content()
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
