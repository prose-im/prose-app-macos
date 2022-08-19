//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import ComposableArchitecture
@testable import ConversationFeature
import ProseCoreTCA
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
    let store = TestStore(
      initialState: MessageBarState(
        chatId: self.chatId,
        loggedInUserJID: self.ownId,
        chatName: .jid(self.chatId)
      ),
      reducer: messageBarReducer,
      environment: self.environment
    )

    // Open the chat
    store.send(.onAppear)
    store.receive(.typingUsersChanged([]))
    XCTAssertEqual(self.participants, [:])

    // Focus the text field
    store.send(.textField(.binding(.set(\.$isFocused, true)))) {
      $0.textField.isFocused = true
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .active, timestamp: self.date),
    ])

    // Write text
    store.send(.textField(.binding(.set(\.$message, "I write")))) {
      $0.textField.message = "I write"
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])

    // Wait for typing timeout
    self.scheduler.advance(by: .pauseTypingDebounceDuration)
    store.receive(.textField(.setChatState(.paused)))
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .paused, timestamp: self.date),
    ])

    // Write text again
    store.send(.textField(.binding(.set(\.$message, "I write and I continue")))) {
      $0.textField.message = "I write and I continue"
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])

    // Send the message
    store.send(.textField(.sendTapped)) {
      $0.textField.message = ""
    }
    store.receive(.textField(.send(message: "I write and I continue")))

    // Focus the text field while it has some text
    store.send(.textField(.binding(.set(\.$message, "A new message")))) {
      $0.textField.message = "A new message"
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])
    store.send(.textField(.binding(.set(\.$isFocused, false)))) {
      $0.textField.isFocused = false
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .active, timestamp: self.date),
    ])
    store.send(.textField(.binding(.set(\.$isFocused, true)))) {
      $0.textField.isFocused = true
    }
    XCTAssertEqual(self.participants, [
      self.ownId: .init(kind: .composing, timestamp: self.date),
    ])

    // Close the chat
    store.send(.textField(.onDisappear))
    store.send(.onDisappear)
  }

  func testOwnTypingIndicatorFromOtherApp() throws {
    let store = TestStore(
      initialState: MessageBarState(
        chatId: self.chatId,
        loggedInUserJID: self.ownId,
        chatName: .jid(self.chatId)
      ),
      reducer: messageBarReducer,
      environment: self.environment
    )

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
    store.send(.textField(.onDisappear))
    store.send(.onDisappear)
  }

  func testRecipientTypingIndicatorDebounced() throws {
    let store = TestStore(
      initialState: MessageBarState(
        chatId: self.chatId,
        loggedInUserJID: self.ownId,
        chatName: .jid(self.chatId)
      ),
      reducer: messageBarReducer,
      environment: self.environment
    )

    // The recipient logs in
    self.participants[self.recipientId] = .init(kind: .active, timestamp: self.date)

    // The recipient starts typing
    self.participants[self.recipientId] = .init(kind: .composing, timestamp: self.date)

    // Open the chat
    store.send(.onAppear)
    store.receive(.typingUsersChanged([.jid(self.recipientId)])) {
      $0.typingUsers = [.jid(self.recipientId)]
    }

    // The recipient stops typing
    self.participants[self.recipientId] = .init(kind: .paused, timestamp: self.date)
    store.receive(.typingUsersChanged([])) {
      $0.typingUsers = []
    }

    // Close the chat
    store.send(.textField(.onDisappear))
    store.send(.onDisappear)
  }
}
