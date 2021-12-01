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
    case favoritesAtom(String)
    case teamMembersAtom(String)
    case teamMembersAdd
    case otherContactsAtom(String)
    case otherContactsAdd
    case groupsAtom(String)
    case groupsAdd
}

extension SidebarID: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .unreadStack:
            hasher.combine(0)
        case .replies:
            hasher.combine(1)
        case .directMessages:
            hasher.combine(2)
        case .peopleAndGroups:
            hasher.combine(3)
        case .favoritesAtom(let inner):
            hasher.combine(4)
            hasher.combine(inner)
        case .teamMembersAtom(let inner):
            hasher.combine(5)
            hasher.combine(inner)
        case .teamMembersAdd:
            hasher.combine(6)
        case .otherContactsAtom(let inner):
            hasher.combine(7)
            hasher.combine(inner)
        case .otherContactsAdd:
            hasher.combine(8)
        case .groupsAtom(let inner):
            hasher.combine(9)
            hasher.combine(inner)
        case .groupsAdd:
            hasher.combine(10)
        }
    }
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
        VStack(spacing: 0) {
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
