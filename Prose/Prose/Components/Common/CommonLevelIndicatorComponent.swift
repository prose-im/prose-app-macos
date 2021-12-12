//
//  CommonLevelIndicatorComponent.swift
//  Prose
//
//  Created by Valerian Saliou on 12/12/21.
//

import Cocoa
import SwiftUI

struct CommonLevelIndicatorComponent: View {
    var minimumValue: Double = 0.0
    var maximumValue: Double = 1.0
    var warningValue: Double = 0.5
    var criticalValue: Double = 0.75
    var tickMarkFactor: Double = 6.0
    
    var currentValue: Double
    
    var body: some View {
        let indicator = NSLevelIndicator()
        
        // Configure bounds
        indicator.minValue = minimumValue * tickMarkFactor
        indicator.maxValue = maximumValue * tickMarkFactor
        indicator.warningValue = warningValue * tickMarkFactor
        indicator.criticalValue = criticalValue * tickMarkFactor
        
        // Apply value
        indicator.doubleValue = currentValue * tickMarkFactor
        
        return ViewWrap(indicator)
    }
}

struct CommonLevelIndicatorComponent_Previews: PreviewProvider {
    static var previews: some View {
        CommonLevelIndicatorComponent(
            currentValue: 0.4
        )
            .padding(10)
    }
}
