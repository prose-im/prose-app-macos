//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import Foundation
import IdentifiedCollections
import ProseCore
import ProseCoreClientFFI
import ProseCoreTCA
import TestHelpers
import XCTest

final class ProseClientTests: XCTestCase {
  func testGroupsMessagesInChatsWhenReceiving() throws {
    let date = Date.ymd(2022, 6, 25)
    let (client, mock) = try self.connectedClient(date: { date })

    let chat1Messages = TestSink<IdentifiedArrayOf<Message>>()
    let chat2Messages = TestSink<IdentifiedArrayOf<Message>>()
    var c = Set<AnyCancellable>()

    client.messagesInChat("chat1@prose.org").collectInto(sink: chat1Messages).store(in: &c)
    client.messagesInChat("chat2@prose.org").collectInto(sink: chat2Messages).store(in: &c)

    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat1@prose.org", id: "1"))
    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat2@prose.org", id: "2"))
    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat2@prose.org", id: "3"))

    XCTAssertEqual(
      chat1Messages.values, [
        [],
        [.mock(from: "chat1@prose.org", id: "1", timestamp: date)],
      ]
    )
    XCTAssertEqual(
      chat2Messages.values, [
        [],
        [.mock(from: "chat2@prose.org", id: "2", timestamp: date)],
        [
          .mock(from: "chat2@prose.org", id: "2", timestamp: date),
          .mock(from: "chat2@prose.org", id: "3", timestamp: date),
        ],
      ]
    )
  }

  func testGroupsMessagesInChatsWhenSending() throws {
    let date = Date.ymd(2022, 6, 25)
    let (client, _) = try self.connectedClient(date: { date })

    let chat1Messages = TestSink<IdentifiedArrayOf<Message>>()
    let chat2Messages = TestSink<IdentifiedArrayOf<Message>>()
    var c = Set<AnyCancellable>()

    client.messagesInChat("chat1@prose.org").collectInto(sink: chat1Messages).store(in: &c)
    client.messagesInChat("chat2@prose.org").collectInto(sink: chat2Messages).store(in: &c)

    try self.await(client.sendMessage("chat1@prose.org", "message 1"))
    try self.await(client.sendMessage("chat2@prose.org", "message 2"))
    try self.await(client.sendMessage("chat1@prose.org", "message 3"))

    XCTAssertEqual(
      chat1Messages.values, [
        [],
        [.mock(
          from: "marc@prose.org",
          id: "00000000-0000-0000-0000-000000000000",
          kind: .chat,
          body: "message 1",
          timestamp: date,
          isRead: true
        )],
        [
          .mock(
            from: "marc@prose.org",
            id: "00000000-0000-0000-0000-000000000000",
            kind: .chat,
            body: "message 1",
            timestamp: date,
            isRead: true
          ),
          .mock(
            from: "marc@prose.org",
            id: "00000000-0000-0000-0000-000000000002",
            kind: .chat,
            body: "message 3",
            timestamp: date,
            isRead: true
          ),
        ],
      ]
    )
    XCTAssertEqual(
      chat2Messages.values, [
        [],
        [.mock(
          from: "marc@prose.org",
          id: "00000000-0000-0000-0000-000000000001",
          kind: .chat,
          body: "message 2",
          timestamp: date,
          isRead: true
        )],
      ]
    )
  }

