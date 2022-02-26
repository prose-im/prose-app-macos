//
//  SidebarView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarID?
    
    var body: some View {
        VStack(spacing: 0) {
            SidebarPartSectionsComponent(
                selection: $selection
            )
            
            SidebarPartContextComponent()
        }
        .toolbar {
            SidebarToolbarComponent()
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(
            selection: .constant(nil)
        )
    }
}
