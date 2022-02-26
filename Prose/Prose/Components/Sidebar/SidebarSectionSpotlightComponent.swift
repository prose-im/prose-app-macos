//
//  SidebarSectionSpotlightComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionSpotlightComponent: View {
    @Binding var selection: SidebarID?
    
    let spotlightOptions: [SidebarOption] = [
        .init(
            id: .unread,
            title: "sidebar_spotlight_unread_stack".localized(),
            image: "tray.2",
            count: 0
        ),
        .init(
            id: .replies,
            title: "sidebar_spotlight_replies".localized(),
            image: "arrowshape.turn.up.left.2",
            count: 5
        ),
        .init(
            id: .directMessages,
            title: "sidebar_spotlight_direct_messages".localized(),
            image: "message",
            count: 0
        ),
        .init(
            id: .peopleAndGroups,
            title: "sidebar_spotlight_people_and_groups".localized(),
            image: "text.book.closed",
            count: 2
        ),
    ]
    
    var body: some View {
        Section(header: Text("sidebar_section_spotlight".localized())) {
            ForEach(spotlightOptions) { option in
                NavigationLink(tag: option.id, selection: $selection) {
                    ContentView(selection: option.id)
                } label: {
                    SidebarNavigationComponent(
                        title: option.title,
                        image: option.image,
                        count: option.count
                    )
                }
            }
        }
    }
}

struct SidebarSectionSpotlightComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionSpotlightComponent(
            selection: .constant(nil)
        )
    }
}
