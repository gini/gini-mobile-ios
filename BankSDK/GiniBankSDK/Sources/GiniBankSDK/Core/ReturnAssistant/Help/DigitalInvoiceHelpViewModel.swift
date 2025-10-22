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
        let firstHelpSection = DigitalInvoiceHelpSection(icon: prefferedImage(named: "help_icon_1"),
                                                         title: Strings.firstHelpSectionTitle,
                                                         description: Strings.firstHelpSectionDescription)

        let secondHelpSection = DigitalInvoiceHelpSection(icon: prefferedImage(named: "help_icon_2"),
                                                          title: Strings.secondHelpSectionTitle,
                                                          description: Strings.secondHelpSectionDescription)

        let thirdHelpSection = DigitalInvoiceHelpSection(icon: prefferedImage(named: "help_icon_3"),
                                                         title: Strings.thirdHelpSectionTitle,
                                                         description: Strings.thirdHelpSectionDescription)

        helpSections = [firstHelpSection, secondHelpSection, thirdHelpSection]
    }

    private struct Strings {
        private static let baseKey = "ginibank.digitalinvoice.help"

        static let titleComment: String = "help title"
        static let descriptionComment: String = "help description"
        static let firstHelpSectionTitle = giniLocalized("ginibank.digitalinvoice.help.title1",
                                                         comment: Strings.titleComment)
        static let firstHelpSectionDescription = giniLocalized("ginibank.digitalinvoice.help.description1",
                                                               comment: Strings.descriptionComment)
        static let secondHelpSectionTitle = giniLocalized("ginibank.digitalinvoice.help.title2",
                                                          comment: Strings.titleComment)
        static let secondHelpSectionDescription = giniLocalized("ginibank.digitalinvoice.help.description2",
                                                                comment: Strings.descriptionComment)
        static let thirdHelpSectionTitle = giniLocalized("ginibank.digitalinvoice.help.title3",
                                                         comment: Strings.titleComment)
        static let thirdHelpSectionDescription = giniLocalized("ginibank.digitalinvoice.help.description3",
                                                               comment: Strings.descriptionComment)

    }
}
