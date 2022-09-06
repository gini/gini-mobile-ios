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
