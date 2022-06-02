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
            .toolbar(content: Toolbar.init)
    }
}

struct AddressBookScreen_Previews: PreviewProvider {
    static var previews: some View {
        AddressBookScreen()
    }
}
