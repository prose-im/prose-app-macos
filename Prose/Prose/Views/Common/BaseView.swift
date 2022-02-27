//
//  BaseView.swift
//  Prose
//
//  Created by Valerian Saliou on 9/14/21.
//

import SwiftUI

struct BaseView: View {
    @State var selection: SidebarID? = .unread
    
    var body: some View {
        NavigationView {
            SidebarView(selection: $selection)
                .frame(minWidth: 280.0)
            Text("Nothing to show here 🤷")
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 1280, minHeight: 720)
    }
}

struct BaseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BaseView()
        }
    }
}
