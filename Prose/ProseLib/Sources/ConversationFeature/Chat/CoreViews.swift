//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import typealias IdentifiedCollections.IdentifiedArrayOf
import ProseCoreTCA
import enum SwiftUI.ColorScheme
import WebKit.WKWebView

// MARK: - JavaScriptEvaluator

struct JavaScriptEvaluator {
  let _evaluateJavaScript: (
    _ script: String,
    _ domain: StaticString,
    _ printResult: Bool
  ) -> Void

  func evaluateJavaScript(
    _ script: String,
    domain: StaticString,
    debugLog: Bool = false,
    printResult: Bool = false
  ) {
    if debugLog {
      logger.debug("Evaluating `\(script)`…")
    }
    self._evaluateJavaScript(script, domain, printResult)
  }
}

extension JavaScriptEvaluator {
  static var noop: Self {
    JavaScriptEvaluator(
      _evaluateJavaScript: { _, _, _ in () }
    )
  }
}

extension JavaScriptEvaluator {
  static func live(webView: WKWebView) -> Self {
    JavaScriptEvaluator(
      _evaluateJavaScript: { [weak webView] script, domain, printResult in
        webView?.evaluateJavaScript(script) { res, error in
          if printResult, let res = res {
            logger.debug("[\(domain)] JavaScript response: \(String(reflecting: res))")
          }
          if let error: NSError = error as? NSError {
            logger
              .warning(
                "[\(domain)] Error evaluating JavaScript: \(error.javaScriptExceptionMessage)"
              )
          }
        }
      }
    )
  }
}

private extension NSError {
  var javaScriptExceptionMessage: String {
    (self.userInfo["WKJavaScriptExceptionMessage"] as? String) ?? self.localizedDescription
  }
}

// MARK: - JSON conversions

func json<T: Encodable & Collection>(_ array: T) -> String {
  let jsonData: Data
  do {
    jsonData = try JSONEncoder().encode(array)
  } catch {
    return "[]"
  }
  return String(data: jsonData, encoding: .utf8) ?? "[]"
}

/// - Note: This method is named unsafe because it uses `fatalError`.
///         The object is escaped properly.
func unsafeJson<T: Encodable>(_ object: T) -> String {
  let jsonData: Data
  do {
    jsonData = try JSONEncoder().encode(object)
  } catch {
    fatalError("\(object) could not be encoded to JSON")
  }
  guard let json = String(data: jsonData, encoding: .utf8) else {
    fatalError("\(object) could not be converted to String")
  }
  return json
}

// MARK: - MessagingStore

struct MessagingStore {
  let signpostID = signposter.makeSignpostID()

  var evaluator: JavaScriptEvaluator

  func updateMessages(
    to messages: [ProseCoreViewsMessage],
    oldMessages: inout IdentifiedArrayOf<ProseCoreViewsMessage>
  ) {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    let messages = IdentifiedArrayOf<ProseCoreViewsMessage>(uniqueElements: messages)
    defer { oldMessages = messages }

    let diff = messages.difference(from: oldMessages)

    for messageId in diff.removedIds {
      self.retractMessage(withId: messageId)
    }
    for messageId in diff.updatedIds {
      if let message = messages[id: messageId] {
        self.updateMessage(to: message)
      }
    }
    self.insertMessages(diff.insertedIds.compactMap { messages[id: $0] })

    signposter.endInterval(#function, interval)
  }

  func insertMessages(_ messages: [ProseCoreViewsMessage]) {
    guard !messages.isEmpty else { return }
    logger.trace("Inserting \(messages.count, privacy: .public) message(s)…")

    let script = """
    MessagingStore.insert(...\(json(messages)));
    """
    self.evaluator.evaluateJavaScript(script, domain: "Insert messages")
  }

  func updateMessage(to message: ProseCoreViewsMessage) {
    logger.trace("Updating 1 message…")

    let script = """
    MessagingStore.update(\(unsafeJson(message.id)), \(unsafeJson(message)));
    """
    self.evaluator.evaluateJavaScript(script, domain: "Update message")
  }

  func retractMessage(withId messageId: ProseCoreViewsMessage.ID) {
    logger.trace("Retracting 1 message…")

    let script = """
    MessagingStore.retract(\(unsafeJson(messageId)));
    """
    self.evaluator.evaluateJavaScript(script, domain: "Retract message")
  }

  func highlightMessage(_ messageId: Message.ID?) {
    logger.trace("Highlighting message \(messageId ?? "nil", privacy: .public)…")

    let jsonData: Data = try! JSONEncoder().encode(messageId)
    let json = String(data: jsonData, encoding: .utf8) ?? "null"
    let script = """
    MessagingStore.highlight(\(json));
    """
    self.evaluator.evaluateJavaScript(script, domain: "Highlight message")
  }

  func lockAction(
    _ action: ProseCoreViewsMessageAction,
    of messageId: Message.ID,
    isLocked: Bool
  ) {
    let script = """
    MessagingStore.interact(\(unsafeJson(messageId)), \(unsafeJson(action)), \(unsafeJson(isLocked)));
    """
    self.evaluator.evaluateJavaScript(script, domain: "Lock/unlock action")
  }
}

// MARK: - MessagingContext

struct MessagingContext {
  var evaluator: JavaScriptEvaluator

  static func setAccountJIDScript(jid loggedInUserJID: JID) -> String {
    let jsonData: Data = try! JSONEncoder().encode(loggedInUserJID.jidString)
    let json = String(data: jsonData, encoding: .utf8) ?? "''"
    let script = """
    MessagingContext.setAccountJID(\(json));
    """
    return script
  }

  func updateColorScheme(to colorScheme: ColorScheme) {
    let theme: String? = {
      switch colorScheme {
      case .light:
        return "light"
      case .dark:
        return "dark"
      @unknown default:
        return nil
      }
    }()
    if let theme: String = theme {
      let jsonData: Data = try! JSONEncoder().encode(theme)
      let json = String(data: jsonData, encoding: .utf8) ?? "''"
      let script = """
      MessagingContext.setStyleTheme(\(json));
      """
      self.evaluator.evaluateJavaScript(script, domain: "Color scheme")
    }
  }
}

// MARK: - MessagingEvent

struct MessagingEvent {
  static func on(_ event: String) -> (script: String, handlerName: String) {
    let handlerName = "handler_" + event.replacingOccurrences(of: ":", with: "_")

    let script = """
    function \(handlerName)(content) {
      // We need to send a parameter, or the call will not be forwarded to the `WKScriptMessageHandler`
      window.webkit.messageHandlers.\(handlerName).postMessage(JSON.stringify(content));
    }
    MessagingEvent.on("\(event)", \(handlerName));
    """

    return (script: script, handlerName: handlerName)
  }
}
