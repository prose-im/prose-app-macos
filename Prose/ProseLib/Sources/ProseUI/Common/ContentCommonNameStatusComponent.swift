//
//  ContentCommonNameStatusComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import SharedModels
import SwiftUI

public struct ContentCommonNameStatusComponent: View {
    var name: String
    var status: OnlineStatus = .offline

    public init(name: String, status: OnlineStatus = .offline) {
        self.name = name
        self.status = status
    }

    public var body: some View {
        HStack {
            OnlineStatusIndicator(
                status: status
            )
            .offset(x: 3, y: 1)
            .accessibilitySortPriority(1)

            Text(verbatim: name)
                .font(.system(size: 14).bold())
                .accessibilitySortPriority(2)
        }
        .accessibilityElement(children: .combine)
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
