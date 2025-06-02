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
    case chevronDown = "chevron_down"
    case chevronRight = "chevron_right"
    case chevronUp = "chevron_up"
    case invoicePlaceholderIcon = "invoice_placeholder_icon"
    case skontoHelpItem1 = "skonto_help_item1"
    case skontoHelpItem2 = "skonto_help_item2"
    case skontoHelpItem3 = "skonto_help_item3"
    case skontoHelpItem4 = "skonto_help_item4"
    case transactionDocsOptionsIcon = "transactionDocs_attached_document_options_icon"
    case transactionDocsFileIcon = "transactionDocs_attached_document_file_icon"
    case transactionDocsImageIcon = "transactionDocs_attached_image_icon"

    var image: UIImage? {
        return prefferedImage(named: rawValue)
    }
}
