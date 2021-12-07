//
//  AdvancedSettingsView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/7/21.
//

import SwiftUI
import Preferences

struct AdvancedSettingsView: View {
    var body: some View {
        Preferences.Container(contentWidth: SettingsContants.contentWidth) {
            // TODO: fill this
        }
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
    }
}
