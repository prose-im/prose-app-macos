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
    private let imageSource: ImageSource
    private let count: UInt16?

    init(
        title: String,
        image: ImageSource,
        count: UInt16? = 0
    ) {
        self.title = title
        self.imageSource = image
        self.count = count
    }

    var body: some View {
        HStack {
            Label { Text(title) } icon: { imageSource.image }
                .frame(maxWidth: .infinity, alignment: .leading)
            Counter(count: count)
        }
    }
}

struct NavigationRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationRow(
            title: "Label",
            image: .symbol("trash")
        )
    }
}
