//
//  SkontoHelpViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

struct SkontoHelpViewModel {
    let items: [SkontoHelpItem]

    init() {
        let item1 = SkontoHelpItem(
            icon: GiniImages.skontoHelpItem1.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item1",
                                                            comment: "Use your camera to capture invoices with cash discounts")
        )

        let item2 = SkontoHelpItem(
            icon: GiniImages.skontoHelpItem2.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item2",
                                                            comment: "Immediately identify discounted amounts and due dates")
        )

        let item3 = SkontoHelpItem(
            icon: GiniImages.skontoHelpItem3.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item3",
                                                            comment: "Approve or adjust payment details")
        )

        let item4 = SkontoHelpItem(
            icon: GiniImages.skontoHelpItem4.image,
            title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.help.content.item4",
                                                            comment: "Save money by paying promptly")
        )

        items = [item1, item2, item3, item4]
    }
}
