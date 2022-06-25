import Foundation
import XCTest
import ProseCoreTCA
import ProseCore
import TestHelpers
import Combine

final class ProseClientTests: XCTestCase {
    func testGroupsMessagesInChats() throws {
        let date = Date.ymd(2022, 6, 25)
        let (client, mock) = try self.connectedClient(date: { date })
        
        var chat1Messages = [[Message]]()
        var chat2Messages = [[Message]]()
        var c = Set<AnyCancellable>()
        
        client.messagesInChat("chat1@prose.org").sink(receiveValue: { messages in
            chat1Messages.append(messages)
        }).store(in: &c)
        
        client.messagesInChat("chat2@prose.org").sink(receiveValue: { messages in
            chat2Messages.append(messages)
        }).store(in: &c)
        
        mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat1@prose.org", id: "1"))
        mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat2@prose.org", id: "2"))
        mock.delegate.proseClient(mock, didReceiveMessage: .mock(from: "chat2@prose.org", id: "3"))
        
        XCTAssertEqual(
          chat1Messages, [
            [],
            [.mock(from: "chat1@prose.org", id: "1", timestamp: date)],
          ]
        )
        XCTAssertEqual(
          chat2Messages, [
            [],
            [.mock(from: "chat2@prose.org", id: "2", timestamp: date)],
            [
                .mock(from: "chat2@prose.org", id: "2", timestamp: date),
                .mock(from: "chat2@prose.org", id: "3", timestamp: date),
            ]
          ]
        )
    }
}

private extension ProseClientTests {
  func connectedClient(
      date: @escaping () -> Date = Date.init,
      file: StaticString = #file,
      line: UInt = #line
  ) throws -> (ProseCoreTCA.ProseClient, ProseMockClient) {
        var mockClient: ProseMockClient?
        
        let client = ProseClient.live(provider: ProseMockClient.provider { _mockClient in
            mockClient = _mockClient
            _mockClient.impl.connect = { _ in
                  _mockClient.delegate.proseClientDidConnect(_mockClient)
            }
        }, date: date)
        
        try self.await(
            client.login("marc@prose.org", "topsecret").prefix(1),
            file: file,
            line: line
        )
        return try (client, XCTUnwrap(mockClient, file: file, line: line))
  }
}
