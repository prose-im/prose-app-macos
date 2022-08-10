//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import Combine
import ComposableArchitecture
import IdentifiedCollections
import OrderedCollections
import OSLog
import ProseCoreTCA
import ProseUI
import SwiftUI
import WebKit

// MARK: - View

struct ProseCoreViewsMessage: Equatable, Encodable, Identifiable {
  struct User: Equatable, Encodable {
    let jid: String
    let name: String
  }

  struct Reaction: Equatable, Encodable {
    let reaction: String
    let authors: [String]
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
  let reactions: [Reaction]

  init(from message: Message) {
    self.id = message.id
    self.date = Self.dateFormatter.string(from: message.timestamp)
    self.content = message.body
    self.from = User(
      jid: message.from.jidString,
      name: message.from.jidString
    )
    self.reactions = message.reactions.reactions.map(Reaction.init(from:))
  }
}

extension ProseCoreViewsMessage.Reaction {
  init(from element: MessageReactions.WrappedValue.Element) {
    self.init(reaction: element.key.rawValue, authors: element.value.map(\.rawValue))
  }
}

enum ProseCoreViewsMessageAction: String, Encodable {
  case reactions, actions
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
      .alert(self.store.scope(state: \.alert), dismiss: .alertDismissed)
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
    /// This is the state of messages stored in the web view. It's used for diffing purposes.
    var messages = IdentifiedArrayOf<ProseCoreViewsMessage>()
    var cancellables = Set<AnyCancellable>()

    let viewStore: ViewStore<Void, Action>
    var reactionPicker: ReactionPickerView<ChatView.Action>?

    #if os(macOS)
      var menu: MessageMenu?
    #endif

    init(viewStore: ViewStore<Void, Action>) {
      self.viewStore = viewStore
    }

    func createOrUpdateReactionPicker(
      store: Store<MessageReactionPickerState, ChatView.Action>,
      action: CasePath<ChatView.Action, ReactionPickerAction>,
      dismiss dismissAction: ChatView.Action
    ) -> ReactionPickerView<ChatView.Action> {
      if let picker = self.reactionPicker {
        picker.store = store
        return picker
      } else {
        let picker = ReactionPickerView(store: store, action: action, dismiss: dismissAction)
        self.reactionPicker = picker
        return picker
      }
    }
  }

  @Environment(\.colorScheme) private var colorScheme

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

    let actions = ViewStore(self.store.stateless)
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
      // Do not run `updateMessages` until there are messages to show,
      // but still allow starting with a non-empty value (which `dropFirst()` would prevent).
      .drop(while: \.isEmpty)
      .removeDuplicates()
      .sink { [weak coordinator = context.coordinator] messages in
        guard let coordinator = coordinator else { return }
        self.updateMessages(to: messages, in: webView, coordinator: coordinator)
      }
      .store(in: &context.coordinator.cancellables)

    // Update highlighted message
    self.viewStore.publisher
      .drop(while: { !$0.isWebViewReady })
      .map(\.selectedMessageId)
      // Do not run `highlightMessage` while `selectedMessageId`,
      // but still allow starting with a non-nil value (which `dropFirst()` would prevent).
      .drop(while: { $0 == nil })
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
      .sink { [weak coordinator = context.coordinator] menuState in
        guard let coordinator = coordinator else { return }
        if let menuState: MessageMenuState = menuState {
          self.showMenu(menuState, on: webView, coordinator: coordinator)
        } else {
          self.hideMenu(coordinator: coordinator)
        }
      }
      .store(in: &context.coordinator.cancellables)

    // Show reaction picker
    self.viewStore.publisher
      // NOTE: We don't *need* the web view to be ready, but it would not make sense
      //       to show the picker anyway
      .drop(while: { !$0.isWebViewReady })
      .map(\.reactionPicker)
      // Do not run `hideReactionPicker` if the picker was never presented,
      // but still allow starting with a non-nil value (which `dropFirst()` would prevent).
      .drop(while: { $0 == nil })
      .removeDuplicates()
      .sink { [weak coordinator = context.coordinator] pickerState in
        guard let coordinator = coordinator else { return }
        if let pickerState: MessageReactionPickerState = pickerState {
          self.showReactionPicker(pickerState, on: webView, coordinator: coordinator)
        } else {
          self.hideReactionPicker(webView: webView, coordinator: coordinator)
        }
      }
      .store(in: &context.coordinator.cancellables)

