//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import ProseCoreTCA
import ProseUI
import SwiftUI

public struct MessageView: View {
  let model: Message

  public init(model: Message) {
    self.model = model
  }

  public var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Avatar(.placeholder, size: 32)

      VStack(alignment: .leading, spacing: 3) {
        HStack(alignment: .firstTextBaseline) {
          Text(model.from.jidString)
            .font(.system(size: 13).bold())
            .foregroundColor(Colors.Text.primary.color)

          Text(model.timestamp, format: .relative(presentation: .numeric))
            .font(.system(size: 11.5))
            .foregroundColor(Colors.Text.secondary.color)
        }

        Text(model.body)
          .font(.system(size: 12.5))
          .fontWeight(.regular)
          .foregroundColor(Colors.Text.primary.color)
      }
      .textSelection(.enabled)

      Spacer()
    }
  }
}
