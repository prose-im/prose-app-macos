//
//  CommonToolbarNavigation.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

public struct CommonToolbarNavigation: View {
    public init() {}

    public var body: some View {
        Button { print("Navigation back tapped") } label: {
            Label("Back", systemImage: "chevron.backward")
        }
        Button { print("Navigation forward tapped") } label: {
            Label("Forward", systemImage: "chevron.forward")
        }
        Menu {
            // TODO: Add actions
            Text("TODO")
        } label: {
            Label("History", systemImage: "clock")
        }
    }
}

struct CommonToolbarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CommonToolbarNavigation()
        }
    }
}
