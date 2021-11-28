//
//  ContentCommonToolbarComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct ContentCommonToolbarComponent: ToolbarContent {
    var body: some ToolbarContent {
        let stackSpacing: CGFloat = 16.0
        
        ToolbarItemGroup(placement: .navigation) {
            HStack(spacing: stackSpacing) {
                ContentCommonToolbarNavigationComponent()
                
                Divider()
                
                ContentCommonToolbarTitleComponent()
            }
        }
        
        ToolbarItemGroup {
            HStack(spacing: stackSpacing) {
                ContentCommonToolbarAuthenticationComponent()
                
                Divider()
                
                ContentCommonToolbarActionsComponent()
            }
        }
    }
}
