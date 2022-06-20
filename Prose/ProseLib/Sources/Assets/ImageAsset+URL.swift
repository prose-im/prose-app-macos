//
//  ImageAsset+URL.swift
//  Prose
//
//  Created by Rémi Bardon on 20/06/2022.
//

import Foundation

// TODO: [Rémi Bardon] Here is probably not the right place to put this function, we should move it somewhere else.
public func assetData(from url: URL) -> (String, Bundle?)? {
    guard url.scheme == "asset" else { return nil }
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
    
    let query = components.queryItems ?? []
    components.queryItems = nil
    
    guard let imageName = query.first(where: { $0.name == "imageName" })?.value else { return nil }
    
    return (imageName, Bundle(path: components.path))
}
