//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
  let store: StoreOf<ProfileReducer>

  @ObservedObject var viewStore: ViewStoreOf<ProfileReducer>
  @FocusState private var focusedField: ProfileReducer.Field?

  init(store: StoreOf<ProfileReducer>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    VStack(spacing: 32) {
      VStack {
        TextField(
          L10n.Authentication.Profile.Form.FullName.placeholder,
          text: self.viewStore.binding(\.$fullName)
        )
        .textContentType(.username)
        .focused(self.$focusedField, equals: .fullName)
        .onSubmit { self.viewStore.send(.fieldSubmitted(.fullName)) }

        TextField(
          L10n.Authentication.Profile.Form.Title.placeholder,
          text: self.viewStore.binding(\.$title)
        )
        .focused(self.$focusedField, equals: .title)
        .onSubmit { self.viewStore.send(.fieldSubmitted(.title)) }
      }.disabled(self.viewStore.isLoading)

      Button(action: { self.viewStore.send(.submitButtonTapped) }) {
        Text(
          self.viewStore.isLoading
            ? L10n.Authentication.Profile.Form.cancel
            : L10n.Authentication.Profile.Form.save
        )
        .frame(minWidth: 196)
      }
      .overlay(alignment: .leading) {
        if self.viewStore.isLoading {
          ProgressView()
            .scaleEffect(0.5, anchor: .center)
        }
      }
    }
    .synchronize(self.viewStore.binding(\.$focusedField), self.$focusedField)
    .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
  }
}
