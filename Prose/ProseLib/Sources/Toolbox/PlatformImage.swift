//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation

#if os(macOS)
  import AppKit

  public typealias PlatformImage = NSImage

  public extension NSImage {
    var cgImage: CGImage? {
      self.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }

    func jpegData(compressionQuality: CGFloat) -> Data? {
      self.cgImage.flatMap { cgImage in
        NSBitmapImageRep(cgImage: cgImage).representation(
          using: NSBitmapImageRep.FileType.jpeg,
          properties: [.compressionFactor: compressionQuality]
        )
      }
    }
  }

#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit

  public typealias PlatformImage = UIImage
#endif
