//
//  Color+Extension.swift
//  Prose
//
//  Created by Valerian Saliou on 11/22/21.
//

import SwiftUI

extension Color {
    // States
    public static var stateGreen: Color {
        return Color("state/green")
    }
    
    public static var stateGreenLight: Color {
        return Color("state/greenLight")
    }
    
    public static var stateBlue: Color {
        return Color("state/blue")
    }
    
    public static var stateGrey: Color {
        return Color("state/grey")
    }
    
    public static var stateGreyLight: Color {
        return Color("state/greyLight")
    }
    
    // Backgrounds
    public static var backgroundMessage: Color {
        return Color("background/message")
    }
    
    // Borders
    public static var borderPrimary: Color {
        return Color("border/primary")
    }
    
    public static var borderSecondary: Color {
        return Color("border/secondary")
    }
    
    public static var borderTertiary: Color {
        return Color("border/tertiary")
    }
    
    public static var borderTertiaryLight: Color {
        return Color("border/tertiaryLight")
    }
    
    // Texts
    public static var textPrimary: Color {
        return Color("text/primary")
    }
    
    public static var textPrimaryLight: Color {
        return Color("text/primaryLight")
    }
    
    public static var textSecondary: Color {
        return Color("text/secondary")
    }
    
    public static var textSecondaryLight: Color {
        return Color("text/secondaryLight")
    }
    
    // Buttons
    public static var buttonPrimary: Color {
        return Color("button/primary")
    }
    
    public static var buttonActionGradientFromText: Color {
        return Color("button/actionGradientFromText")
    }
    
    public static var buttonActionGradientToText: Color {
        return Color("button/actionGradientToText")
    }
    
    public static var buttonActionText: Color {
        return Color("button/actionText")
    }
    
    public static var buttonActionShadow: Color {
        return Color("button/actionShadow")
    }
}
