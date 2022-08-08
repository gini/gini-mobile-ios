//
//  HelpMenuItem.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

public enum HelpMenuItem {
    case noResultsTips
    case openWithTutorial
    case supportedFormats
    case custom(String, UIViewController)
    
    var title: String {
        switch self {
        case .noResultsTips:
            return NSLocalizedString("ginicapture.help.menu.firstItem", bundle: giniCaptureBundle(), comment: "")
        case .openWithTutorial:
            return NSLocalizedString("ginicapture.help.menu.secondItem", bundle: giniCaptureBundle(), comment: "")
        case .supportedFormats:
            return NSLocalizedString("ginicapture.help.menu.thirdItem", bundle: giniCaptureBundle(), comment: "")
        case .custom(let title, _):
            return title
        }
    }
}
