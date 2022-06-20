//
//  ImageAsset+URL.swift
//  Prose
//
//  Created by Rémi Bardon on 20/06/2022.
//

import Foundation

public extension ImageAsset {
    var customURL: URL? {
        var components = URLComponents()
        components.scheme = "asset"
        components.path = Bundle.fixedModule.bundlePath
        components.queryItems = [
            .init(name: "imageName", value: self.name),
        ]
        return components.url
    }
}
