//
//  Chat.swift
//  Prose
//
//  Created by Rémi Bardon on 03/03/2022.
//  Copyright © 2022 Prose. All rights reserved.
//

import Assets
import ComposableArchitecture
import OSLog
import ProseCoreTCA
import SharedModels
import SwiftUI
import WebKit

// MARK: - View

struct ProseCoreViewsMessage: Encodable {
    struct Content: Encodable {
        let type = "text"
        let text: String
    }

    struct User: Encodable {
        let name: String
        let avatar: String
    }

    fileprivate static var dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        return formatter
    }()

    let id = UUID()
    let type = "message"
    let date: String
    let content: [Content]
    let user: User

    init(from message: Message) {
        self.date = Self.dateFormatter.string(from: message.timestamp)
        self.content = [Content(text: message.body)]
        self.user = User(
            name: message.from.jidString,
            avatar: ""
        )
    }
}

struct Chat: NSViewRepresentable {
    typealias ViewState = ChatState
    typealias ViewAction = Never

    let signpostID = signposter.makeSignpostID()

    let store: Store<ViewState, ViewAction>
    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

    init(store: Store<ViewState, ViewAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    func makeNSView(context _: Context) -> WKWebView {
        let interval = signposter.beginInterval(#function, id: self.signpostID)

        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.loadFileURL(Files.indexHtml.url, allowingReadAccessTo: Files.indexHtml.url)

        signposter.endInterval(#function, interval)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context _: Context) {
        let interval = signposter.beginInterval(#function, id: self.signpostID)

        if !webView.isLoading {
            let jsonData = try! JSONEncoder().encode(self.viewStore.messages.map(ProseCoreViewsMessage.init(from:)))
            let json = String(data: jsonData, encoding: .utf8) ?? "[]"
            webView.evaluateJavaScript("""
            globalThis.MessagingStore.flush();
            globalThis.MessagingStore.insert(...\(json));
            """) { _, error in
                if let error = error {
                    logger.warning("Error evaluating JavaScript: \(error)")
                }
            }
        } else {
            logger.trace("Skipping \(Self.self) update: Page is not loaded, `updateMessages` is `undefined`.")
        }

        signposter.endInterval(#function, interval)
    }
}

struct ChatState: Equatable {
    var messages = [Message]()
}
