//
// This file is part of prose-app-macos.
// Copyright (c) 2022 Prose Foundation
//

import Assets
import Foundation
import SwiftUI

public struct AvatarImage: Equatable {
  public let url: URL?
  // let initials: String

  public init(url: URL?) {
    self.url = url
  }
}

public extension AvatarImage {
  static var placeholder: AvatarImage {
    AvatarImage(url: nil)
  }
}

public struct Avatar: View {
  private let avatar: AvatarImage
  private let size: CGFloat
  private let cornerRadius: CGFloat

  public var shape: some InsettableShape {
    RoundedRectangle(cornerRadius: self.cornerRadius)
  }

  public init(
    _ avatar: AvatarImage,
    size: CGFloat,
    cornerRadius: CGFloat = 4
  ) {
    self.avatar = avatar
    self.size = size
    self.cornerRadius = cornerRadius
  }

  init(_ url: URL?, size: CGFloat) {
    self.init(AvatarImage(url: url), size: size)
  }

  public var body: some View {
    let shape = self.shape
    self.image()
      .scaledToFill()
      .frame(width: self.size, height: self.size)
      .background(Colors.Border.secondary.color)
      .clipShape(shape)
      .overlay {
        shape
          .strokeBorder(Color(nsColor: .separatorColor))
      }
  }

  @ViewBuilder
  private func image() -> some View {
    if let assetData = self.avatar.url.flatMap(Assets.assetData) {
      Image(assetData.0, bundle: assetData.1).resizable()
    } else {
      AsyncImage(url: self.avatar.url) { image in
        image.resizable()
      } placeholder: {
        Color.primary.opacity(0.125)
      }
    }
  }
}

// MARK: - Previews

#if DEBUG
  import PreviewAssets

  struct Avatar_Previews: PreviewProvider {
    private struct Preview: View {
      var body: some View {
        VStack {
          Avatar(PreviewAsset.Avatars.valerian.customURL, size: 48)
          Avatar(PreviewAsset.Avatars.valerian.customURL, size: 24)
        }
        .padding()
        .previewLayout(.sizeThatFits)
      }
    }

    static var previews: some View {
      Preview()
        .preferredColorScheme(.light)
        .previewDisplayName("Light mode")
      Preview()
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark mode")
      Preview()
        .redacted(reason: .placeholder)
        .previewDisplayName("Placeholder")
    }
  }
#endif
