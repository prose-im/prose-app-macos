//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import Combine
import ComposableArchitecture
import IdentifiedCollections
import OSLog
import ProseCoreTCA
import ProseUI
import SwiftUI
import WebKit

// MARK: - View

struct ProseCoreViewsMessage: Equatable, Encodable {
  struct User: Equatable, Encodable {
    let jid: String
    let name: String
  }

  fileprivate static var dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions.insert(.withFractionalSeconds)
    return formatter
  }()

  let id: Message.ID
  let type = "text"
  let date: String
  let content: String
  let from: User
  let reactions: MessageReactions

  init(from message: Message) {
    self.id = message.id
    self.date = Self.dateFormatter.string(from: message.timestamp)
    self.content = message.body
    self.from = User(
      jid: message.from.jidString,
      name: message.from.jidString
    )
    self.reactions = message.reactions
  }
}

struct Chat: View {
  let store: Store<ChatView.State, ChatView.Action>
  @ObservedObject var viewStore: ViewStore<ChatView.State, ChatView.Action>

  init(store: Store<ChatView.State, ChatView.Action>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    ChatView(store: self.store)
      .onKeyDown { key in
        switch key {
        case .up:
          self.viewStore.send(.navigateUp)
        case .down:
          self.viewStore.send(.navigateDown)
        default:
          break
        }
      }
  }
}

struct ChatView: NSViewRepresentable {
  typealias State = ChatState
  typealias Action = ChatAction

  final class Coordinator: NSObject {
    var cancellables = Set<AnyCancellable>()

    let viewStore: ViewStore<Void, Action>

    #if os(macOS)
      var menu: MessageMenu?
    #endif

    init(viewStore: ViewStore<Void, Action>) {
      self.viewStore = viewStore
    }
  }

  let store: Store<State, Action>
  let viewStore: ViewStore<State, Action>

  let signpostID = signposter.makeSignpostID()

