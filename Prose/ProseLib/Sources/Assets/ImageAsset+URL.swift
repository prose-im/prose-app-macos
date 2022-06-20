//
//  ImageAsset+URL.swift
//  Prose
//
//  Created by Rémi Bardon on 20/06/2022.
//

import Foundation

/// `PreviewAssets.ImageAsset.customURL` creates a custom URL for assets, using the `asset` scheme.
/// This function tries to parse an URL to check if it's an asset.
///
/// ```swift
/// let url: URL? = URL(string: "asset://path/to.bundle?imageName=some-image-asset")
/// if let assetData = url.flatMap(Assets.assetData) {
///     Image(assetData.0, bundle: assetData.1).resizable()
/// } else {
///     AsyncImage(url: url) { image in
///         image.resizable()
///     } placeholder: {
///         Color.primary.opacity(0.125)
///     }
/// }
/// ```
///
/// - Returns: If the URL references an asset, it returns the asset name (potentially namespaced)
///            and the optional `Bundle`. `nil` otherwise or if any error occured.
public func assetData(from url: URL) -> (String, Bundle?)? {
    guard url.scheme == "asset" else { return nil }
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }

    let query = components.queryItems ?? []
    components.queryItems = nil

    guard let imageName = query.first(where: { $0.name == "imageName" })?.value else { return nil }

    return (imageName, Bundle(path: components.path))
}
