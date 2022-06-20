//
//  NavigationRow.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SharedModels
import SwiftUI

struct NavigationRow: View {
    private let title: String
    private let systemImage: String
    private let count: UInt16?

    init(
        title: String,
        systemImage: String,
        count: UInt16? = 0
    ) {
        self.title = title
        self.systemImage = systemImage
        self.count = count
    }

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
            Counter(count: count)
        }
    }
}

struct NavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRow(
            title: "Label",
            systemImage: "trash"
        )
    }
}
