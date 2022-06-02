//
//  CommonToolbar.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

public struct CommonToolbar: ToolbarContent {
    public init() {}

    public var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            CommonToolbarNavigation()
        }

        ToolbarItemGroup {
            CommonToolbarActions()
        }
    }
}
