//
//  ToolbarTitle.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import ProseUI
import SharedModels
import SwiftUI

/// Separated as its own view as we might need to reuse it someday.
struct ToolbarTitle: View {
    let name: String
    let status: OnlineStatus

    init(name: String, status: OnlineStatus = .offline) {
        self.name = name
        self.status = status
    }

    var body: some View {
        ContentCommonNameStatusComponent(
            name: name,
            status: status
        )
        .padding(.horizontal, 8)
    }
}

struct ToolbarTitle_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarTitle(
            name: "Valerian Saliou",
            status: .online
        )
    }
}
