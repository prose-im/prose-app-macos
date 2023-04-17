//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import SwiftUI

public extension View {
  /// Synchronizes a `Binding` and a `FocusState.Binding`.
  ///
  /// Comes from <https://github.com/pointfreeco/episode-code-samples/blob/891f028d38bfa9f1bbbd3b4e24760feaa43947fe/0159-safer-conciser-forms-pt2/ConciseForms/ConciseForms/FocusState.swift#L70-L77>.
  func synchronize<Value>(
    _ first: Binding<Value>,
    _ second: FocusState<Value>.Binding
  ) -> some View {
    self
      .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
      .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
  }
}
