//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

struct ThreeColumns<Column1: View, Column2: View, Column3: View>: View {
  let column1: () -> Column1
  let column2: () -> Column2
  let column3: () -> Column3

  /// - Note: The ``ZStack``s allow SwiftUI to keep some space for views.
  ///         Without it, the second column of a ``ThreeColumns<_, _, EmptyView>`` would span
  ///         all the way until the trailing edge, which is not what we want.
  var body: some View {
    HStack {
      ZStack(content: column1)
        .font(.headline.weight(.medium))
        .frame(width: 96, alignment: .leading)
      ZStack(content: column2)
        .frame(maxWidth: .infinity, alignment: .leading)
      ZStack(content: column3)
        .font(.headline.weight(.medium))
        .frame(width: 96, alignment: .leading)
    }
  }
}

struct ThreeColumns_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ThreeColumns {
        Text("First name:")
      } column2: {
        TextField(text: .constant("Baptiste"), label: { Text("Label") })
          .textFieldStyle(.roundedBorder)
          .controlSize(.large)
      } column3: {
        Button {} label: {
          Text("Get verified")
        }
        .buttonStyle(.link)
      }
      ThreeColumns {
        Text("Password:")
      } column2: {
        Button {} label: {
          Text("Change password…")
            .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
      } column3: {
        EmptyView()
      }
      ThreeColumns {
        Text("Auto-detect:")
      } column2: {
        Toggle(isOn: .constant(true), label: { Text("Label") })
          .toggleStyle(.switch)
          .labelsHidden()
      } column3: {
        EmptyView()
      }
    }
    .padding()
  }
}
