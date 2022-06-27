//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import SwiftUI

struct DaySeparator: View {
  static let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
  }()

  let date: Date

  var body: some View {
    HStack {
      Colors.Border.tertiary.color
        .frame(height: 1)
      Text(date, formatter: Self.formatter)
        .layoutPriority(1)
        .foregroundColor(.secondary)
      Colors.Border.tertiary.color
        .frame(height: 1)
    }
  }
}

struct DaySeparator_Previews: PreviewProvider {
  static var previews: some View {
    DaySeparator(date: .now)
  }
}
