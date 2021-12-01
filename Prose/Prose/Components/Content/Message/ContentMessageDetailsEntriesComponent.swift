//
//  ContentMessageDetailsEntriesComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/1/21.
//

import SwiftUI

struct ContentMessageDetailsEntriesComponent: View {
    var entries: [ContentMessageDetailsEntryOption]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(entries, id: \.self) { entry in
                ContentMessageDetailsEntryComponent(
                    entry: entry
                )
            }
        }
    }
}

struct ContentMessageDetailsEntriesComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsEntriesComponent(
            entries: [
                .init(
                    value: "Email address",
                    image: .system("envelope.fill")
                ),
                .init(
                    value: "Phone number",
                    image: .system("iphone")
                )
            ]
        )
    }
}
