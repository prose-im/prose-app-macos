//
//  Sidebar+SpotlightSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

extension SidebarView {
    struct SpotlightSection: View {
        @Binding var selection: SidebarID?

        let items: [SidebarOption] = [
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
            Section("sidebar_section_spotlight".localized()) {
                ForEach(items) { item in
                    NavigationLink(tag: item.id, selection: $selection) {
                        ContentView(selection: item.id)
                    } label: {
                        SidebarNavigationRow(
                            title: item.title,
                            image: item.image,
                            count: item.count
                        )
                    }
                }
            }
        }
    }
}

struct Sidebar_SpotlightSection_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SidebarView.SpotlightSection(
                selection: .constant(nil)
            )
        }
    }
}
