//
//  SettingsPreviewVideoComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct SettingsPreviewVideoComponent: View {
    @State var streamPath: String
    @State var sizeWidth: CGFloat = 180
    @State var sizeHeight: CGFloat = 100
    
    var body: some View {
        Image(streamPath)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: sizeWidth, height: sizeHeight)
            .background(.black)
            .cornerRadius(4.0)
            .clipped()
    }
}

struct SettingsPreviewVideoComponent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPreviewVideoComponent(
            streamPath: "webcam-valerian",
            sizeWidth: 260.0,
            sizeHeight: 180.0
        )
    }
}
