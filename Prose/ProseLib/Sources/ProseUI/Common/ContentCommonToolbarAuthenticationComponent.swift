//
//  ContentCommonToolbarAuthenticationComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct ContentCommonToolbarAuthenticationComponent: View {
    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .renderingMode(.template)
                .foregroundColor(.stateGreen)
                .offset(x: 5, y: 0)

            Text(verbatim: "valerian@crisp.chat").foregroundColor(.textSecondary)
        }
    }
}

struct ContentCommonToolbarAuthenticationComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentCommonToolbarAuthenticationComponent()
    }
}
