//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import ComposableArchitecture
import ProseCoreTCA
import SwiftUI
import Toolbox

private let l10n = L10n.Content.MessageBar.self

// MARK: - View

struct MessageBar: View {
  typealias State = ChatSessionState<MessageBarState>
  typealias Action = MessageBarAction

  static let verticalPadding: CGFloat = 12
  static let buttonsFont: Font = .system(size: 16)

  let store: Store<State, Action>
  private var actions: ViewStore<Void, Action> { ViewStore(self.store.stateless) }

  var body: some View {
    HStack(alignment: .messageBar, spacing: 16) {
      leadingButtons()
        .font(Self.buttonsFont)
        .alignmentGuide(.messageBar) {
          $0[VerticalAlignment.center] + MessageField.minimumHeight / 2
        }

      MessageComposingField(
        store: self.store.scope(state: \.messageField, action: Action.messageField)
      )
      .alignmentGuide(.top) {
        $0[VerticalAlignment.top] - Self.verticalPadding
      }
      .overlay(alignment: .typingIndicator) {
        WithViewStore(self.store.scope(state: \.typingUsers)) { typingUsers in
          TypingIndicator(typingUsers: typingUsers.state)
        }
      }

      trailingButtons()
        .font(Self.buttonsFont)
        .alignmentGuide(.messageBar) {
          $0[VerticalAlignment.center] + MessageField.minimumHeight / 2
        }
    }
    .padding(.vertical, Self.verticalPadding)
    .foregroundColor(.secondary)
    .padding(.horizontal, 20)
    .background {
      Rectangle()
        // TODO: [Rémi Bardon] Maybe add a material background here,
        //       to make it more beautiful with content going under
//        .fill(.ultraThinMaterial)
        .fill(.background)
        .overlay(alignment: .top, content: Divider.init)
    }
    .fixedSize(horizontal: false, vertical: true)
    .onAppear { self.actions.send(.onAppear) }
    .onDisappear { self.actions.send(.onDisappear) }
    // Make sure accessibility frame is correct
    .contentShape(Rectangle())
    .accessibilityElement(children: .contain)
  }

  private func leadingButtons() -> some View {
    HStack(spacing: 12) {
      MessageFormattingButton(store: self.store.scope(
        state: \.formatting,
        action: Action.formatting
      ))
    }
    .buttonStyle(.plain)
  }

  private func trailingButtons() -> some View {
    HStack(spacing: 12) {
      MessageAttachmentsButton(store: self.store.scope(
        state: \.attachments,
        action: Action.attachments
      ))
      MessageEmojisButton(store: self.store.scope(
        state: \.emojis,
        action: Action.emojis
      ))
    }
    .buttonStyle(.plain)
  }
}

private struct MessageBarAlignment: AlignmentID {
  static func defaultValue(in context: ViewDimensions) -> CGFloat {
    context[VerticalAlignment.bottom]
  }
}

private extension VerticalAlignment {
  static let messageBar: Self = .init(MessageBarAlignment.self)
}

extension Alignment {
  static let messageBar: Self = .init(horizontal: .center, vertical: .messageBar)
}

// MARK: - The Composable Architecture

// MARK: Reducer

enum MessageBarEffectToken: Hashable, CaseIterable {
  case observeParticipantStates
}

public let messageBarReducer = Reducer<
  ChatSessionState<MessageBarState>,
  MessageBarAction,
  ConversationEnvironment
