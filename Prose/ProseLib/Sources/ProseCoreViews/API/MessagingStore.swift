//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import IdentifiedCollections
import ProseCoreTCA

public struct MessagingStore {
  private let signpostID = signposter.makeSignpostID()

  public let insertMessages: JSRestFunc1<[Message], Void>
  public let retractMessage: JSFunc1<Message.ID, Void>
  public let highlightMessage: JSFunc1<Message.ID?, Void>
  public let interact: JSFunc3<MessageAction, Message.ID, Bool, Void>

  private let update: JSFunc2<Message.ID, Message, Void>

  init(evaluator: @escaping JSEvaluator) {
    let cls = JSClass(name: "MessagingStore", evaluator: evaluator)
    self.insertMessages = cls.insert
    self.update = cls.update
    self.retractMessage = cls.retract
    self.highlightMessage = cls.highlight
    self.interact = cls.interact
  }

  public func updateMessages(
    to messages: [Message],
    oldMessages: inout IdentifiedArrayOf<Message>
  ) {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    let messages = IdentifiedArrayOf<Message>(uniqueElements: messages)
    defer { oldMessages = messages }

    let diff = messages.difference(from: oldMessages)

    for messageId in diff.removedIds {
      self.retractMessage(messageId)
    }
    for messageId in diff.updatedIds {
      if let message = messages[id: messageId] {
        self.updateMessage(message)
      }
    }
    self.insertMessages(diff.insertedIds.compactMap { messages[id: $0] })

    signposter.endInterval(#function, interval)
  }

  public func updateMessage(_ message: Message) {
    self.update(message.id, message)
  }
}
