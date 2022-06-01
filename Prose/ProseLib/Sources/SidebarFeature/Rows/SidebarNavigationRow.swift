//
//  SidebarNavigationRow.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SwiftUI

struct SidebarNavigationRow: View {
    private let title: String
    private let image: String
    private let count: UInt16?

    init(
        title: String,
        image: String,
        count: UInt16? = 0
    ) {
        self.title = title
        self.image = image
        self.count = count
    }

    var body: some View {
        HStack {
            Label(title, systemImage: image)

            Spacer()

            SidebarCounter(
                count: count
            )
        }
    }
}

struct SidebarNavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        SidebarNavigationRow(
            title: "Label",
            image: "trash"
        )
    }
}
