//
//  SidebarView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SwiftUI

public struct SidebarView: View {
    @Binding var selection: SidebarID?
    
    public init(selection: Binding<SidebarID?>) {
      self._selection = selection
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Content(selection: $selection)
            Footer()
        }
        .toolbar(content: SidebarToolbar.init)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(
            selection: .constant(nil)
        )
    }
}
