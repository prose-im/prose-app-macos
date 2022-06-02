//
//  CommonToolbarActions.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

public struct CommonToolbarActions: View {
    public init() {}

    public var body: some View {
        Button { print("Search tapped") } label: {
            Label("Search", systemImage: "magnifyingglass")
        }
    }
}

struct CommonToolbarActions_Previews: PreviewProvider {
    static var previews: some View {
        CommonToolbarActions()
    }
}
