//
//  ContentCommonNameStatusComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import SwiftUI

struct ContentCommonNameStatusComponent: View {
    var name: String
    var status: Status = .offline
    
    var body: some View {
        HStack {
            CommonStatusComponent(
                status: status
            )
                .offset(x: 3, y: 1)
            
            Text(verbatim: name)
                .font(.system(size: 14).bold())
        }
    }
}

struct ContentCommonNameStatusComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentCommonNameStatusComponent(
            name: "Valerian Saliou",
            status: .online
        )
    }
}
