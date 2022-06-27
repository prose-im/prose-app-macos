//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

public extension ImageAsset {
  var customURL: URL? {
    var components = URLComponents()
    components.scheme = "asset"
    components.path = Bundle.fixedModule.bundlePath
    components.queryItems = [
      .init(name: "imageName", value: self.name),
    ]
    return components.url
  }
}
