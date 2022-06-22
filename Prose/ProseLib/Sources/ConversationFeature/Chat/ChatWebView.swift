//
//  ChatWebView.swift
//  Prose
//
//  Created by Rémi Bardon on 22/06/2022.
//

import AppKit
import ComposableArchitecture
import SwiftUI
import WebKit

struct ChatWebView: NSViewRepresentable {
    typealias ViewState = ChatState
    typealias ViewAction = Never

    let store: Store<ViewState, ViewAction>
    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

    init(store: Store<ViewState, ViewAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    func makeNSView(context: Context) -> WKWebView {
//        let data = try! Data(contentsOf: Files.indexCb20d22aJs.url)
//        let realScript = String(data: data, encoding: .utf8)!
        let customScript = """
        const list = document.getElementById('messages');
        function updateMessages(messages) {
            list.replaceChildren(...messages.map((message) => {
                var li = document.createElement('li');
                li.appendChild(document.createTextNode(message));
                return li;
            }));
        }
        """

        let contentController = WKUserContentController()
//        contentController.addUserScript(WKUserScript(
//            source: realScript,
//            injectionTime: .atDocumentEnd,
//            forMainFrameOnly: true
//        ))
        contentController.addUserScript(WKUserScript(
            source: customScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        ))

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
//        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.uiDelegate = context.coordinator

//        webView.loadFileURL(Files.indexHtml.url, allowingReadAccessTo: Files.indexHtml.url)
        webView.loadHTMLString("""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Messaging View</title>
        </head>
        <body>
            <h1>Hello, World!</h1>
            <ol id="messages">
            </ol>
        </body>
        </html>
        """, baseURL: nil)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context _: Context) {
        if !webView.isLoading {
            let jsonData = try! JSONEncoder().encode(self.viewStore.messages.map(\.body))
            let json = String(data: jsonData, encoding: .utf8) ?? "[]"
            webView.evaluateJavaScript("updateMessages(\(json));") { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error)")
                }
            }
        } else {
            print("Skipping \(Self.self) update: Page is not loaded, `updateMessages` is `undefined`.")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKUIDelegate {
        /// - Copyright: https://www.advancedswift.com/wkwebview-javascript-alerts-in-swift/#wkwebview-javascript-alert-message-on-macos
        func webView(
            _: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame _: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            // Set the message as the NSAlert text
            let alert = NSAlert()
            alert.informativeText = message
            alert.addButton(withTitle: "Ok")

            // Display the NSAlert
            alert.runModal()

            // Call completionHandler
            completionHandler()
        }
    }
}
