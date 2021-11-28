//
//  SidebarView.swift
//  Prose
//
//  Created by Valerian Saliou on 11/15/21.
//

import SwiftUI

enum SidebarID {
    case unreadStack
    case replies
    case directMessages
    case peopleAndGroups
    case favoritesAtom
    case teamMembersAtom
    case teamMembersAdd
    case otherContactsAtom
    case otherContactsAdd
    case groupsAtom
    case groupsAdd
}

struct SidebarOption: Hashable {
    let id: SidebarID
    let title: String
    let image: String
    let count: UInt16
}

struct SidebarView: View {
    @State var selection: SidebarID? = .unreadStack
    
    var body: some View {
        VStack {
            SidebarPartSectionsComponent(
                selection: selection
            )
            
            SidebarPartContextComponent()
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
