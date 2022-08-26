//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

enum DownsamplingError: Error {
  case couldNotDownsampleImage
  case couldNotCreateImageDestination
  case invalidInputImage
  case couldNotFinalizeImage
}

public extension CGImageSource {
  func prose_downsample(
    to targetURL: URL,
    maxPixelSize: Int,
    compressionRatio: Float
  ) throws {
    guard let thumbnail = self.prose_thumbnail(maxPixelSize: maxPixelSize) else {
      throw DownsamplingError.couldNotDownsampleImage
    }

    guard let imageDestination =
      CGImageDestinationCreateWithURL(
        targetURL as CFURL,
        UTType.jpeg.identifier as CFString,
        1,
        nil
      )
    else {
      throw DownsamplingError.couldNotCreateImageDestination
    }

    let destinationProperties = [
      kCGImageDestinationLossyCompressionQuality: compressionRatio,
    ] as CFDictionary

    CGImageDestinationAddImage(imageDestination, thumbnail, destinationProperties)
    CGImageDestinationFinalize(imageDestination)
  }

  func prose_thumbnail(maxPixelSize: Int) -> CGImage? {
    let downsampleOptions = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
    ] as CFDictionary

    return CGImageSourceCreateThumbnailAtIndex(self, 0, downsampleOptions)
  }
}

public extension CGImage {
  func prose_downsampled(maxPixelSize: Int) throws -> CGImage {
    let imageSize = CGSize(
      width: self.width,
      height: self.height
    )

    guard Int(max(imageSize.width, imageSize.height)) > maxPixelSize else {
      return self
    }

    let newSize: CGSize
    switch imageSize {
    case _ where imageSize.width > imageSize.height:
      newSize = CGSize(
        width: CGFloat(maxPixelSize),
        height: imageSize.height / imageSize.width * CGFloat(maxPixelSize)
      )
    default:
      newSize = CGSize(
        width: imageSize.width / imageSize.height * CGFloat(maxPixelSize),
        height: CGFloat(maxPixelSize)
      )
    }

    guard let colorSpace = self.colorSpace else {
      throw DownsamplingError.invalidInputImage
    }

    guard let context = CGContext(
      data: nil,
      width: Int(newSize.width),
      height: Int(newSize.height),
      bitsPerComponent: self.bitsPerComponent,
      bytesPerRow: self.bytesPerRow,
      space: colorSpace,
      bitmapInfo: self.alphaInfo.rawValue
    ) else {
      throw DownsamplingError.couldNotCreateImageDestination
    }

    context.interpolationQuality = .high
    context.draw(self, in: CGRect(origin: .zero, size: newSize))

    guard let image = context.makeImage() else {
      throw DownsamplingError.couldNotFinalizeImage
    }

    return image
  }

  func prose_jpegData(compressionQuality: Float) -> Data? {
    guard let buffer = CFDataCreateMutable(nil, 0) else {
      return nil
    }

    guard let imageDestination =
      CGImageDestinationCreateWithData(buffer, UTType.jpeg.identifier as CFString, 1, nil)
    else {
      return nil
    }

    let destinationProperties = [
      kCGImageDestinationLossyCompressionQuality: compressionQuality,
    ] as CFDictionary

    CGImageDestinationAddImage(imageDestination, self, destinationProperties)
    CGImageDestinationFinalize(imageDestination)

    return buffer as Data
  }
}
