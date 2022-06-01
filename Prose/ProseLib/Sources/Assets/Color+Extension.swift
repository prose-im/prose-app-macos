//
//  Color+Extension.swift
//  Prose
//
//  Created by Valerian Saliou on 11/22/21.
//

import SwiftUI

public extension Color {
    // States
    static var stateGreen: Color {
        Color("state/green")
    }

    static var stateGreenLight: Color {
        Color("state/greenLight")
    }

    static var stateBlue: Color {
        Color("state/blue")
    }

    static var stateGrey: Color {
        Color("state/grey")
    }

    static var stateGreyLight: Color {
        Color("state/greyLight")
    }

    // Backgrounds
    static var backgroundMessage: Color {
        Color("background/message")
    }

    // Borders
    static var borderPrimary: Color {
        Color("border/primary")
    }

    static var borderSecondary: Color {
        Color("border/secondary")
    }

    static var borderTertiary: Color {
        Color("border/tertiary")
    }

    static var borderTertiaryLight: Color {
        Color("border/tertiaryLight")
    }

    // Texts
    static var textPrimary: Color {
        Color("text/primary")
    }

    static var textPrimaryLight: Color {
        Color("text/primaryLight")
    }

    static var textSecondary: Color {
        Color("text/secondary")
    }

    static var textSecondaryLight: Color {
        Color("text/secondaryLight")
    }

    // Buttons
    static var buttonPrimary: Color {
        Color("button/primary")
    }

    static var buttonActionGradientFromText: Color {
        Color("button/actionGradientFromText")
    }

    static var buttonActionGradientToText: Color {
        Color("button/actionGradientToText")
    }

    static var buttonActionText: Color {
        Color("button/actionText")
    }

    static var buttonActionShadow: Color {
        Color("button/actionShadow")
    }
}
