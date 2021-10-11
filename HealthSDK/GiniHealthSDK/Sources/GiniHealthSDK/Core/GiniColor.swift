//
//  GiniColor.swift
//  GiniHealth
//
//  Created by Nadya Karaban on 30.03.21.
//

import UIKit

/**
 The `GiniColor` class allows to customize color for the light and the dark modes.
 */
@objc public class GiniColor : NSObject {
    var lightModeColor: UIColor
    var darkModeColor: UIColor
    
    /**
     Creates a GiniColor with the colors for the light and dark modes
     
     - parameter lightModeColor: color for the light mode
     - parameter darkModeColor: color for the dark mode
     */
    public init(lightModeColor: UIColor, darkModeColor: UIColor) {
        self.lightModeColor = lightModeColor
        self.darkModeColor = darkModeColor
    }
}
