//
//  BaseView.swift
//  Prose
//
//  Created by Valerian Saliou on 9/14/21.
//

import SidebarFeature
import SwiftUI

public struct AppView: View {
    @State var selection: SidebarID? = .unread
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            SidebarView(selection: $selection)
                .frame(minWidth: 280.0)
            Text("Nothing to show here 🤷")
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 1280, minHeight: 720)
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AppView()
        }
    }
}
