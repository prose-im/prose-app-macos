//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import AppDomain
import AppLocalization
import ComposableArchitecture
@testable import ConversationFeature
import ProseCore
import Toolbox
import XCTest

@MainActor
final class TypingIndicatorTests: XCTestCase {
  func testSendsComposeStateOnlyOnce() async {
    var composingValues = [Bool]()

    let store = Self.makeTestStore(setUserIsComposing: { isComposing in
      composingValues.append(isComposing)
    })

    await store.send(.messageField(.focusChanged(true))) {
      $0.messageField.isFocused = true
    }
    XCTAssertEqual(composingValues, [])

    await store.send(.messageField(.messageChanged("Hello"))) {
      $0.messageField.message = "Hello"
      $0.messageField.isComposing = true
    }
    XCTAssertEqual(composingValues, [true])

    await store.send(.messageField(.messageChanged("Hello World"))) {
      $0.messageField.message = "Hello World"
    }

    await store.send(.onDisappear)
  }

  func testResetsComposeStateAfterClearingTextField() async {
    var composingValues = [Bool]()

    let store = Self.makeTestStore(setUserIsComposing: { isComposing in
      composingValues.append(isComposing)
    })

    await store.send(.messageField(.focusChanged(true))) {
      $0.messageField.isFocused = true
    }
    await store.send(.messageField(.messageChanged("Hello"))) {
      $0.messageField.message = "Hello"
      $0.messageField.isComposing = true
    }

    await store.send(.messageField(.messageChanged(""))) {
      $0.messageField.message = ""
      $0.messageField.isComposing = false
    }
    XCTAssertEqual(composingValues, [true, false])

    await store.send(.onDisappear)
  }

  func testResetsComposeStateAfterLosingFocus() async {
    var composingValues = [Bool]()

    let store = Self.makeTestStore(setUserIsComposing: { isComposing in
      composingValues.append(isComposing)
    })

    await store.send(.messageField(.focusChanged(true))) {
      $0.messageField.isFocused = true
    }
    await store.send(.messageField(.messageChanged("Hello"))) {
      $0.messageField.message = "Hello"
      $0.messageField.isComposing = true
    }

    await store.send(.messageField(.focusChanged(false))) {
      $0.messageField.isFocused = false
      $0.messageField.isComposing = false
    }
    XCTAssertEqual(composingValues, [true, false])

    await store.send(.onDisappear)
  }

  func testSetsComposeStateAfterReceivingFocusWithNonEmptyMessage() async {
    var composingValues = [Bool]()

    let store = Self.makeTestStore(setUserIsComposing: { isComposing in
      composingValues.append(isComposing)
    })

    await store.send(.messageField(.focusChanged(true))) {
      $0.messageField.isFocused = true
    }
    await store.send(.messageField(.messageChanged("Hello"))) {
      $0.messageField.message = "Hello"
      $0.messageField.isComposing = true
    }
    await store.send(.messageField(.focusChanged(false))) {
      $0.messageField.isFocused = false
      $0.messageField.isComposing = false
    }

    await store.send(.messageField(.focusChanged(true))) {
      $0.messageField.isFocused = true
      $0.messageField.isComposing = true
    }
    XCTAssertEqual(composingValues, [true, false, true])

    await store.send(.onDisappear)
  }

  func testResetsComposeStateAfterInactivity() async {
    var composingValues = [Bool]()
    let clock = TestClock()

    let store = Self.makeTestStore(setUserIsComposing: { isComposing in
      composingValues.append(isComposing)
    })
    store.dependencies.continuousClock = clock

    await store.send(.messageField(.focusChanged(true))) {
      $0.messageField.isFocused = true
    }
    await store.send(.messageField(.messageChanged("Hello"))) {
      $0.messageField.message = "Hello"
      $0.messageField.isComposing = true
    }
    XCTAssertEqual(composingValues, [true])

    await clock.advance(by: .composeDelay)

    await store.receive(.messageField(.composeDelayExpired)) {
      $0.messageField.isComposing = false
    }
    XCTAssertEqual(composingValues, [true, false])

    await store.send(.onDisappear)
  }

  func testTypingResetsInactivityDelay() async {
    var composingValues = [Bool]()
    let clock = TestClock()

    let store = Self.makeTestStore(setUserIsComposing: { isComposing in
      composingValues.append(isComposing)
    })
    store.dependencies.continuousClock = clock

    await store.send(.messageField(.focusChanged(true))) {
      $0.messageField.isFocused = true
    }
    await store.send(.messageField(.messageChanged("Hello"))) {
      $0.messageField.message = "Hello"
      $0.messageField.isComposing = true
    }
    XCTAssertEqual(composingValues, [true])

    await clock.advance(by: .composeDelay / 3 * 2)

    await store.send(.messageField(.messageChanged("Hello World"))) {
      $0.messageField.message = "Hello World"
    }

    // Since 2/3 + 1/2 > 1 this is proof that the delay is interrupted
    await clock.advance(by: .composeDelay / 2)

    XCTAssertEqual(composingValues, [true])

    await store.send(.onDisappear)
  }
}

private extension TypingIndicatorTests {
  static func makeTestStore(setUserIsComposing: @escaping (Bool) -> Void) -> some TestStore<
    MessageBarReducer.State,
    MessageBarReducer.Action,
    MessageBarReducer.State,
    MessageBarReducer.Action,
    Void
  > {
    var coreClient = ProseCoreClient.noop
    coreClient.setUserIsComposing = { conversation, isComposing in
      XCTAssertEqual(conversation, .johnDoe)
      setUserIsComposing(isComposing)
    }

    var accountsClient = AccountsClient.testValue
    accountsClient.client = { jid in
      XCTAssertEqual(jid, .janeDoe)
      return coreClient
    }

    return TestStore(
      initialState: .mock(
        selectedAccountId: .janeDoe,
        chatId: .johnDoe,
        userInfos: [.johnDoe: .johnDoe],
        .init()
      ),
      reducer: MessageBarReducer(),
      prepareDependencies: {
        $0.accountsClient = accountsClient
        $0.continuousClock = ContinuousClock()
      }
    )
  }
}
