//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import Combine
import ComposableArchitecture
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
  let reactions: [String: [String]]

  init(from message: Message) {
    self.id = message.id
    self.date = Self.dateFormatter.string(from: message.timestamp)
    self.content = message.body
    self.from = User(
      jid: message.from.jidString,
      name: message.from.jidString
    )
    var reactions = [String: [String]]()
    for (reaction, jids) in message.reactions {
      reactions[String(reaction)] = jids.map(\.jidString)
    }
    self.reactions = reactions
  }
}

struct Chat: View {
  @ObservedObject var viewStore: ViewStore<ChatView.State, ChatView.Action>

  init(store: Store<ChatView.State, ChatView.Action>) {
    self.viewStore = ViewStore(store)
  }

  var body: some View {
    ChatView(viewStore: self.viewStore)
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

protocol WebMessageHandler {
  associatedtype Body: Decodable
  static var jsHandlerName: String { get }
  static var jsEventName: String { get }
  static var jsFunctionName: String { get }
  static var script: WKUserScript { get }
  func handle(_ message: WKScriptMessage)
  func handle(_ message: WKScriptMessage, body: Body)
}

extension WebMessageHandler {
  static var script: WKUserScript {
    let script = """
    function \(Self.jsFunctionName)(content) {
      // We need to send a parameter, or the call will not be forwarded to the `WKScriptMessageHandler`
      window.webkit.messageHandlers.\(Self.jsHandlerName)
        .postMessage(JSON.stringify(content));
    }
    MessagingEvent.on("\(Self.jsEventName)", \(Self.jsFunctionName));
    """
    return WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
  }

  func handle(_ message: WKScriptMessage) {
    guard let bodyString: String = message.body as? String,
          let bodyData: Data = bodyString.data(using: .utf8)
    else {
      logger.fault("JS message body should be serialized as a String")
      return assertionFailure()
    }
    guard let body: Self.Body = try? JSONDecoder().decode(Self.Body.self, from: bodyData) else {
      logger.warning("JS message body could not be decoded as `Self.Body`. Content: \(bodyString)")
      return assertionFailure()
    }
    self.handle(message, body: body)
  }
}

final class UserContentController: WKUserContentController {
  func add<Handler: WebMessageHandler>(
    _ scriptMessageHandler: WKScriptMessageHandler,
    for _: Handler.Type
  ) {
    self.add(scriptMessageHandler, name: Handler.jsHandlerName)
    self.addUserScript(Handler.script)
  }
}

struct ChatView: NSViewRepresentable {
  typealias State = ChatState
  typealias Action = ChatAction

  final class Coordinator: NSObject {
    var cancellables = Set<AnyCancellable>()

    let viewStore: ViewStore<State, Action>

    init(viewStore: ViewStore<State, Action>) {
      self.viewStore = viewStore
    }
  }

  let viewStore: ViewStore<State, Action>

  let signpostID = signposter.makeSignpostID()

  func makeCoordinator() -> Coordinator {
    Coordinator(viewStore: self.viewStore)
  }

  func makeNSView(context: Context) -> WKWebView {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    let contentController = UserContentController()

    // Set logged in user JID
    contentController.addUserScript(self.setAccountJIDScript)

    // Allow right clicking messages
    contentController.add(context.coordinator, for: MessageMenuHandler.self)
    // Allow toggling reactions
    contentController.add(context.coordinator, for: ToggleReactionHandler.self)
    // Enable reactions shortcut
    contentController.add(context.coordinator, for: ShowReactionsHandler.self)

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

  func updateNSView(_ webView: WKWebView, context _: Context) {
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
    } else {
      logger.trace("Skipping \(Self.self) update: JavaScript is not loaded.")
    }

    signposter.endInterval(#function, interval)
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

extension ChatView.Coordinator: WKScriptMessageHandler {
  func userContentController(
    _: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    switch message.name {
    case MessageMenuHandler.jsHandlerName:
      MessageMenuHandler(viewStore: self.viewStore).handle(message)
    case ToggleReactionHandler.jsHandlerName:
      ToggleReactionHandler(viewStore: self.viewStore).handle(message)
    case ShowReactionsHandler.jsHandlerName:
      ShowReactionsHandler(viewStore: self.viewStore).handle(message)
    case let name:
      logger.info("Received message \(String(describing: name))")
    }
  }
}

struct ChatState: Equatable {
  let loggedInUserJID: JID
  let chatId: JID
  var isWebViewReady = false
  var messages = [Message]()
  var selectedMessageId: Message.ID?
}

public enum ChatAction: Equatable {
  case webViewReady
  case navigateUp, navigateDown
  case didCreateMenu(MessageMenu, for: [Message.ID])
  case messageMenuItemTapped(MessageMenu.Action)
  case toggleReaction(Character, for: [Message.ID])
}

let chatReducer = Reducer<
  ChatState,
  ChatAction,
  ConversationEnvironment
> { state, action, environment in
  switch action {
  case .webViewReady:
    state.isWebViewReady = true
    return .none

  case .navigateUp:
    if let messageId = state.selectedMessageId,
       let index = state.messages.lastIndex(where: { $0.id == messageId })
    {
      if index > 0 {
        state.selectedMessageId = state.messages[index - 1].id
      } else {
        state.selectedMessageId = nil
      }
    } else {
      state.selectedMessageId = state.messages.last?.id
    }
    return .none

  case .navigateDown:
    if let messageId = state.selectedMessageId,
       let index = state.messages.lastIndex(where: { $0.id == messageId })
    {
      if index + 1 < state.messages.count {
        state.selectedMessageId = state.messages[index + 1].id
      } else {
        state.selectedMessageId = nil
      }
    } else {
      state.selectedMessageId = state.messages.first?.id
    }
    return .none

  case let .didCreateMenu(menu, messageIds):
    let loggedInUserJID: JID = state.loggedInUserJID

    if let id = messageIds.first,
       let message = state.messages.last(where: { $0.id == id }),
       message.from == loggedInUserJID
    {
      return .fireAndForget {
        // TODO: Uncomment once we support message edition
//        menu.item(withTag: .edit)!.isEnabled = true
        menu.item(withTag: .remove)!.isEnabled = true
      }
      .receive(on: environment.mainQueue)
      .eraseToEffect()
    }
    return .none

  case let .messageMenuItemTapped(action):
    switch action {
    case let .copyText(id):
      logger.trace("Copying text of \(String(describing: id))…")
      if let message = state.messages.last(where: { $0.id == id }) {
        environment.pasteboard.copyString(message.body)
      } else {
        logger.notice("Could not copy text: Message \(String(describing: id)) not found")
      }

    case let .edit(id):
      logger.trace("Editing \(String(describing: id))…")

    case let .addReaction(id):
      logger.trace("Reacting to \(String(describing: id))…")
      return environment.proseClient.addReaction(state.chatId, id, "👍").fireAndForget()

    case let .remove(id):
      logger.trace("Retracting \(String(describing: id))…")
      // NOTE: No need to `state.messages.removeAll(where:)` because the view will be automatically updated
      return environment.proseClient.retractMessage(id).fireAndForget()
    }
    return .none

  case let .toggleReaction(reaction, messageIds):
    if let id = messageIds.first {
      return environment.proseClient.toggleReaction(state.chatId, id, reaction).fireAndForget()
    } else {
      logger.notice("Could not toggle reaction: No message selected")
      return .none
    }
  }
}
