//
//  SettingsPickActionComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct SettingsPickActionComponent: View {
    var actionName: String

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {}) {
                Image(systemName: actionName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .frame(width: 26, alignment: .center)

            Divider()
                .padding(.vertical, 3.0)
        }
    }
}

struct SettingsPickActionComponent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPickActionComponent(
            actionName: "plus"
        )
    }
}
