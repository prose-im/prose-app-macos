//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

#if os(macOS)
  import Cocoa
#elseif canImport(UIKit)
  import UIKit
#endif
import ComposableArchitecture

extension PasteboardClient: DependencyKey {
  public static var liveValue = PasteboardClient.live()
}

public extension PasteboardClient {
  #if os(macOS)
    static func live(
      pasteboard: NSPasteboard = .general
    ) -> Self {
      .init(
        copyString: {
          pasteboard.clearContents()
          pasteboard.setString($0, forType: .string)
        }
      )
    }

  #elseif canImport(UIKit)
    static func live(
      pasteboard: UIPasteboard = .general
    ) -> Self {
      .init(
        copyString: { pasteboard.string = $0 }
      )
    }
  #endif
}

#if DEBUG
  public extension PasteboardClient {
    static var noop = PasteboardClient(
      copyString: { _ in () }
    )
  }
#endif
