//
//  SkontoHelpViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

struct SkontoHelpViewModel {
    let items: [SkontoHelpItem] = [
        SkontoHelpItem(
            icon: GiniImages.skontoHelpItem1.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item1",
                                                            comment: "Use your camera to capture invoices with Skonto discounts")),
        SkontoHelpItem(
            icon: GiniImages.skontoHelpItem2.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item2",
                                                            comment: "Immediately identify discounted amounts and due dates")
        ),
        SkontoHelpItem(
            icon: GiniImages.skontoHelpItem3.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item3",
                                                            comment: "Approve or adjust payment details")
        ),
        SkontoHelpItem(
            icon: GiniImages.skontoHelpItem4.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item4",
                                                            comment: "Save money by paying promptly")
        )
    ]
}
