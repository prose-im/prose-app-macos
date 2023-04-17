//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import AppLocalization
import Combine
import ComposableArchitecture
@testable import ConversationFeature
import TestHelpers
import Toolbox
import XCTest

final class TypingIndicatorTests: XCTestCase {
  let scheduler = DispatchQueue.test

  let ownId: JID = "test.user@prose.org"
  let chatId: JID = "test.chat@prose.org"
  let recipientId: JID = "test.recipient@prose.org"

  let date: Date = .ymd(2022, 08, 16)

  let chats = CurrentValueSubject<[JID: ProseCoreTCA.Chat], Never>([:])

  lazy var environment: ConversationEnvironment = {
    var environment = ConversationEnvironment(
      proseClient: .noop,
      pasteboard: .noop,
      mainQueue: self.scheduler.eraseToAnyScheduler()
    )
    environment.proseClient.sendChatState = { chatId, kind in
      XCTAssertEqual(chatId, self.chatId)
      self.participants[self.ownId] = .init(kind: kind, timestamp: self.date)
      return Just(.none).setFailureType(to: EquatableError.self).eraseToEffect()
    }
    environment.proseClient.activeChats = {
      self.chats.setFailureType(to: EquatableError.self).eraseToEffect()
    }
    return environment
  }()

  var participants: [JID: ProseCoreTCA.ChatState] {
    get { self.chats.value[self.chatId]!.participantStates }
    set { self.chats.value[self.chatId]!.participantStates = newValue }
  }

  override func setUp() {
    super.setUp()
    // Cleanup the state
    self.chats.value = [self.chatId: ProseCoreTCA.Chat(jid: self.chatId)]
  }

  func testOwnTypingIndicatorDebounced() throws {
    let store = self.makeTestStore()

    // Open the chat
    store.send(.onAppear)
    store.receive(.typingUsersChanged([]))
    XCTAssertEqual(self.participants, [:])

    // Focus the text field
    store.send(.messageField(.field(.binding(.set(\.$isFocused, true))))) {
      $0.messageField.isFocused = true
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .active, timestamp: self.date),
    ])

    // Write text
    store.send(.messageField(.field(.binding(.set(\.$message, "I write"))))) {
      $0.messageField.message = "I write"
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])

    // Wait for typing timeout
    self.scheduler.advance(by: .pauseTypingDebounceDuration)
    store.receive(.messageField(.setChatState(.paused)))
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .paused, timestamp: self.date),
    ])

    // Write text again
    store.send(.messageField(.field(.binding(.set(\.$message, "I write and I continue"))))) {
      $0.messageField.message = "I write and I continue"
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])

    // Send the message
    store.send(.messageField(.field(.sendButtonTapped)))
    store.receive(.messageField(.field(.send(message: "I write and I continue"))))
    store.receive(.messageSendResult(.success(.none))) {
      $0.messageField.message = ""
    }

    // Focus the text field while it has some text
    store.send(.messageField(.field(.binding(.set(\.$message, "A new message"))))) {
      $0.messageField.message = "A new message"
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])
    store.send(.messageField(.field(.binding(.set(\.$isFocused, false))))) {
      $0.messageField.isFocused = false
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .active, timestamp: self.date),
    ])
    store.send(.messageField(.field(.binding(.set(\.$isFocused, true))))) {
      $0.messageField.isFocused = true
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])

    // Close the chat
    store.send(.messageField(.onDisappear))
    store.send(.onDisappear)
  }

  func testOwnTypingIndicatorFromOtherApp() throws {
    let store = self.makeTestStore()

    // We log into another app
    self.participants[self.ownId] = .init(kind: .active, timestamp: self.date)

    // We start typing in another app
    self.participants[self.ownId] = .init(kind: .composing, timestamp: self.date)

    // We open the chat in this Prose instance
    store.send(.onAppear)
    store.receive(.typingUsersChanged([]))

    // We stop typing in another app
    self.participants[self.ownId] = .init(kind: .paused, timestamp: self.date)
    // No action received `.typingUsersChanged([])` is deduplicated

    // We close the chat in this Prose instance
    store.send(.messageField(.onDisappear))
    store.send(.onDisappear)
  }

  func testRecipientTypingIndicator() throws {
    let store = self.makeTestStore()

    // The recipient logs in
    self.participants[self.recipientId] = .init(kind: .active, timestamp: self.date)

    // The recipient starts typing
    self.participants[self.recipientId] = .init(kind: .composing, timestamp: self.date)

    // Open the chat
    store.send(.onAppear)
    store.receive(.typingUsersChanged([self.recipientId])) {
      $0.typingUsers = [.init(jid: self.recipientId)]
    }

    // The recipient stops typing
    self.participants[self.recipientId] = .init(kind: .paused, timestamp: self.date)
    store.receive(.typingUsersChanged([])) {
      $0.typingUsers = []
    }

    // Close the chat
    store.send(.messageField(.onDisappear))
    store.send(.onDisappear)
  }
}

private extension TypingIndicatorTests {
  func makeTestStore() -> TestStore<
    ChatSessionState<MessageBarState>,
    MessageBarAction,
    ChatSessionState<MessageBarState>,
    MessageBarAction,
    ConversationEnvironment
  > {
    var state = ChatSessionState(
      currentUser: .init(jid: self.ownId),
      chatId: self.chatId,
      userInfos: [:],
      childState: MessageBarState()
    )

    // We're setting the placeholder here manually. Otherwise this would happen later and be
    // detected as a change by the TestStore.
    state.messageField.placeholder =
      L10n.Content.MessageBar.fieldPlaceholder(self.chatId.jidString)

    return TestStore(
      initialState: state,
      reducer: messageBarReducer,
      environment: self.environment
    )
  }
}
