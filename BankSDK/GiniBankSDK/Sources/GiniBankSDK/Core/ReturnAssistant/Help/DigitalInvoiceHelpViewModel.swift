//
//  DigitalInvoiceHelpViewModel.swift
//  
//
//  Created by David Vizaknai on 15.02.2023.
//

import UIKit

struct DigitalInvoiceHelpSection {
    let icon: UIImage?
    let title: String
    let description: String
}

struct DigitalInvoiceHelpViewModel {
    let helpSections: [DigitalInvoiceHelpSection]

    init() {
        let firstHelpSection = DigitalInvoiceHelpSection(
            icon: prefferedImage(named: "help_icon_1"),
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.title1",
                                                            comment: "help title"),
            description: NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.description1",
                                                                  comment: "help description"))

        let secondHelpSection = DigitalInvoiceHelpSection(
            icon: prefferedImage(named: "help_icon_2"),
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.title2",
                                                            comment: "help title"),
            description: NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.description2",
                                                                  comment: "help description"))

        let thirdHelpSection = DigitalInvoiceHelpSection(
            icon: prefferedImage(named: "help_icon_3"),
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.title3",
                                                            comment: "help title"),
            description: NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.help.description3",
                                                                  comment: "help description"))

        self.helpSections = [firstHelpSection, secondHelpSection, thirdHelpSection]
    }
}
