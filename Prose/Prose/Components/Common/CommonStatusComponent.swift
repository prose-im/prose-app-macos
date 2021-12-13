//
//  CommonStatusComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 11/28/21.
//

import SwiftUI

enum Status {
    case offline
    case online
    
    func toFillColor() -> Optional<Color> {
        switch self {
        case .online:
            return .some(.stateGreen)
        default:
            return .none
        }
    }
    
    func toStrokeColor() -> Optional<Color> {
        switch self {
        case .online:
            return .none
        default:
            return .some(.stateGrey)
        }
    }
}

struct CommonStatusComponent: View {
    var status: Status = .offline
    var size: CGFloat = 8.0
    
    var body: some View {
        if let fillColor = status.toFillColor() {
            Circle()
                .fill(fillColor)
                .frame(width: size, height: size)
        } else if let strokeColor = status.toStrokeColor() {
            Circle()
                .strokeBorder(strokeColor, lineWidth: 1)
                .frame(width: size, height: size)
        } else {
            Circle()
                .frame(width: size, height: size)
        }
    }
}

struct CommonStatusComponent_Previews: PreviewProvider {
    static var previews: some View {
        CommonStatusComponent(
            status: .online
        )
    }
}
