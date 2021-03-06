//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import Combine
import ComposableArchitecture
import OSLog
import ProseCoreTCA
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

  let id = UUID()
  let type = "text"
  let date: String
  let content: String
  let from: User

  init(from message: Message) {
    self.date = Self.dateFormatter.string(from: message.timestamp)
    self.content = message.body
    self.from = User(
      jid: message.from.jidString,
      name: message.from.jidString
    )
  }
}

struct Chat: NSViewRepresentable {
  typealias ViewState = ChatState
  typealias ViewAction = ChatAction

  final class ChatCoordinator {
    var cancellables = Set<AnyCancellable>()

    init() {}
  }

  let signpostID = signposter.makeSignpostID()

  let store: Store<ViewState, ViewAction>
  @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

  init(store: Store<ViewState, ViewAction>) {
    self.store = store
    self.viewStore = ViewStore(store)
  }

  func makeCoordinator() -> ChatCoordinator {
    ChatCoordinator()
  }

  func makeNSView(context: Context) -> WKWebView {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    let configuration = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.loadFileURL(Files.messagingHtml.url, allowingReadAccessTo: Files.messagingHtml.url)
    signposter.endInterval(#function, interval)

    webView.publisher(for: \.isLoading)
      .filter { isLoading in !isLoading }
      .prefix(1)
      .sink(receiveValue: { [viewStore] _ in
        viewStore.send(.webViewReady)
      }).store(in: &context.coordinator.cancellables)

    return webView
  }

  func updateNSView(_ webView: WKWebView, context _: Context) {
    let interval = signposter.beginInterval(#function, id: self.signpostID)

    if !webView.isLoading {
      let jsonData = try! JSONEncoder()
        .encode(self.viewStore.messages.map(ProseCoreViewsMessage.init(from:)))
      let json = String(data: jsonData, encoding: .utf8) ?? "[]"
      webView.evaluateJavaScript("""
      MessagingStore.flush();
      MessagingStore.insert(...\(json));
      """) { _, error in
        if let error = error {
          logger.warning("Error evaluating JavaScript: \(error.localizedDescription)")
        }
      }
    } else {
      logger.trace("Skipping \(Self.self) update: JavaScript is not loaded.")
    }

    signposter.endInterval(#function, interval)
  }
}

struct ChatState: Equatable {
  var isWebViewReady = false
  var messages = [Message]()
}

public enum ChatAction: Equatable {
  case webViewReady
}

let chatReducer = Reducer<ChatState, ChatAction, Void> { state, action, _ in
  switch action {
  case .webViewReady:
    state.isWebViewReady = true
    return .none
  }
}
