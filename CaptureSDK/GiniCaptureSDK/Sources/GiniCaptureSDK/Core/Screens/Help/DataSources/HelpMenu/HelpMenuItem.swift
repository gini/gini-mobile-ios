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
            return .localized(resource: HelpStrings.menuFirstItemText)
        case .openWithTutorial:
            return .localized(resource: HelpStrings.menuSecondItemText)
        case .supportedFormats:
            return .localized(resource: HelpStrings.menuThirdItemText)
        case .custom(let title, _):
            return title
        }
    }
}
