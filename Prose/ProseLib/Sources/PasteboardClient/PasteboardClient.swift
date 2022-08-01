//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

#if os(macOS)
  import Cocoa
#elseif canImport(UIKit)
  import UIKit
#endif

public struct PasteboardClient {
  public var copyString: (String) -> Void

  public init(
    copyString: @escaping (String) -> Void
  ) {
    self.copyString = copyString
  }
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
