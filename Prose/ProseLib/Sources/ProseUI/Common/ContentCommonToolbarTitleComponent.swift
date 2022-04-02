//
//  ContentCommonToolbarTitleComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct ContentCommonToolbarTitleComponent: View {
    var body: some View {
        HStack {
            ContentCommonNameStatusComponent(
                name: "Valerian Saliou",
                status: .online
            )
        }
    }
}

struct ContentCommonToolbarTitleComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentCommonToolbarTitleComponent()
    }
}
