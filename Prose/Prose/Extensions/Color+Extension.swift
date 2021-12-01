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
        return Color(red: 0 / 255.0, green: 171.0 / 255.0, blue: 126.0 / 255.0)
    }
    
    public static var stateBlue: Color {
        return Color(red: 0 / 255.0, green: 98.0 / 255.0, blue: 233.0 / 255.0)
    }
    
    public static var stateGrey: Color {
        return Color(red: 121.0 / 255.0, green: 121.0 / 255.0, blue: 121.0 / 255.0)
    }
    
    // Borders
    public static var borderPrimary: Color {
        return Color(red: 131.0 / 255.0, green: 131.0 / 255.0, blue: 131.0 / 255.0)
    }
    
    public static var borderSecondary: Color {
        return Color(red: 189.0 / 255.0, green: 189.0 / 255.0, blue: 189.0 / 255.0)
    }
    
    public static var borderTertiary: Color {
        return Color(red: 230.0 / 255.0, green: 230.0 / 255.0, blue: 230.0 / 255.0)
    }
    
    // Texts
    public static var textPrimary: Color {
        return Color(red: 35.0 / 255.0, green: 37.0 / 255.0, blue: 38.0 / 255.0)
    }
    
    public static var textPrimaryLight: Color {
        return Color(red: 77.0 / 255.0, green: 77.0 / 255.0, blue: 77.0 / 255.0)
    }
    
    public static var textSecondary: Color {
        return Color(red: 121.0 / 255.0, green: 121.0 / 255.0, blue: 121.0 / 255.0)
    }
    
    public static var textSecondaryLight: Color {
        return Color(red: 128.0 / 255.0, green: 128.0 / 255.0, blue: 128.0 / 255.0)
    }
    
    // Buttons
    public static var buttonPrimary: Color {
        return Color(red: 0.0 / 255.0, green: 98.0 / 255.0, blue: 233.0 / 255.0)
    }
    
    public static var buttonActionGradientFromText: Color {
        return Color(red: 39.0 / 255.0, green: 125.0 / 255.0, blue: 255.0 / 255.0)
    }
    
    public static var buttonActionGradientToText: Color {
        return Color(red: 1.0 / 255.0, green: 100.0 / 255.0, blue: 255.0 / 255.0)
    }
    
    public static var buttonActionText: Color {
        return Color(red: 0.0 / 255.0, green: 98.0 / 255.0, blue: 233.0 / 255.0)
    }
    
    public static var buttonActionShadow: Color {
        return Color(red: 0.0 / 255.0, green: 93.0 / 255.0, blue: 233.0 / 255.0)
    }
}
