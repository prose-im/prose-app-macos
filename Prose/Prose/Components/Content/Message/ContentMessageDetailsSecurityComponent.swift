//
//  ContentMessageDetailsSecurityComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct ContentMessageDetailsSecurityComponent: View {
    let entries: [ContentMessageDetailsEntryOption] = [
        .init(
            value: "content_message_details_security_identity_verified".localized(),
            image: .system("checkmark.seal.fill"),
            imageColor: .stateGreen
        ),
        .init(
            value: "content_message_details_security_encrypted".localized() + " (C648A)",
            image: .system("lock.fill"),
            imageColor: .stateBlue
        ),
    ]
    
    var body: some View {
        ContentMessageDetailsEntriesComponent(
            entries: entries
        )
    }
}

struct ContentMessageDetailsSecurityComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsSecurityComponent()
    }
}
