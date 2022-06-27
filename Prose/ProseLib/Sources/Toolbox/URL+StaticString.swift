//
//  URL+StaticString.swift
//  Prose
//
//  Created by Rémi Bardon on 27/01/2021.
//

import Foundation

public extension URL {
    /// Comes from [Constructing URLs in Swift](https://www.swiftbysundell.com/articles/constructing-urls-in-swift/#static-urls)
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}
