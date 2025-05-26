//
//  GiniInputAccessoryViewConfiguration.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import UIKit

public struct GiniInputAccessoryViewConfiguration {

    let backgroundColor: UIColor
    let previousButtonImage: UIImage?
    let nextButtonImage: UIImage?
    let tintColor: UIColor
    let disabledTintColor: UIColor

    public init(backgroundColor: UIColor,
                previousButtonImage: UIImage?,
                nextButtonImage: UIImage?,
                tintColor: UIColor,
                disabledTintColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.previousButtonImage = previousButtonImage
        self.nextButtonImage = nextButtonImage
        self.tintColor = tintColor
        self.disabledTintColor = disabledTintColor
    }
}
