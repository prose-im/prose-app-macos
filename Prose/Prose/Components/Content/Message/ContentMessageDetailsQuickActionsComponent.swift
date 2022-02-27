//
//  ContentMessageDetailsQuickActionsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct ContentMessageDetailsQuickActionsComponent: View {
    var body: some View {
        HStack(spacing: 24) {
            Button {
                // TODO: Handle action
                print("Phone tapped")
            } label: {
                Label("phone", systemImage: "phone")
            }
            Button {
                // TODO: Handle action
                print("Phone tapped")
            } label: {
                Label("email", systemImage: "envelope")
            }
        }
        .buttonStyle(SubtitledActionButtonStyle())
    }
}

struct ContentMessageDetailsQuickActionsComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsQuickActionsComponent()
    }
}