    return webView
  }

  func updateNSView(_ webView: WKWebView, context _: Context) {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    if !webView.isLoading {
      // TODO: Maybe remove duplicates (see if signpost interval becomes too long)
      self.updateColorScheme(of: webView)
    } else {
      logger.trace("Skipping \(Self.self) update: JavaScript is not loaded.")
    }

    signposter.endInterval(#function, interval)
  }

  func updateMessages(
    to messages: [ProseCoreViewsMessage],
    in webView: WKWebView,
    coordinator: Coordinator
  ) {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    let messages = IdentifiedArrayOf<ProseCoreViewsMessage>(uniqueElements: messages)
    let oldMessages: IdentifiedArrayOf<ProseCoreViewsMessage> = coordinator.messages
    defer { coordinator.messages = messages }

    let ids = OrderedSet<Message.ID>(messages.map(\.id))
    let oldIds: OrderedSet<Message.ID> = coordinator.messages.ids

    let insertedIds: OrderedSet<Message.ID> = ids.subtracting(oldIds)
    let removedIds: OrderedSet<Message.ID> = oldIds.subtracting(ids)
    let updatedIds: [Message.ID] = ids.intersection(oldIds)
      .filter { messages[id: $0] != oldMessages[id: $0] }

    for messageId in removedIds {
      self.retractMessage(withId: messageId, in: webView)
    }
    for messageId in updatedIds {
      if let message = messages[id: messageId] {
        self.updateMessage(to: message, in: webView)
      }
    }
    self.insertMessages(insertedIds.compactMap { messages[id: $0] }, in: webView)

    signposter.endInterval(#function, interval)
  }

  func insertMessages(_ messages: [ProseCoreViewsMessage], in webView: WKWebView) {
    guard !messages.isEmpty else { return }
    logger.trace("Inserting \(messages.count, privacy: .public) message(s)…")

    let script = """
    MessagingStore.insert(...\(Self.json(messages)));
    """
    webView.evaluateJavaScript(script, domain: "Insert messages")
  }

  func updateMessage(to message: ProseCoreViewsMessage, in webView: WKWebView) {
    logger.trace("Updating 1 message…")

    let script = """
    MessagingStore.update(\(Self.unsafeJson(message.id)), \(Self.unsafeJson(message)));
    """
    webView.evaluateJavaScript(script, domain: "Update message")
  }

  func retractMessage(withId messageId: ProseCoreViewsMessage.ID, in webView: WKWebView) {
    logger.trace("Retracting 1 message…")

    let script = """
    MessagingStore.retract(\(Self.unsafeJson(messageId)));
    """
    webView.evaluateJavaScript(script, domain: "Retract message")
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

  func showMenu(_ menuState: MessageMenuState, on webView: WKWebView, coordinator: Coordinator) {
    logger.trace("Showing message menu…")

    #if os(macOS)
      let menu: MessageMenu = coordinator.menu ?? {
        let menu = MessageMenu(title: "Actions")
        menu.viewStore = self.viewStore

        // Enable items, which are disabled by default because the responder chain doesn't handle the actions
        menu.autoenablesItems = false

        menu.delegate = coordinator

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

  func hideMenu(coordinator: Coordinator) {
    logger.trace("Hiding message menu…")

    #if os(macOS)
      coordinator.menu = nil
    #endif
  }

  func showReactionPicker(
    _ pickerState: MessageReactionPickerState,
    on webView: WKWebView,
    coordinator: Coordinator
  ) {
    logger.trace("Showing reaction picker…")

    #if os(macOS)
      let picker: ReactionPickerView = coordinator.createOrUpdateReactionPicker(
        store: self.store.scope(state: { _ in pickerState }),
        action: CasePath(ChatAction.reactionPicker),
        dismiss: .reactionPickerDismissed
      )

      picker.frame = pickerState.origin

      if picker.superview == nil {
        webView.addSubview(picker)
      }

      self.lockAction(.reactions, of: pickerState.messageId, isLocked: true, in: webView)
    #else
      #warning("Show a reaction picker")
    #endif
  }

  func hideReactionPicker(webView: WKWebView, coordinator: Coordinator) {
    logger.trace("Hiding reaction picker…")

    #if os(macOS)
      if let store = coordinator.reactionPicker?.store {
        self.lockAction(.reactions, of: ViewStore(store).messageId, isLocked: false, in: webView)
      }
      coordinator.reactionPicker?.removeFromSuperview()
    #endif
  }

  func lockAction(
    _ action: ProseCoreViewsMessageAction,
    of messageId: Message.ID,
    isLocked: Bool,
    in webView: WKWebView
  ) {
    let script = """
    MessagingStore.interact(\(Self.unsafeJson(messageId)), \(Self.unsafeJson(action)), \(Self
      .unsafeJson(isLocked)));
    """
    webView.evaluateJavaScript(script, domain: "Lock/unlock action")
  }

  func updateColorScheme(of webView: WKWebView) {
    let theme: String? = {
      switch self.colorScheme {
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
      webView.evaluateJavaScript(script, domain: "Color scheme")
    }
  }

  static func json<T: Encodable & Collection>(_ array: T) -> String {
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
  static func unsafeJson<T: Encodable>(_ object: T) -> String {
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
  var actionFromMessage: (WKScriptMessage) -> Result<MessageAction, JSEventError>

  init<Payload: Decodable>(event: String, action: @escaping (Payload) -> MessageAction) {
    self.event = event
    self.actionFromMessage = { message in
      guard let bodyString: String = message.body as? String,
            let bodyData: Data = bodyString.data(using: .utf8)
      else {
        logger.fault("JS message body should be serialized as a String")
        return .failure(.badSerialization)
      }

      do {
        let payload = try JSONDecoder().decode(Payload.self, from: bodyData)
        return .success(action(payload))
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
  }
}

final class ViewStoreScriptMessageHandler: NSObject, WKScriptMessageHandler {
  let viewStore: ViewStore<Void, ChatAction>
  let handler: JSEventHandler

  init(handler: JSEventHandler, viewStore: ViewStore<Void, ChatAction>) {
    self.handler = handler
    self.viewStore = viewStore
    super.init()
  }

  func userContentController(
    _: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    switch self.handler.actionFromMessage(message) {
    case let .success(action):
      self.viewStore.send(.message(action))
    case let .failure(error):
      self.viewStore.send(.jsEventError(error))
    }
  }
}

extension WKUserContentController {
  func addEventHandler(_ handler: JSEventHandler, viewStore: ViewStore<Void, ChatAction>) {
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
