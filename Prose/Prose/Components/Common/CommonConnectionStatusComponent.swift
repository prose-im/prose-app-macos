//
//  CommonConnectionStatusComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/11/21.
//

import SwiftUI

enum ConnectionStatus {
    case disconnected
    case connected
    
    func toFillColor() -> Color {
        switch self {
        case .connected:
            return .stateGreenLight
        default:
            return .stateGreyLight
        }
    }
}

struct CommonConnectionStatusComponent: View {
    var status: ConnectionStatus = .disconnected
    var size: CGFloat = 10.0
    
    var body: some View {
        Circle()
            .fill(status.toFillColor())
            .frame(width: size, height: size)
    }
}

struct CommonConnectionStatusComponent_Previews: PreviewProvider {
    static var previews: some View {
        CommonConnectionStatusComponent(
            status: .connected
        )
    }
}
