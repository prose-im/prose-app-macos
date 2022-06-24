//
//  VideoPreviewView.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import SwiftUI

struct VideoPreviewView: View {
    @State var streamPath: String
    @State var sizeWidth: CGFloat = 180
    @State var sizeHeight: CGFloat = 100

    var body: some View {
        Image(streamPath)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: sizeWidth, height: sizeHeight)
            .background(.black)
            .cornerRadius(4)
            .clipped()
    }
}

struct VideoPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPreviewView(
            streamPath: "webcam-valerian",
            sizeWidth: 260,
            sizeHeight: 180
        )
    }
}
