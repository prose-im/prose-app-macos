//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

struct VideoPreviewView: View {
  @State var streamPath: String
  @State var sizeWidth: CGFloat = 180
  @State var sizeHeight: CGFloat = 100

  var body: some View {
    Image(self.streamPath)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: self.sizeWidth, height: self.sizeHeight)
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
