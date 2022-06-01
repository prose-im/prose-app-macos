//
//  Sidebar+OtherContactsSection.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import PreviewAssets
import SwiftUI

extension SidebarView {
    struct OtherContactsSection: View {
        @Binding var selection: SidebarID?

        let items: [SidebarOption] = [
            .init(
                id: .person(id: "id-baptiste"),
                title: "Baptiste",
                image: PreviewImages.Avatars.baptiste.rawValue,
                count: 0
            ),
        ]

        var body: some View {
            Section("sidebar_section_other_contacts".localized()) {
                ForEach(items) { item in
                    NavigationLink(tag: item.id, selection: $selection) {
                        ContentView(selection: item.id)
                    } label: {
                        SidebarContactRow(
                            title: item.title,
                            avatar: item.image,
                            count: item.count
                        )
                    }
                }

                SidebarActionRow(
                    title: "sidebar_other_contacts_add",
                    systemImage: "plus.square.fill"
                ) {
                    // TODO: [Rémi Bardon] Add action
                    print("Add contact tapped")
                }
            }
        }
    }
}

struct Sidebar_OtherContactsSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                SidebarView.OtherContactsSection(
                    selection: .constant(nil)
                )
            }
            .frame(width: 256)
        }
    }
}
