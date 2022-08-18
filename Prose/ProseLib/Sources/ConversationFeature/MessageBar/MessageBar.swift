//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import ProseCoreTCA
import ProseUI
import SwiftUI

// MARK: - View

struct MessageBar: View {
  typealias State = MessageBarState
  typealias Action = MessageBarAction

  static let height: CGFloat = 64

  @Environment(\.redactionReasons) private var redactionReasons

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some View {
    VStack(spacing: 0) {
      Divider()

      HStack(spacing: 16) {
        leadingButtons()

        ZStack {
          MessageBarTextField(store: self.store.scope(
            state: \.textField,
            action: Action.textField
          ))
        }
        .frame(maxHeight: .infinity)
        .overlay(alignment: .typingIndicator) {
          WithViewStore(self.store.scope(state: \.typingUsers)) { typingUsers in
            TypingIndicator(typingUsers: typingUsers.state)
          }
          .offset(y: -1)
        }

        trailingButtons()
      }
      .font(.title2)
      .padding(.horizontal, 20)
      .frame(maxHeight: Self.height)
    }
    .frame(height: Self.height)
    .foregroundColor(.secondary)
    // TODO: [Rémi Bardon] Maybe add a material background here, to make it more beautiful with content going under
//    .background(.ultraThinMaterial)
    .background(.background)
    // Make sure accessibility frame is correct
    .contentShape(Rectangle())
    .accessibilityElement(children: .contain)
    .onAppear { self.actions.send(.onAppear) }
    .onDisappear { self.actions.send(.onDisappear) }
  }

  private func leadingButtons() -> some View {
    HStack(spacing: 12) {
      Button { actions.send(.textFormatTapped) } label: {
        Image(systemName: "textformat.alt")
      }
    }
    .buttonStyle(.plain)
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
    // https://github.com/prose-im/prose-app-macos/issues/48
    .disabled(true)
  }

  private func trailingButtons() -> some View {
    HStack(spacing: 12) {
      Button { actions.send(.addAttachmentTapped) } label: {
        Image(systemName: "paperclip")
      }
      // https://github.com/prose-im/prose-app-macos/issues/48
      .disabled(true)
      Button { actions.send(.showEmojisTapped) } label: {
        Image(systemName: "face.smiling")
      }
      .reactionPicker(
        store: self.store.scope(state: \.reactionPicker),
        action: Action.reactionPicker,
        dismiss: .reactionPickerDismissed
      )
    }
    .buttonStyle(.plain)
    .unredacted()
    .disabled(self.redactionReasons.contains(.placeholder))
  }
}

// MARK: - The Composable Architecture

// MARK: Reducer

enum MessageBarEffectToken: Hashable, CaseIterable {
  case observeParticipantStates
}

public let messageBarReducer: Reducer<
  MessageBarState,
  MessageBarAction,
  ConversationEnvironment
> = Reducer.combine([
  messageBarTextFieldReducer.pullback(
    state: \MessageBarState.textField,
    action: CasePath(MessageBarAction.textField),
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .onAppear:
      let chatId = state.chatId
      let loggedInUserJID = state.loggedInUserJID
      return environment.proseClient.activeChats()
        .compactMap { $0[chatId] }
        .map(\.participantStates)
        .map { (participantStates: [JID: ProseCoreTCA.ChatState]) in
          participantStates
            .filter { $0.value.kind == .composing }
            .filter { $0.key != loggedInUserJID }
            .map { Name.jid($0.key) }
        }
        .replaceError(with: [])
        .removeDuplicates()
        .eraseToEffect()
        .map(MessageBarAction.typingUsersChanged)
        .cancellable(id: MessageBarEffectToken.observeParticipantStates)

    case .onDisappear:
      return .cancel(token: MessageBarEffectToken.self)

    case let .typingUsersChanged(names):
      state.typingUsers = names
      return .none

    case .showEmojisTapped:
      state.reactionPicker = .init()
      return .none

    case let .reactionPicker(.select(reaction)):
      state.textField.message.append(contentsOf: reaction.rawValue)
      state.reactionPicker = nil
      return .none

    case .reactionPickerDismissed:
      state.reactionPicker = nil
      return .none

    case .textFormatTapped, .addAttachmentTapped, .textField, .reactionPicker, .binding:
      return .none
    }
  }.binding(),
])

// MARK: State

public struct MessageBarState: Equatable {
  let chatId: JID
  let loggedInUserJID: JID
  var typingUsers: [Name]
  var textField: MessageBarTextFieldState
  var reactionPicker: ReactionPickerState?

  public init(
    chatId: JID,
    loggedInUserJID: JID,
    chatName: Name,
    message: String = "",
    typingUsers: [Name] = []
  ) {
    self.chatId = chatId
    self.loggedInUserJID = loggedInUserJID
    self.typingUsers = typingUsers
    self.textField = .init(chatId: chatId, chatName: chatName, message: message)
  }
}

// MARK: Actions

public enum MessageBarAction: Equatable, BindableAction {
  case onAppear, onDisappear
  case typingUsersChanged([Name])
  case textFormatTapped, addAttachmentTapped, showEmojisTapped
  case textField(MessageBarTextFieldAction)
  case reactionPicker(ReactionPickerAction), reactionPickerDismissed
  case binding(BindingAction<MessageBarState>)
}

// MARK: - Previews

#if DEBUG
  internal struct MessageBar_Previews: PreviewProvider {
    private struct Preview: View {
      let recipient: JID

      var body: some View {
        MessageBar(store: Store(
          initialState: MessageBarState(
            chatId: self.recipient,
            loggedInUserJID: "preview@prose.org",
            chatName: .jid(self.recipient),
            message: "",
            typingUsers: [.jid(self.recipient)]
          ),
          reducer: messageBarReducer,
          environment: .init(proseClient: .noop, pasteboard: .live(), mainQueue: .main)
        ))
      }
    }

    static var previews: some View {
      Group {
        Preview(recipient: "preview.recipient@prose.org")
          .previewDisplayName("Simple username")
        Preview(recipient: "")
          .previewDisplayName("Empty")
        Preview(recipient: "preview.recipient@prose.org")
          .padding()
          .background(Color.pink)
          .previewDisplayName("Colorful background")
        Preview(recipient: "preview.recipient@prose.org")
          .redacted(reason: .placeholder)
          .previewDisplayName("Placeholder")
      }
      .preferredColorScheme(.light)
      Group {
        Preview(recipient: "preview.recipient@prose.org")
          .previewDisplayName("Simple username / Dark")
        Preview(recipient: "")
          .previewDisplayName("Empty / Dark")
        Preview(recipient: "preview.recipient@prose.org")
          .padding()
          .background(Color.pink)
          .previewDisplayName("Colorful background / Dark")
        Preview(recipient: "preview.recipient@prose.org")
          .redacted(reason: .placeholder)
          .previewDisplayName("Placeholder / Dark")
      }
      .preferredColorScheme(.dark)
    }
  }
#endif
