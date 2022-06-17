//
//  AddressBookScreen.swift
//  Prose
//
//  Created by Rémi Bardon on 02/06/2022.
//

import SwiftUI

public struct AddressBookScreen: View {
    public init() {}

    public var body: some View {
        Text("Address book")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .unredacted()
            .toolbar(content: Toolbar.init)
    }
}

internal struct AddressBookScreen_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            NavigationView {
                Text("Test")
                AddressBookScreen()
            }
        }
    }

    static var previews: some View {
        Preview()
        Preview()
            .redacted(reason: .placeholder)
            .previewDisplayName("Placeholder")
    }
}
