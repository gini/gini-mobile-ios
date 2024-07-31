//
//  GiniImages.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

enum GiniImages: String {
    case calendar = "calendar"
    case checkmarkIcon = "checkmark_icon"
    case digitalInvoiceOnboarding = "digital_invoice_onboarding"
    case helpIcon1 = "help_icon_1"
    case helpIcon2 = "help_icon_2"
    case helpIcon3 = "help_icon_3"
    case infoMessageIcon = "info_message_icon"
    case quantityMinusIcon = "quantity_minus_icon"
    case quantityPlusIcon = "quantity_plus_icon"

    var image: UIImage? {
        return prefferedImage(named: rawValue)
    }
}
