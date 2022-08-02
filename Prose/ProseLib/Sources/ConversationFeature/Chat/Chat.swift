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

struct ProseCoreViewsMessage: Encodable {
  struct User: Encodable {
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
      .sink(receiveValue: { [viewStore] _ in
        viewStore.send(.webViewReady)
      })
      .store(in: &context.coordinator.cancellables)

    return webView
  }

  func updateNSView(_ webView: WKWebView, context: Context) {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    if !webView.isLoading {
      do {
        // TODO: Maybe remove duplicates (see if signpost interval becomes too long)
        let jsonEncoder = JSONEncoder()
        // NOTE: We sort keys so that reaction emojis are always sorted the same.
        //       We could use `OrderedDictionary` from `swift-collections`, but it encodes as
        //       `["key": ["value"]]` instead of `{"key": ["value"]}`.
        jsonEncoder.outputFormatting = .sortedKeys
        let jsonData: Data = try! jsonEncoder
          .encode(self.viewStore.messages.map(ProseCoreViewsMessage.init(from:)))
        let json = String(data: jsonData, encoding: .utf8) ?? "[]"
        let script: String = """
        MessagingStore.flush();
        MessagingStore.insert(...\(json));
        """
        webView.evaluateJavaScript(script, domain: "Insert messages")
      }

      do {
        // TODO: Maybe remove duplicates (see if signpost interval becomes too long)
        let jsonData: Data = try! JSONEncoder().encode(self.viewStore.selectedMessageId)
        let json = String(data: jsonData, encoding: .utf8) ?? "[]"
        let script: String = """
        MessagingStore.highlight(\(json));
        """
        webView.evaluateJavaScript(script, domain: "Highlight message")
      }

      do {
        #warning("TODO: Remove duplicates, not to show the menu multiple times")
        if let menu = self.viewStore.menu {
          self.showMenu(menu, on: webView, context: context)
        }
      }
    } else {
      logger.trace("Skipping \(Self.self) update: JavaScript is not loaded.")
    }

    signposter.endInterval(#function, interval)
  }

  func showMenu(_ menuState: MessageMenuState, on webView: WKWebView, context: Context) {
    #if os(macOS)
      let menu = MessageMenu(title: "Actions")
      menu.viewStore = self.viewStore

      if let id: Message.ID = menuState.ids.first {
        menu.addItem(withTitle: "Copy text", action: .copyText(id))
        menu.addItem(withTitle: "Add reaction…", action: .addReaction(id))
        menu.addItem(.separator())
        menu.addItem(withTitle: "Edit…", action: .edit(id), isDisabled: true)
        menu.addItem(withTitle: "Remove message", action: .remove(id), isDisabled: true)
      } else {
        menu.addItem(withTitle: "No action", action: nil)
      }

      // Enable items, which are disabled by default because the responder chain doesn't handle the actions
      menu.autoenablesItems = false

      menu.delegate = context.coordinator

      self.viewStore.send(.didCreateMenu(menu, for: menuState.ids))

      DispatchQueue.main.async {
        menu.popUp(positioning: nil, at: menuState.origin, in: webView)
      }
    #else
      #warning("Show a menu")
      // NOTE: UIKit has [`UIMenuController.showMenu(from:rect:)`](https://developer.apple.com/documentation/uikit/uimenucontroller/3044217-showmenu), but it will be deprecated in iOS 16
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
