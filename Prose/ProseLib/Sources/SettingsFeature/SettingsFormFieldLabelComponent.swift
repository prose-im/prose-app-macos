//
//  SettingsFormFieldLabelComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/11/21.
//

import SwiftUI

struct SettingsFormFieldLabelComponent: View {
    var label: String
    
    var body: some View {
        Text(label)
            .padding(.trailing, 2.0)
            .frame(minWidth: 90, alignment: .trailing)
    }
}

struct SettingsFormFieldLabelComponent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsFormFieldLabelComponent(
            label: "Label"
        )
    }
}
