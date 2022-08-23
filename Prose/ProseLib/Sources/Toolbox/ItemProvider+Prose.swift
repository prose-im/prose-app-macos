//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Combine
import Foundation
import UniformTypeIdentifiers

#if canImport(AppKit)
  import AppKit
#endif

public enum ItemProviderError: Error {
  case couldNotRetrieveItem
  case invalidItemData
}

public extension NSItemProvider {
  func prose_systemImagePublisher() -> AnyPublisher<PlatformImage, Error> {
    #if os(macOS)
      if #available(macOS 13.0, *) {
        return self.prose_publisher(ofClass: PlatformImage.self)
      } else {
        return Deferred {
          Future { promise in
            let identifier = [UTType]([.png, .jpeg, .image, .fileURL])
              .lazy
              .map(\.identifier)
              .filter(self.hasItemConformingToTypeIdentifier)
              .first

            guard let identifier = identifier else {
              return promise(.failure(ItemProviderError.couldNotRetrieveItem))
            }

            self.loadItem(forTypeIdentifier: identifier) { data, error in
              if let error = error {
                return promise(.failure(error))
              }
              guard let data = data else {
                return promise(.failure(ItemProviderError.couldNotRetrieveItem))
              }

              if identifier == UTType.fileURL.identifier {
                guard
                  let data = data as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil),
                  let image = NSImage(contentsOf: url)
                else {
                  return promise(.failure(ItemProviderError.invalidItemData))
                }
                return promise(.success(image))
              }

              guard
                let data = data as? Data,
                let image = NSImage(data: data)
              else {
                return promise(.failure(ItemProviderError.invalidItemData))
              }

              promise(.success(image))
            }
          }
        }.eraseToAnyPublisher()
      }
    #else
      return self.prose_publisher(ofClass: PlatformImage.self)
    #endif
  }

  func prose_publisher<T>(ofClass cls: T.Type) -> AnyPublisher<T, Error>
    where T: NSItemProviderReading
  {
    guard self.canLoadObject(ofClass: cls) else {
      return Fail(error: ItemProviderError.couldNotRetrieveItem).eraseToAnyPublisher()
    }

    return Deferred {
      Future { promise in
        _ = self.loadObject(ofClass: cls) { result, error in
          if let error = error {
            return promise(.failure(error))
          }
          guard let item = result as? T else {
            return promise(.failure(ItemProviderError.invalidItemData))
          }
          promise(.success(item))
        }
      }
    }.eraseToAnyPublisher()
  }
}
