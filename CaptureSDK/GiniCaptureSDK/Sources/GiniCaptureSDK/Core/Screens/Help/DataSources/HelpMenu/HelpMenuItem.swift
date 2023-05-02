//
//  HelpMenuItem.swift
//  
//
//  Created by Krzysztof Kryniecki on 02/08/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
* HelpMenuItem is an enum that defines different options that can be displayed on the help screen.
*
* - noResultsTips: displays tips for when no results are returned.
* - openWithTutorial: displays a tutorial on how to use the `open with`functionality
* - supportedFormats: displays a list of supported formats.
* - custom(String, UIViewController): allows for the creation of a custom option, with a title and a corresponding UIViewController.
*/

public enum HelpMenuItem {
    case noResultsTips
    case openWithTutorial
    case supportedFormats
    case custom(String, UIViewController)

    // The title of the HelpMenuItems
    var title: String {
        switch self {
        case .noResultsTips:
            return NSLocalizedStringPreferredFormat("ginicapture.help.menu.tips", comment: "Tips Menu Item")
        case .openWithTutorial:
            return NSLocalizedStringPreferredFormat("ginicapture.help.menu.import", comment: "Import Menu Item")
        case .supportedFormats:
            return NSLocalizedStringPreferredFormat("ginicapture.help.menu.formats", comment: "Format Menu Item")
        case .custom(let title, _):
            return title
        }
    }
}
