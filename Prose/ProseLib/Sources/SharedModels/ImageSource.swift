//
//  ImageSource.swift
//  Prose
//
//  Created by Rémi Bardon on 17/06/2022.
//

import SwiftUI

public enum ImageSource: Hashable {
    case placeholder, asset(String, bundle: Bundle), symbol(String), url(URL), nsImage(NSImage)

    @ViewBuilder
    public var image: some View {
        switch self {
        case .placeholder:
            Self.placeholderImage
        case let .asset(assetName, bundle):
            Image(assetName, bundle: bundle)
        case let .symbol(name):
            Image(systemName: name)
        case let .url(url):
            AsyncImage(url: url) { image in
                image
            } placeholder: {
                Color.primary.opacity(0.125)
            }
        case let .nsImage(nsImage):
            Image(nsImage: nsImage)
        }
    }

    @ViewBuilder
    public var resizableImage: some View {
        switch self {
        case .placeholder:
            Self.placeholderImage
        case let .asset(assetName, bundle):
            Image(assetName, bundle: bundle).resizable()
        case let .symbol(name):
            Image(systemName: name).resizable()
        case let .url(url):
            AsyncImage(url: url) { image in
                image.resizable()
            } placeholder: {
                Self.placeholderImage
            }
        case let .nsImage(nsImage):
            Image(nsImage: nsImage).resizable()
        }
    }

    private static var placeholderImage: some View {
        Color.primary.opacity(0.125)
    }
}
