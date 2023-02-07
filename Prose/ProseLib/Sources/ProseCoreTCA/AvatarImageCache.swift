//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ImageIO
import ProseCore
import Toolbox
import ProseBackend

public struct AvatarImageCache {
  public var cachedURLForAvatarImageWithID: (BareJid, _ imageId: String) -> URL?
  public var cacheAvatarImage: (BareJid, _ imageData: Data, _ imageId: ImageId) throws -> URL
}

enum ImageCacheError: Error {
  case couldNotGenerateURL
  case couldNotDecodeAvatarData
}

public extension AvatarImageCache {
  static func live(cacheDirectory: URL) throws -> Self {
    let fileManager = FileManager.default

    try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

    func fileURL(for jid: BareJid, imageId: String) -> URL? {
      let filename = "\(jid.node ?? "")-\(jid.domain)-\(imageId)"
        .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
      return filename.map { cacheDirectory.appendingPathComponent($0, conformingTo: .jpeg) }
    }

    let maxPixelSize = 300
    let compressionRatio = Float(0.75)

    return .init(
      cachedURLForAvatarImageWithID: { jid, imageId in
        if let url = fileURL(for: jid, imageId: imageId) {
          return fileManager.fileExists(atPath: url.path) ? url : nil
        }
        return nil
      },
      cacheAvatarImage: { jid, imageData, imageId in
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions)
        else {
          throw ImageCacheError.couldNotDecodeAvatarData
        }

        guard let url = fileURL(for: jid, imageId: imageId) else {
          throw ImageCacheError.couldNotGenerateURL
        }

        try imageSource.prose_downsample(
          to: url,
          maxPixelSize: maxPixelSize,
          compressionRatio: compressionRatio
        )

        return url
      }
    )
  }
}

public extension AvatarImageCache {
  static let noop = AvatarImageCache(
    cachedURLForAvatarImageWithID: { _, _ in nil },
    cacheAvatarImage: { _, _, _ in URL(fileURLWithPath: "/") }
  )
}
