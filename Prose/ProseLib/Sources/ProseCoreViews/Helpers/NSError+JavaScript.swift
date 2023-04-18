//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Foundation

public extension NSError {
  var crisp_javaScriptExceptionMessage: String {
    (self.userInfo["WKJavaScriptExceptionMessage"] as? String) ?? self.localizedDescription
  }
}
