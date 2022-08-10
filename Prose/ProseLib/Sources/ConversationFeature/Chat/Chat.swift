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
import ProseCoreViews
import ProseUI
import SwiftUI
import WebKit

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
    var messages = IdentifiedArrayOf<ProseCoreViews.Message>()
    var cancellables = Set<AnyCancellable>()

    var ffi: ProseCoreViews.FFI!

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
    MessagingContext { jsScript, completion in
      contentController.addUserScript(
        WKUserScript(source: jsScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
      )
      completion(nil, nil)
    }.setAccountJID(self.viewStore.loggedInUserJID)

    let actions = ViewStore(self.store.stateless)
    // Allow right clicking messages
    contentController.addMessageEventHandler(for: .showMenu) { result in
      actions.send(.messageEvent(MessageEvent.showMenu, from: result))
    }
    // Allow toggling reactions
    contentController.addMessageEventHandler(for: .toggleReaction) { result in
      actions.send(.messageEvent(MessageEvent.toggleReaction, from: result))
    }
    // Enable reactions picker shortcut
    contentController.addMessageEventHandler(for: .showReactions) { result in
      actions.send(.messageEvent(MessageEvent.showReactions, from: result))
    }

    let configuration = WKWebViewConfiguration()
    configuration.userContentController = contentController

    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.loadFileURL(Files.messagingHtml.url, allowingReadAccessTo: Files.messagingHtml.url)

    context.coordinator.ffi = FFI { [weak webView] jsString, completion in
      print(jsString)

      webView?.evaluateJavaScript(jsString) { res, error in
        if let res = res {
          logger.debug("JavaScript response: \(String(reflecting: res))")
        }
        if let error = error as? NSError {
          logger.warning(
            "[Error evaluating JavaScript: \(error.crisp_javaScriptExceptionMessage)"
          )
        }
        completion(res, error)
      }
    }

    signposter.endInterval(#function, interval)

    // Send an event when the web view finishes loading
    webView.publisher(for: \.isLoading)
      .filter { isLoading in !isLoading }
      .prefix(1)
      .sink { [viewStore] _ in
        viewStore.send(.webViewReady)
      }
      .store(in: &context.coordinator.cancellables)

    let ffi = context.coordinator.ffi.expect("Expected ProseCoreViews FFI to be set")

    // Update messages
    self.viewStore.publisher
      .drop(while: { !$0.isWebViewReady })
      .map(\.messages)
      .map { $0.map(ProseCoreViews.Message.init(from:)) }
      // Do not run `updateMessages` until there are messages to show,
      // but still allow starting with a non-empty value (which `dropFirst()` would prevent).
      .drop(while: \.isEmpty)
      .removeDuplicates()
      .sink { [weak coordinator = context.coordinator] messages in
        guard let coordinator = coordinator else { return }
        ffi.messagingStore.updateMessages(to: messages, oldMessages: &coordinator.messages)
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
        ffi.messagingStore.highlightMessage(messageId)
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
          self.showReactionPicker(
            pickerState,
            on: webView,
            coordinator: coordinator
          )
        } else {
          self.hideReactionPicker(coordinator: coordinator)
        }
      }
      .store(in: &context.coordinator.cancellables)

    return webView
  }

  func updateNSView(_ webView: WKWebView, context: Context) {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    if !webView.isLoading {
      // TODO: Maybe remove duplicates (see if signpost interval becomes too long)
      let styleTheme: StyleTheme = {
        switch self.colorScheme {
        case .light:
          return .light
        case .dark:
          return .dark
        @unknown default:
          return .light
        }
      }()
      context.coordinator.ffi.messagingContext.setStyleTheme(styleTheme)
    } else {
      logger.trace("Skipping \(Self.self) update: JavaScript is not loaded.")
    }

    signposter.endInterval(#function, interval)
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

      coordinator.ffi.messagingStore.interact(.reactions, pickerState.messageId, true)
    #else
      #warning("Show a reaction picker")
    #endif
  }

  func hideReactionPicker(coordinator: Coordinator) {
    logger.trace("Hiding reaction picker…")

    #if os(macOS)
      if let store = coordinator.reactionPicker?.store {
        let messageId = ViewStore(store).messageId
        coordinator.ffi.messagingStore.interact(.reactions, messageId, false)
      }
      coordinator.reactionPicker?.removeFromSuperview()
    #endif
  }
}

extension ChatView.Coordinator: NSMenuDelegate {
  func menuDidClose(_: NSMenu) {
    self.viewStore.send(.menuDidClose)
  }
}

private extension ChatAction {
  static func messageEvent<T>(
    _ action: (T) -> MessageEvent,
    from result: Result<T, JSEventError>
  ) -> Self {
    switch result {
    case let .success(payload):
      return .message(action(payload))
    case let .failure(error):
      return .jsEventError(error)
    }
  }
}
