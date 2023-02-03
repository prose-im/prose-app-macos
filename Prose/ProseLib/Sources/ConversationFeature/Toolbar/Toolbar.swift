//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI

// MARK: - View

struct Toolbar: ToolbarContent {
  typealias State = ChatSessionState<ToolbarState>
  typealias Action = ToolbarAction

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>

  var body: some ToolbarContent {
    ToolbarItemGroup(placement: .navigation) {
      Self.navigationButtons(store: self.store)
    }

    ToolbarItemGroup {
      Self.otherButtons(
        store: self.store,
        redactionReasons: redactionReasons
      )
    }
  }

  @ViewBuilder
  static func navigationButtons(store: Store<State, Action>) -> some View {
    CommonToolbarNavigation()

    IfLetStore(store.scope(state: { $0.userInfos[$0.chatId] })) { store in
      ToolbarDivider()

      WithViewStore(store) { viewStore in
        ToolbarTitle(
          name: viewStore.name,
          // TODO: Make this dynamic
          status: .online
        )
      }
    }
  }

  @ViewBuilder
  static func otherButtons(
    store: Store<State, Action>,
    redactionReasons: RedactionReasons
  ) -> some View {
    IfLetStore(store.scope(state: { $0.userInfos[$0.chatId] })) { store in
      WithViewStore(store) { viewStore in
        ToolbarSecurity(
          jid: viewStore.jid,
          // TODO: Make this dynamic
          isVerified: false
        )

        ToolbarDivider()
      }
    }

    Self.actionItems(store: store, redactionReasons: redactionReasons)

    ToolbarDivider()

    CommonToolbarActions()
  }

  static func actionItems(
    store: Store<State, Action>,
    redactionReasons: RedactionReasons
  ) -> some View {
    WithViewStore(store) { viewStore in
      Button { viewStore.send(.startVideoCallTapped) } label: {
        Label("Video", systemImage: "video")
      }
      // https://github.com/prose-im/prose-app-macos/issues/48
      .disabled(true)

      Toggle(isOn: viewStore.binding(\State.$isShowingInfo).animation()) {
        Label("Info", systemImage: "info.circle")
      }
      .disabled(viewStore.childState.user == nil)
    }
    .unredacted()
    .disabled(redactionReasons.contains(.placeholder))
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

public let toolbarReducer: AnyReducer<
  ChatSessionState<ToolbarState>,
  ToolbarAction,
  Void
> = AnyReducer { state, action, _ in
  switch action {
  case .startVideoCallTapped:
    logger.info("Start video call tapped")

  case .binding(\.$isShowingInfo):
    if state.isShowingInfo {
      logger.info("Show info tapped")
    } else {
      logger.info("Stop showing info tapped")
    }

  case .binding:
    break
  }

  return .none
}.binding()

// MARK: State

public struct ToolbarState: Equatable {
  let user: User?
  @BindingState var isShowingInfo: Bool

  public init(
    user: User?,
    showingInfo: Bool = false
  ) {
    self.user = user ?? .init(
      jid: JID(rawValue: "hello@prose.org")!,
      displayName: #"¯\_(ツ)_/¯"#,
      fullName: #"¯\_(ツ)_/¯"#,
      avatar: nil,
      jobTitle: "Chatbot",
      company: "Acme Inc.",
      emailAddress: "chatbot@prose.org",
      phoneNumber: "0000000",
      location: "The Internets"
    )
    self.isShowingInfo = showingInfo
  }
}

// MARK: Actions

public enum ToolbarAction: Equatable, BindableAction {
  case startVideoCallTapped
  case binding(BindingAction<ChatSessionState<ToolbarState>>)
}

// MARK: - Previews

#if DEBUG
  internal struct Toolbar_Previews: PreviewProvider {
    private struct Preview: View {
      @Environment(\.redactionReasons) private var redactionReasons

      let state: ToolbarState

      var body: some View {
        let store = Store(
          initialState: .mock(state),
          reducer: toolbarReducer,
          environment: ()
        )
        VStack(alignment: .leading) {
          HStack {
            Toolbar.navigationButtons(store: store)
          }
          HStack {
            Toolbar.otherButtons(
              store: store,
              redactionReasons: redactionReasons
            )
          }
        }
        .padding()
        .previewLayout(.sizeThatFits)
      }
    }

    static var previews: some View {
      Preview(state: .init(user: nil))
      Preview(state: .init(user: nil))
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
