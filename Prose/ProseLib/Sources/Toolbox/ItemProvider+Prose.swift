//
// This file is part of prose-app-macos.
// Copyright (c) 2023 Prose Foundation
//

import Combine
import Foundation

public extension NSItemProvider {
  func prose_loadObject<T>(ofClass: T.Type) async throws -> T? where T: NSItemProviderReading {
    try await withCheckedThrowingContinuation { continuation in
      _ = loadObject(ofClass: ofClass) { data, error in
        if let error {
          continuation.resume(throwing: error)
          return
        }

        guard let image = data as? T else {
          continuation.resume(returning: nil)
          return
        }

        continuation.resume(returning: image)
      }
    }
  }

  func prose_loadImage() async throws -> PlatformImage? {
    try await self.prose_loadObject(ofClass: PlatformImage.self)
  }
}