>.combine(
  messageComposingFieldReducer.pullback(
    state: \.messageField,
    action: CasePath(MessageBarAction.messageField),
    environment: { $0 }
  ),
  messageFormattingReducer.pullback(
    state: \.formatting,
    action: CasePath(MessageBarAction.formatting),
    environment: { _ in () }
  ),
  messageAttachmentsReducer.pullback(
    state: \.attachments,
    action: CasePath(MessageBarAction.attachments),
    environment: { _ in () }
  ),
  messageEmojisReducer.pullback(
    state: \.emojis,
    action: CasePath(MessageBarAction.emojis),
    environment: { _ in () }
  ),
  Reducer { state, action, environment in
    switch action {
    case .onAppear:
      let chatId = state.chatId
      let loggedInUserJID = state.currentUser.jid
      return environment.proseClient.activeChats()
        .compactMap { $0[chatId] }
        .map(\.participantStates)
        .map { (participantStates: [JID: ProseCoreTCA.ChatState]) in
          participantStates
            .filter { $0.value.kind == .composing }
            .filter { $0.key != loggedInUserJID }
            .map(\.key)
        }
        .replaceError(with: [])
        .removeDuplicates()
        .eraseToEffect()
        .map(MessageBarAction.typingUsersChanged)
        .cancellable(id: MessageBarEffectToken.observeParticipantStates)

    case .onDisappear:
      return .cancel(token: MessageBarEffectToken.self)

    case let .typingUsersChanged(jids):
      state.typingUsers = jids.map { state.userInfos[$0, default: .init(jid: $0)] }
      return .none

    case let .emojis(.insert(reaction)):
      // NOTE: We could find a way to use [smartInsert](https://developer.apple.com/documentation/appkit/nstextview/1449467-smartinsert)
      //       to add proper spacing (system behavior).
      state.messageField.textField.replaceSelection(with: reaction.rawValue)
      state.messageField.textField.isFocused = true
      return .none

    case let .messageField(.field(.send(messageContent))):
      return environment.proseClient.sendMessage(state.chatId, messageContent)
        .catchToEffect()
        .map(MessageBarAction.messageSendResult)

    case let .formatting(.formatTapped(format)):
      func surround(between delimiter1: String, and delimiter2: String, selectionOffset: Int) {
        let typingAttributes = state.messageField.textField.typingAttributes.attributes
        state.messageField.textField.replaceSelection { (subStr: NSMutableAttributedString) in
          let startAttributes, endAttributes: [NSAttributedString.Key: Any]
          if subStr.length == 0 {
            startAttributes = typingAttributes
            endAttributes = typingAttributes
          } else {
            startAttributes = subStr.attributes(at: 0, effectiveRange: nil)
            endAttributes = subStr.attributes(at: subStr.length - 1, effectiveRange: nil)
          }
          subStr.insert(NSAttributedString(string: delimiter1, attributes: startAttributes), at: 0)
          subStr.append(NSAttributedString(string: delimiter2, attributes: endAttributes))
        }
        state.messageField.textField.offsetSelection(by: selectionOffset)
      }
      func surround(by delimiter: String, selectionOffset: Int) {
        surround(between: delimiter, and: delimiter, selectionOffset: selectionOffset)
      }

      switch format {
      case .bold:
        surround(by: "**", selectionOffset: -2)
      case .italic:
        surround(by: "_", selectionOffset: -1)
      case .underline:
        surround(between: "<u>", and: "</u>", selectionOffset: -4)
      case .strikethrough:
        surround(by: "~~", selectionOffset: -2)
      case .unorderedList:
        var selection = state.messageField.textField.selection
        var range = state.messageField.textField.range
        state.messageField.textField.replaceSelectedLines {
          (subStr: NSMutableAttributedString, indices: ReversedCollection<[Int]>) in
          indices.forEach { index in
            subStr.insert(NSAttributedString(string: "- "), at: index)
            range.length += 2
            selection.prose_extend(by: 2, in: range)
          }
        }
        selection.prose_extend(by: -2, in: range)
        selection.prose_offset(by: 2, in: range)
        state.messageField.textField.selection = selection
      case .orderedList:
        var selection = state.messageField.textField.selection
        var range = state.messageField.textField.range
        state.messageField.textField.replaceSelectedLines {
          (subStr: NSMutableAttributedString, indices: ReversedCollection<[Int]>) in
          var number = indices.count
          indices.forEach { index in
            let insertedString = "\(number). "
            subStr.insert(NSAttributedString(string: insertedString), at: index)
            number -= 1
            range.length += insertedString.count
            selection.prose_extend(by: insertedString.count, in: range)
          }
        }
        // First item is always "1. "
        selection.prose_extend(by: -3, in: range)
        selection.prose_offset(by: 3, in: range)
        state.messageField.textField.selection = selection
      case .quoteBlock:
        var selection = state.messageField.textField.selection
        var range = state.messageField.textField.range
        state.messageField.textField.replaceSelectedLines {
          (subStr: NSMutableAttributedString, indices: ReversedCollection<[Int]>) in
          indices.forEach { index in
            subStr.insert(NSAttributedString(string: "> "), at: index)
            range.length += 2
            selection.prose_extend(by: 2, in: range)
          }
        }
        selection.prose_extend(by: -2, in: range)
        selection.prose_offset(by: 2, in: range)
        state.messageField.textField.selection = selection
      case .link:
        surround(between: "[", and: "]()", selectionOffset: -1)
      case .code:
        surround(by: "`", selectionOffset: -1)
      }
      state.messageField.textField.isFocused = true
      return .none

    case .messageSendResult(.success):
      state.messageField.textField.clear()
      return .none

    case let .messageSendResult(.failure(error)):
      logger.notice("Error when sending message: \(error)")
      // Ignore the error for now. There is no error handling in the library so far.
      // FIXME: https://github.com/prose-im/prose-app-macos/issues/114
      return .none

    case .messageField, .formatting, .attachments, .emojis, .binding:
      return .none
    }
  }.binding()
)

