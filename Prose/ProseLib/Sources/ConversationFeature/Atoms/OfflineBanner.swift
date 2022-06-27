//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import SwiftUI

private let l10n = L10n.Chat.OfflineBanner.self

// MARK: - View

struct OfflineBanner: View {
  typealias ViewState = OfflineBannerState
  typealias ViewAction = OfflineBannerAction

  let store: Store<ViewState, ViewAction>
  private var actions: ViewStore<Void, ViewAction> { ViewStore(self.store.stateless) }

  var body: some View {
    HStack {
      Group {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.title.bold())
        Text(l10n.title)
          .font(.title3.bold())
        Text(l10n.content)
          .foregroundColor(.white.opacity(0.875))
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .foregroundColor(.white)
      Button(l10n.ReconnectAction.title) { actions.send(.reconnectTapped) }
        .controlSize(.large)
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 24)
    .frame(maxWidth: .infinity)
    .fixedSize(horizontal: false, vertical: true)
    .background(Color.gray)
  }
}

// MARK: - The Composabe Architecture

// MARK: Reducer

public let offlineBannerReducer = Reducer<
  OfflineBannerState,
  OfflineBannerAction,
  Void
> { _, action, _ in
  switch action {
  case .reconnectTapped:
    logger.trace("Reconnect tapped")
    return .none
  }
}

// MARK: State

public struct OfflineBannerState: Equatable {}

// MARK: Actions

public enum OfflineBannerAction: Equatable {
  case reconnectTapped
}

// MARK: - Previews

struct OfflineBanner_Previews: PreviewProvider {
  struct Preview: View {
    var body: some View {
      OfflineBanner(store: Store(
        initialState: OfflineBannerState(),
        reducer: offlineBannerReducer,
        environment: ()
      ))
    }
  }

  static var previews: some View {
    Preview()
      .frame(width: 720)
      .preferredColorScheme(.light)
      .previewDisplayName("Light")
    Preview()
      .frame(width: 720)
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark")
    Preview()
      .frame(width: 512)
      .previewDisplayName("Constrained")
  }
}
