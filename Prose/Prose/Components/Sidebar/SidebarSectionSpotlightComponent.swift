//
//  SidebarSectionSpotlightComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

struct SidebarSectionSpotlightComponent: View {
    @State var selection: SidebarID?
    
    let spotlightOptions: [SidebarOption] = [
        .init(
            id: .unreadStack,
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
            ForEach(spotlightOptions, id: \.self) { option in
                NavigationLink(
                    destination: ContentView(), tag: option.id, selection: $selection
                ) {
                    SidebarNavigationComponent(
                        title: option.title,
                        image: option.image,
                        count: option.count
                    )
                }
                .tag(option.id)
            }
        }
    }
}

struct SidebarSectionSpotlightComponent_Previews: PreviewProvider {
    static var previews: some View {
        SidebarSectionSpotlightComponent()
    }
}
