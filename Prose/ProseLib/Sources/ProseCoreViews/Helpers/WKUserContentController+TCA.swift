//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import ComposableArchitecture
import Foundation
import Toolbox
import WebKit

public extension WKUserContentController {
  func addMessageEventHandler<T: Decodable>(
    for event: MessageEvent.Kind,
    handler: @escaping (Result<T, JSEventError>) -> Void
  ) {
    let (script, handlerName) = MessagingEventScript.on(event)

    let scriptMessageHandler = ScriptMessageHandler<T> { message in
      handler(decodeJSEventPayload(message))
    }

    self.add(scriptMessageHandler, name: handlerName)
    self.addUserScript(
      WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    )
  }
}

private final class ScriptMessageHandler<T>: NSObject, WKScriptMessageHandler {
  let handler: (Any) -> Void

  init(handler: @escaping (Any) -> Void) {
    self.handler = handler
    super.init()
  }

  func userContentController(
    _: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    self.handler(message.body)
  }
}

private enum MessagingEventScript {
  static func on(_ event: MessageEvent.Kind) -> (script: String, handlerName: String) {
    let handlerName = "handler_" + event.rawValue.replacingOccurrences(of: ":", with: "_")

    let script = """
    function \(handlerName)(content) {
      window.webkit.messageHandlers.\(handlerName).postMessage(JSON.stringify(content));
    }
    MessagingEvent.on("\(event.rawValue)", \(handlerName));
    """

    return (script: script, handlerName: handlerName)
  }
}

private func decodeJSEventPayload<T: Decodable>(_ message: Any) -> Result<T, JSEventError> {
  guard
    let bodyString: String = message as? String,
    let bodyData: Data = bodyString.data(using: .utf8)
  else {
    logger.fault("JS message body should be serialized as a String")
    return .failure(.badSerialization)
  }

  do {
    let payload = try JSONDecoder().decode(T.self, from: bodyData)
    return .success(payload)
  } catch let error as DecodingError {
    logger
      .warning("JS message body could not be decoded as `Payload`. Content: \(bodyString)")
    return .failure(
      .decodingError(
        "JS message body could not be decoded from \"\(bodyString)\": \(error.debugDescription)"
      )
    )
  } catch {
    fatalError("`error` should always be a `DecodingError`")
  }
}
