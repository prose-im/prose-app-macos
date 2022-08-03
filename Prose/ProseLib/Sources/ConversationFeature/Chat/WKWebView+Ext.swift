//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import WebKit

extension WKWebView {
  func evaluateJavaScript(
    _ script: String,
    domain: StaticString,
    debugLog: Bool = false,
    printResult: Bool = false
  ) {
    if debugLog {
      logger.debug("Evaluating `\(script)`…")
    }
    self.evaluateJavaScript(script) { res, error in
      if printResult, let res = res {
        logger.debug("[\(domain)] JavaScript response: \(String(reflecting: res))")
      }
      if let error: NSError = error as? NSError {
        logger
          .warning("[\(domain)] Error evaluating JavaScript: \(error.javaScriptExceptionMessage)")
      }
    }
  }
}

private extension NSError {
  var javaScriptExceptionMessage: String {
    (self.userInfo["WKJavaScriptExceptionMessage"] as? String) ?? self.localizedDescription
  }
}
