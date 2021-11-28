//
//  ContentMessageDetailsInformationComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/23/21.
//

import SwiftUI

struct ContentMessageDetailsInformationComponent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(verbatim: "valerian@crisp.chat")
            Text(verbatim: "+33631210280")
            Text(verbatim: "Active 1 min ago")
            Text(verbatim: "5:03pm (UTC+1)")
            Text(verbatim: "Lisbon, Portugal")
            Text(verbatim: "Focusing on code")
        }
    }
}

struct ContentMessageDetailsInformationComponent_Previews: PreviewProvider {
    static var previews: some View {
        ContentMessageDetailsInformationComponent()
    }
}
