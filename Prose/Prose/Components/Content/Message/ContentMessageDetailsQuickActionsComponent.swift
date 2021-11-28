//
//  ContentMessageDetailsQuickActionsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct ContentMessageDetailsQuickActionsComponent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 26) {
                CommonButtonActionComponent(
                    icon: "phone.fill",
                    label: "phone"
                )
                
                CommonButtonActionComponent(
                    icon: "envelope.fill",
                    label: "email"
                )
            }
        }
    }
}

struct ContentMessageDetailsQuickActionsComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsQuickActionsComponent()
    }
}
