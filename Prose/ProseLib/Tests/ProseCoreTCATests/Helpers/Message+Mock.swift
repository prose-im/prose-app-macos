import Foundation
import ProseCoreClientFFI
import ProseCoreTCA

extension ProseCoreClientFFI.Message {
  static func mock(
      from: BareJid = .init(node: "jane.doe", domain: "prose.org"),
      to: BareJid? = nil,
      id: String? = "message-id",
      kind: ProseCoreClientFFI.MessageKind? = nil,
      body: String? = "Empty Message",
      chatState: ChatState? = nil,
      replace: String? = nil,
      error: String? = nil
  ) -> Self {
      .init(
          from: from,
          to: to,
          id: id,
          kind: kind,
          body: body,
          chatState: chatState,
          replace: replace,
          error: error
      )
  }
}

extension ProseCoreTCA.Message {
  static func mock(
      from: JID = "jane.doe@prose.org",
      id: String = "message-id",
      kind: ProseCoreTCA.MessageKind? = nil,
      body: String = "Empty Message",
      timestamp: Date = .init(),
      isRead: Bool = false
  ) -> Self {
      .init(
          from: from,
          id: .serverAssigned(id),
          kind: kind,
          body: body,
          timestamp: timestamp,
          isRead: isRead
      )
  }
}
