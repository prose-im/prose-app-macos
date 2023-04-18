//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import SwiftUI

public enum Icon: String, CaseIterable {
  case unread = "tray.2"
  case reply = "arrowshape.turn.up.left.2"
  case directMessage = "message"
  case addressBook = "text.book.closed"
  case group = "circle.grid.2x2"

  public var image: Image {
    Image(systemName: self.rawValue)
  }
}

struct Icon_Previews: PreviewProvider {
  static var previews: some View {
    List {
      ForEach(Icon.allCases, id: \.rawValue) { icon in
        Label(String(describing: icon), systemImage: icon.rawValue)
      }
    }
    .frame(width: 200)
  }
}