  func testUpdatesChatStates() throws {
    let date = Date.ymd(2022, 6, 25)
    let (client, mock) = try self.connectedClient(date: { date })

    let chatStates = TestSink<[JID: [JID: ChatState]]>()
    var c = Set<AnyCancellable>()

    client.activeChats().map { chats in
      chats.mapValues(\.participantStates)
    }
    .collectInto(sink: chatStates)
    .store(in: &c)

    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(from: "chat1@prose.org", body: nil, chatState: .composing)
    )
    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(from: "chat2@prose.org", body: nil, chatState: .active)
    )
    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(from: "chat1@prose.org", body: nil, chatState: .paused)
    )

    XCTAssertEqual(
      chatStates.values,
      [
        [:],
        ["chat1@prose.org": ["chat1@prose.org": .init(kind: .composing, timestamp: date)]],
        [
          "chat1@prose.org": ["chat1@prose.org": .init(
            kind: .composing,
            timestamp: date
          )],
          "chat2@prose.org": ["chat2@prose.org": .init(kind: .active, timestamp: date)],
        ],
        [
          "chat1@prose.org": ["chat1@prose.org": .init(kind: .paused, timestamp: date)],
          "chat2@prose.org": ["chat2@prose.org": .init(kind: .active, timestamp: date)],
        ],
      ]
    )
  }

  func testUpdatesPresence() throws {
    let date = Date.ymd(2022, 6, 25)
    let (client, mock) = try self.connectedClient(date: { date })

    let presences = TestSink<[JID: Presence]>()
    var c = Set<AnyCancellable>()

    client.presence().collectInto(sink: presences).store(in: &c)

    mock.delegate.proseClient(
      mock,
      didReceivePresence: .mock(from: "chat1@prose.org", show: .dnd)
    )
    mock.delegate.proseClient(
      mock,
      didReceivePresence: .mock(from: "chat2@prose.org", show: .away)
    )
    mock.delegate.proseClient(
      mock,
      didReceivePresence: .mock(from: "chat1@prose.org", show: .xa)
    )

    XCTAssertEqual(
      presences.values,
      [
        [:],
        ["chat1@prose.org": .mock(show: .dnd, timestamp: date)],
        [
          "chat1@prose.org": .mock(show: .dnd, timestamp: date),
          "chat2@prose.org": .mock(show: .away, timestamp: date),
        ],
        [
          "chat1@prose.org": .mock(show: .xa, timestamp: date),
          "chat2@prose.org": .mock(show: .away, timestamp: date),
        ],
      ]
    )
  }

  func testUpdatesMessageWhenSending() throws {
    let date = Date.ymd(2022, 6, 25)
    let (client, _) = try self.connectedClient(date: { date })

    let chat1Messages = TestSink<IdentifiedArrayOf<Message>>()
    var c = Set<AnyCancellable>()

    try self.await(client.sendMessage("chat1@prose.org", "message 1"))
    try self.await(client.sendMessage("chat1@prose.org", "message 2"))

    client.messagesInChat("chat1@prose.org").collectInto(sink: chat1Messages).store(in: &c)

    try self.await(
      client.updateMessage(
        "chat1@prose.org",
        "00000000-0000-0000-0000-000000000001",
        "updated message 2"
      )
    )

    XCTAssertEqual(
      chat1Messages.values, [
        [
          .mock(
            from: "marc@prose.org",
            id: "00000000-0000-0000-0000-000000000000",
            kind: .chat,
            body: "message 1",
            timestamp: date,
            isRead: true
          ),
          .mock(
            from: "marc@prose.org",
            id: "00000000-0000-0000-0000-000000000001",
            kind: .chat,
            body: "message 2",
            timestamp: date,
            isRead: true
          ),
        ],
        [
          .mock(
            from: "marc@prose.org",
            id: "00000000-0000-0000-0000-000000000000",
            kind: .chat,
            body: "message 1",
            timestamp: date,
            isRead: true
          ),
          .mock(
            from: "marc@prose.org",
            id: "00000000-0000-0000-0000-000000000002",
            kind: .chat,
            body: "updated message 2",
            timestamp: date,
            isRead: true,
            isEdited: true
          ),
        ],
      ]
    )
  }

  func testUpdatesMessageWhenReceiving() throws {
    let date = Date.ymd(2022, 6, 25)
    let (client, mock) = try self.connectedClient(date: { date })

    let chat1Messages = TestSink<IdentifiedArrayOf<Message>>()
    var c = Set<AnyCancellable>()

    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat1@prose.org", id: "1"))
    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat1@prose.org", id: "2"))

    client.messagesInChat("chat1@prose.org").collectInto(sink: chat1Messages).store(in: &c)

    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(
        from: "chat1@prose.org",
        id: "3",
        body: "Updated message",
        replace: "2"
      )
    )

    XCTAssertEqual(
      chat1Messages.values, [
        [
          .mock(from: "chat1@prose.org", id: "1", timestamp: date),
          .mock(from: "chat1@prose.org", id: "2", timestamp: date),
        ],
        [
          .mock(from: "chat1@prose.org", id: "1", timestamp: date),
          .mock(
            from: "chat1@prose.org",
            id: "3",
            body: "Updated message",
            timestamp: date,
            isEdited: true
          ),
        ],
      ]
    )
  }

  func testUpdatesUnreadCounts() throws {
    let date = Date.ymd(2022, 6, 25)
    let (client, mock) = try self.connectedClient(date: { date })

    let unreadCounts = TestSink<[JID: Int]>()
    var c = Set<AnyCancellable>()

    client.activeChats().map { chats in
      chats.mapValues(\.numberOfUnreadMessages)
    }.collectInto(sink: unreadCounts).store(in: &c)

    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat1@prose.org", id: "1"))
    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat2@prose.org", id: "2"))
    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat2@prose.org", id: "3"))

    try self.await(client.markMessagesReadInChat("chat2@prose.org"))

    mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat2@prose.org", id: "4"))

    XCTAssertEqual(
      unreadCounts.values, [
        [:],
        ["chat1@prose.org": 1],
        [
          "chat1@prose.org": 1,
          "chat2@prose.org": 1,
        ],
        [
          "chat1@prose.org": 1,
          "chat2@prose.org": 2,
        ],
        [
          "chat1@prose.org": 1,
          "chat2@prose.org": 0,
        ],
        [
          "chat1@prose.org": 1,
          "chat2@prose.org": 1,
        ],
      ]
    )
  }

  func testSendsReactions() throws {
    let (client, mock) = try self.connectedClient()

    struct SentReactions: Equatable {
      var reactions: Set<String>
      var jid: BareJid
      var messageId: MessageId
    }

    var sentReactions = [SentReactions]()

    mock.impl.sendReactions = { reactions, jid, messageId in
      sentReactions.append(.init(reactions: reactions, jid: jid, messageId: messageId))
    }

    try self.await(client.sendMessage("chat1@prose.org", ""))

    try self.await(
      client.addReaction("chat1@prose.org", "00000000-0000-0000-0000-000000000000", "❤️")
    )
    try self.await(
      client.addReaction("chat1@prose.org", "00000000-0000-0000-0000-000000000000", "🤷‍♂️")
    )
    try self.await(
      client.addReaction("chat1@prose.org", "00000000-0000-0000-0000-000000000000", "🫠")
    )
    try self.await(
      client.addReaction("chat1@prose.org", "00000000-0000-0000-0000-000000000000", "🫠")
    )
    try self.await(
      client.toggleReaction("chat1@prose.org", "00000000-0000-0000-0000-000000000000", "🤷‍♂️")
    )

    XCTAssertEqual(
      sentReactions, [
        .init(
          reactions: ["❤️"],
          jid: "chat1@prose.org",
          messageId: "00000000-0000-0000-0000-000000000000"
        ),
        .init(
          reactions: ["❤️", "🤷‍♂️"],
          jid: "chat1@prose.org",
          messageId: "00000000-0000-0000-0000-000000000000"
        ),
        .init(
          reactions: ["❤️", "🤷‍♂️", "🫠"],
          jid: "chat1@prose.org",
          messageId: "00000000-0000-0000-0000-000000000000"
        ),
        .init(
          reactions: ["❤️", "🫠"],
          jid: "chat1@prose.org",
          messageId: "00000000-0000-0000-0000-000000000000"
        ),
      ]
    )
  }

  func testUpdatesReactions() throws {
    let date = Date.ymd(2022, 8, 4)
    let (client, mock) = try self.connectedClient(date: { date })

    let chat1Reactions = TestSink<[Message.ID: MessageReactions]>()
    var c = Set<AnyCancellable>()

    client.messagesInChat("chat1@prose.org")
      .map { messages in
        Dictionary(uniqueKeysWithValues: zip(messages.ids, messages.map(\.reactions)))
      }
      .removeDuplicates()
      .collectInto(sink: chat1Reactions)
      .store(in: &c)

    try self.await(client.sendMessage("chat1@prose.org", ""))
    try self.await(client.sendMessage("chat2@prose.org", ""))

    try self.await(
      client.addReaction("chat1@prose.org", "00000000-0000-0000-0000-000000000000", "❤️")
    )
    try self.await(
      client.addReaction("chat2@prose.org", "00000000-0000-0000-0000-000000000001", "🤷‍♂️")
    )

    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(from: "chat1@prose.org", id: "1")
    )
    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(from: "chat2@prose.org", id: "1")
    )

    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(
        from: "chat1@prose.org",
        id: "2",
        body: nil,
        reactions: .init(id: "1", reactions: ["🎂", "🐇"])
      )
    )
    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(
        from: "chat2@prose.org",
        id: "2",
        body: nil,
        reactions: .init(id: "1", reactions: ["👻"])
      )
    )
    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(
        from: "chat1@prose.org",
        id: "3",
        body: nil,
        reactions: .init(id: "1", reactions: ["🍻", "🐇"])
      )
    )

    XCTAssertEqual(
      chat1Reactions.values, [
        [:],
        ["00000000-0000-0000-0000-000000000000": [:]],
        ["00000000-0000-0000-0000-000000000000": ["❤️": ["marc@prose.org"]]],
        [
          "00000000-0000-0000-0000-000000000000": ["❤️": ["marc@prose.org"]],
          "1": [:],
        ],
        [
          "00000000-0000-0000-0000-000000000000": ["❤️": ["marc@prose.org"]],
          "1": ["🎂": ["chat1@prose.org"], "🐇": ["chat1@prose.org"]],
        ],
        [
          "00000000-0000-0000-0000-000000000000": ["❤️": ["marc@prose.org"]],
          "1": ["🐇": ["chat1@prose.org"], "🍻": ["chat1@prose.org"]],
        ],
      ]
    )
  }

  func testRetractsMessage() throws {
    let (client, mock) = try self.connectedClient()

    struct RetractedMessage: Equatable {
      var jid: BareJid
      var messageId: MessageId
    }

    let chat1MessageIDs = TestSink<[Message.ID]>()
    let chat1UnreadMessages = TestSink<Int>()
    var retractedMessages = [RetractedMessage]()
    var c = Set<AnyCancellable>()

    client.messagesInChat("chat1@prose.org")
      .map { messages in messages.map(\.id) }
      .removeDuplicates()
      .collectInto(sink: chat1MessageIDs)
      .store(in: &c)

    client.activeChats()
      .map { chats in chats["chat1@prose.org"]?.numberOfUnreadMessages ?? -1 }
      .removeDuplicates()
      .collectInto(sink: chat1UnreadMessages)
      .store(in: &c)

    mock.impl.retractMessage = { jid, messageId in
      retractedMessages.append(.init(jid: jid, messageId: messageId))
    }

    try self.await(client.sendMessage("chat1@prose.org", ""))
    try self.await(client.sendMessage("chat1@prose.org", ""))

    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(from: "chat1@prose.org", id: "1")
    )
    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(from: "chat1@prose.org", id: "2")
    )

    try self.await(client.retractMessage("chat1@prose.org", "00000000-0000-0000-0000-000000000001"))

    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(
        from: "chat1@prose.org",
        id: "3",
        body: "Fallback message",
        fastening: .init(id: "1", retract: true)
      )
    )
    mock.delegate.proseClient(
      mock,
      didReceiveMessage: .mock(
        from: "chat1@prose.org",
        id: "4",
        body: nil,
        fastening: .init(id: "does-not-exist", retract: true)
      )
    )

    XCTAssertEqual(
      chat1UnreadMessages.values,
      [
        -1,
        0,
        1,
        2,
        1,
      ]
    )

    XCTAssertEqual(
      chat1MessageIDs.values,
      [
        [],
        ["00000000-0000-0000-0000-000000000000"],
        ["00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000001"],
        ["00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000001", "1"],
        ["00000000-0000-0000-0000-000000000000", "00000000-0000-0000-0000-000000000001", "1", "2"],
        ["00000000-0000-0000-0000-000000000000", "1", "2"],
        ["00000000-0000-0000-0000-000000000000", "2"],
      ]
    )

    XCTAssertEqual(
      retractedMessages,
      [.init(jid: "chat1@prose.org", messageId: "00000000-0000-0000-0000-000000000001")]
    )
  }
}

private extension ProseClientTests {
  func connectedClient(
    date: @escaping () -> Date = Date.init,
    uuid: @escaping () -> UUID = UUID.incrementing,
    file: StaticString = #file,
    line: UInt = #line
  ) throws -> (ProseCoreTCA.ProseClient, ProseMockClient) {
    var mockClient: ProseMockClient?

    let client = ProseClient.live(provider: ProseMockClient.provider { _mockClient in
      mockClient = _mockClient
      _mockClient.impl.connect = { _ in
        _mockClient.delegate.proseClientDidConnect(_mockClient)
      }
    }, date: date, uuid: uuid)

    try self.await(
      client.login("marc@prose.org", "topsecret").prefix(1),
      file: file,
      line: line
    )
    return try (client, XCTUnwrap(mockClient, file: file, line: line))
  }
}