  init(store: Store<State, Action>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  func makeCoordinator() -> Coordinator { Coordinator(viewStore: ViewStore(self.store.stateless)) }

  func makeNSView(context: Context) -> WKWebView {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    let contentController = WKUserContentController()

    // Set logged in user JID
    contentController.addUserScript(self.setAccountJIDScript)

    let actions = ViewStore(self.store.scope(state: { _ in () }, action: Action.message))
    // Allow right clicking messages
    contentController.addEventHandler(
      JSEventHandler(event: "message:actions:view", action: MessageAction.showMenu),
      viewStore: actions
    )
    // Allow toggling reactions
    contentController.addEventHandler(
      JSEventHandler(event: "message:reactions:react", action: MessageAction.toggleReaction),
      viewStore: actions
    )
    // Enable reactions picker shortcut
    contentController.addEventHandler(
      JSEventHandler(event: "message:reactions:view", action: MessageAction.showReactions),
      viewStore: actions
    )

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = contentController

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.loadFileURL(Files.messagingHtml.url, allowingReadAccessTo: Files.messagingHtml.url)

    signposter.endInterval(#function, interval)

    // Send an event when the web view finishes loading
    webView.publisher(for: \.isLoading)
      .filter { isLoading in !isLoading }
      .prefix(1)
      .sink { [viewStore] _ in
        viewStore.send(.webViewReady)
      }
      .store(in: &context.coordinator.cancellables)

    // Update messages
    self.viewStore.publisher
      .drop(while: { !$0.isWebViewReady })
      .map(\.messages)
      .map { $0.map(ProseCoreViewsMessage.init(from:)) }
      .removeDuplicates()
      .sink { messages in
        self.updateMessages(to: messages, in: webView)
      }
      .store(in: &context.coordinator.cancellables)

    // Update highlighted message
    self.viewStore.publisher
      .drop(while: { !$0.isWebViewReady })
      .map(\.selectedMessageId)
      .removeDuplicates()
      .sink { messageId in
        self.highlightMessage(messageId, in: webView)
      }
      .store(in: &context.coordinator.cancellables)

    // Show message menu
    self.viewStore.publisher
      .drop(while: { !$0.isWebViewReady })
      .map(\.menu)
      // Do not run `hideMenu` if the menu was never presented,
      // but still allow starting with a non-nil value (which `dropFirst()` would prevent).
      .drop(while: { $0 == nil })
      .removeDuplicates()
      .sink { menuState in
        if let menuState: MessageMenuState = menuState {
          self.showMenu(menuState, on: webView, context: context)
        } else {
          self.hideMenu(context: context)
        }
      }
      .store(in: &context.coordinator.cancellables)

    return webView
  }

  func updateNSView(_: WKWebView, context _: Context) {}

  func updateMessages(to messages: [ProseCoreViewsMessage], in webView: WKWebView) {
    logger.trace("Updating \(Self.self): \(messages.count, privacy: .public) messages")

    let interval = signposter.beginInterval(#function, id: self.signpostID)

    let jsonEncoder = JSONEncoder()
    // NOTE: We sort keys so that reaction emojis are always sorted the same.
    //       We could use `OrderedDictionary` from `swift-collections`, but it encodes as
    //       `["key": ["value"]]` instead of `{"key": ["value"]}`.
    // NOTE: Fixed in https://github.com/prose-im/prose-core-views/releases/tag/0.10.0
    jsonEncoder.outputFormatting = .sortedKeys
    let jsonData: Data = try! jsonEncoder.encode(messages)
    let json = String(data: jsonData, encoding: .utf8) ?? "[]"
    let script = """
    MessagingStore.flush();
    MessagingStore.insert(...\(json));
    """
    webView.evaluateJavaScript(script, domain: "Insert messages")

    signposter.endInterval(#function, interval)
  }

  func highlightMessage(_ messageId: Message.ID?, in webView: WKWebView) {
    logger.trace("Highlighting message \(messageId ?? "nil", privacy: .public)…")

    let jsonData: Data = try! JSONEncoder().encode(messageId)
    let json = String(data: jsonData, encoding: .utf8) ?? "null"
    let script = """
    MessagingStore.highlight(\(json));
    """
    webView.evaluateJavaScript(script, domain: "Highlight message")
  }

  func showMenu(_ menuState: MessageMenuState, on webView: WKWebView, context: Context) {
    logger.trace("Showing message menu…")

    #if os(macOS)
      let menu: MessageMenu = context.coordinator.menu ?? {
        let menu = MessageMenu(title: "Actions")
        menu.viewStore = self.viewStore

        // Enable items, which are disabled by default because the responder chain doesn't handle the actions
        menu.autoenablesItems = false

        menu.delegate = context.coordinator

        DispatchQueue.main.async {
          menu.popUp(positioning: nil, at: menuState.origin, in: webView)
        }

        return menu
      }()

      menu.removeAllItems()
      for item in menuState.items {
        switch item {
        case let .item(itemState):
          menu.addItem(itemState)
        case .separator:
          menu.addItem(.separator())
        }
      }
    #else
      #warning("Show a menu")
      // NOTE: UIKit has [`UIMenuController.showMenu(from:rect:)`](https://developer.apple.com/documentation/uikit/uimenucontroller/3044217-showmenu), but it will be deprecated in iOS 16
    #endif
  }

  func hideMenu(context: Context) {
    logger.trace("Hiding message menu…")

    #if os(macOS)
      context.coordinator.menu = nil
    #endif
  }
}

extension ChatView.Coordinator: NSMenuDelegate {
  func menuDidClose(_: NSMenu) {
    self.viewStore.send(.menuDidClose)
  }
}

extension ChatView {
  var setAccountJIDScript: WKUserScript {
    let jsonData: Data = try! JSONEncoder().encode(self.viewStore.loggedInUserJID.jidString)
    let json = String(data: jsonData, encoding: .utf8) ?? "''"
    let script = """
    MessagingContext.setAccountJID(\(json));
    """
    return WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
  }
}

struct JSEventHandler {
  var event: String
  var actionFromMessage: (WKScriptMessage) throws -> MessageAction

  init<Payload: Decodable>(event: String, action: @escaping (Payload) -> MessageAction) {
    self.event = event
    self.actionFromMessage = { message in
      guard let bodyString: String = message.body as? String,
            let bodyData: Data = bodyString.data(using: .utf8)
      else {
        logger.fault("JS message body should be serialized as a String")
        #warning("TODO: Throw an exception instead of `fatalError`")
        fatalError()
      }

      guard let payload = try? JSONDecoder().decode(Payload.self, from: bodyData) else {
        logger
          .warning("JS message body could not be decoded as `Self.Body`. Content: \(bodyString)")
        #warning("TODO: Throw an exception instead of `fatalError`")
        fatalError()
      }

      return action(payload)
    }
  }
}

final class ViewStoreScriptMessageHandler: NSObject, WKScriptMessageHandler {
  let viewStore: ViewStore<Void, MessageAction>
  let handler: JSEventHandler

  init(handler: JSEventHandler, viewStore: ViewStore<Void, MessageAction>) {
    self.handler = handler
    self.viewStore = viewStore
    super.init()
  }

  func userContentController(
    _: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    #warning("TODO: Handle exception")
    try! self.viewStore.send(self.handler.actionFromMessage(message))
  }
}

extension WKUserContentController {
  func addEventHandler(_ handler: JSEventHandler, viewStore: ViewStore<Void, MessageAction>) {
    let handlerName = "handler_" + handler.event.replacingOccurrences(of: ":", with: "_")

    self.add(
      ViewStoreScriptMessageHandler(handler: handler, viewStore: viewStore),
      name: handlerName
    )

    let script = """
    function \(handlerName)(content) {
      // We need to send a parameter, or the call will not be forwarded to the `WKScriptMessageHandler`
      window.webkit.messageHandlers.\(handlerName).postMessage(JSON.stringify(content));
    }
    MessagingEvent.on("\(handler.event)", \(handlerName));
    """

    self.addUserScript(
      WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    )
  }
}
