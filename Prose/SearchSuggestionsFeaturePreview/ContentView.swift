//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SearchSuggestionsFeature
import SwiftUI

struct ContentView: View {
  @State private var text: String = "Start"
  var body: some View {
    SearchSuggestionsField(text: $text)
      .frame(minWidth: 256)
      .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
