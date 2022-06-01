//
//  NavigationRow.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SwiftUI

struct NavigationRow: View {
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

            Counter(
                count: count
            )
        }
    }
}

struct NavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRow(
            title: "Label",
            image: "trash"
        )
    }
}
