//
//  ContentCommonToolbarNavigationComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct ContentCommonToolbarNavigationComponent: View {
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.backward")
            }
            Button(action: {}) {
                Image(systemName: "chevron.forward")
            }
            
            Menu {
                // TODO
            } label: {
                Image(systemName: "clock")
            }
        }
    }
}

struct ContentCommonToolbarNavigationComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentCommonToolbarNavigationComponent()
    }
}
