//
//  ContentCommonToolbarActionsComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct ContentCommonToolbarActionsComponent: View {
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Button(action: {}) {
                    Image(systemName: "video")
                }
                Button(action: {}) {
                    Image(systemName: "info.circle")
                }
            }

            Divider()

            HStack(spacing: 0) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
}

struct ContentCommonToolbarActionsComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentCommonToolbarActionsComponent()
    }
}
