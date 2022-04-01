//
//  String+Extension.swift
//  Prose
//
//  Created by Valerian Saliou on 11/24/21.
//

import SwiftUI

public extension String {
    func localized(withComment comment: String? = nil, withFormat format: String? = nil) -> String {
        let text = NSLocalizedString(self, comment: comment ?? "")
        
        // Apply formatting? (return formatted text)
        if format != nil {
            return String.localizedStringWithFormat(text, format!)
        }
        
        // Return barebone text (non-formatted)
        return text
    }
}