// MARK: State

public struct MessageBarState: Equatable {
  var typingUsers: [UserInfo]
  var messageField: MessageFieldState
  var formatting: MessageFormattingState = .init()
  var attachments: MessageAttachmentsState = .init()
  var emojis: MessageEmojisState = .init()

  public init(message: String = "", typingUsers: [UserInfo] = []) {
    self.typingUsers = typingUsers
    self.messageField = .init(placeholder: "", message: message)
  }
}

private extension ChatSessionState where ChildState == MessageBarState {
  var messageField: ChatSessionState<MessageFieldState> {
    get {
      var messageField = self.get(\.messageField)
      messageField.textField.setPlaceholder(
        to: l10n.fieldPlaceholder(self.userInfos[self.chatId]?.name ?? self.chatId.jidString)
      )
      return messageField
    }
    set { self.set(\.messageField, newValue) }
  }
}

// MARK: Actions

public enum MessageBarAction: Equatable, BindableAction {
  case onAppear, onDisappear
  case typingUsersChanged([JID])
  case messageSendResult(Result<None, EquatableError>)
  case messageField(MessageComposingFieldAction)
  case formatting(MessageFormattingAction)
  case attachments(MessageAttachmentsAction)
  case emojis(MessageEmojisAction)
  case binding(BindingAction<ChatSessionState<MessageBarState>>)
}

// MARK: - Previews

#if DEBUG
  internal struct MessageBar_Previews: PreviewProvider {
    private struct Preview: View {
      let recipient: JID = "preview.recipient@prose.org"
      let message: String
      let isTyping: Bool
      let showBorder: Bool

      init(message: String = "", isTyping: Bool = false, showBorder: Bool = false) {
        self.message = message
        self.isTyping = isTyping
        self.showBorder = showBorder
      }

      var body: some View {
        MessageBar(store: Store(
          initialState: .mock(MessageBarState(
            message: self.message,
            typingUsers: self.isTyping ? [.init(jid: self.recipient)] : []
          )),
          reducer: messageBarReducer,
          environment: .init(proseClient: .noop, pasteboard: .live(), mainQueue: .main)
        ))
        .frame(width: 500)
        .padding(self.showBorder ? 1 : 0)
        .border(self.showBorder ? Color.red : Color.clear)
        .padding()
      }
    }

    static var previews: some View {
      let previews = VStack(spacing: 16) {
        GroupBox("Simple username") {
          Preview(isTyping: true)
        }
        GroupBox("Empty with border") {
          Preview(showBorder: true)
        }
        GroupBox("High") {
          Preview(
            message: (1...5).map { "Line \($0)" }.joined(separator: "\n"),
            isTyping: true
          )
        }
        GroupBox("Colorful background") {
          Preview(isTyping: true)
            .background(Color.pink)
        }
        GroupBox("Placeholder") {
          Preview(isTyping: true)
            .redacted(reason: .placeholder)
        }
      }
      .fixedSize()
      .padding(8)
      previews
        .preferredColorScheme(.light)
        .previewDisplayName("Light")
      previews
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark")
    }
  }
#endif
