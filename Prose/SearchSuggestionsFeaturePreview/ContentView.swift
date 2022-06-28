//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SearchSuggestionsFeature
import SwiftUI

struct ContentView: View {
  @State private var text: String = "Start"
  var body: some View {
    VStack(alignment: .leading) {
      Text("Search for a user 👇")
        .font(.headline)
      Text("You should see a popup appear, and be able to navigate with arrow keys.")
        .font(.subheadline)
      SearchSuggestionsField(text: $text)
    }
    .fixedSize(horizontal: false, vertical: true)
    .frame(minWidth: 320)
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
