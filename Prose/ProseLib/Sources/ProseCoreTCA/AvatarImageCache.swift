//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ImageIO
import ProseCore
import ProseCoreClientFFI
import Toolbox

public struct AvatarImageCache {
  public var cachedURLForAvatarImageWithID: (JID, _ imageId: String) -> URL?
  public var cacheAvatarImage: (JID, _ imageData: Data, _ imageId: ImageId) throws -> URL
}

enum ImageCacheError: Error {
  case couldNotDecodeAvatarData
}

public extension AvatarImageCache {
  static func live(cacheDirectory: URL) throws -> Self {
    let fileManager = FileManager.default

    try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

    func fileURL(for jid: JID, imageId: String) -> URL {
      let filename = "\(jid.bareJid.node ?? "")-\(jid.bareJid.domain)-\(imageId)".unicodeScalars
        .filter(CharacterSet.urlPathAllowed.contains)
      return cacheDirectory.appendingPathComponent(String(filename), conformingTo: .jpeg)
    }

    let maxPixelSize = 300
    let compressionRatio = Float(0.75)

    return .init(
      cachedURLForAvatarImageWithID: { jid, imageId in
        let url = fileURL(for: jid, imageId: imageId)
        return fileManager.fileExists(atPath: url.path) ? url : nil
      },
      cacheAvatarImage: { jid, imageData, imageId in
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)
        else {
          throw ImageCacheError.couldNotDecodeAvatarData
        }

        let url = fileURL(for: jid, imageId: imageId)

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
