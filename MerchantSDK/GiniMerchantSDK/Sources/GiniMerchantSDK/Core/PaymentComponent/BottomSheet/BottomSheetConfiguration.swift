//
//  BottomSheetConfiguration.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

public struct BottomSheetConfiguration {
    let backgroundColor: UIColor
    let rectangleColor: UIColor
    let dimmingBackgroundColor: UIColor

    public init(backgroundColor: UIColor, rectangleColor: UIColor, dimmingBackgroundColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.rectangleColor = rectangleColor
        self.dimmingBackgroundColor = dimmingBackgroundColor
    }
}
