//
//  SkontoAlertFactory.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoAlertFactory {
    private let viewModel: SkontoViewModel

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
    }

    private var edgeCaseMessage: String? {
        switch viewModel.edgeCase {
        case .expired:
            let text = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.edgecase.expired.alert.title",
                                                                         comment: "You could have paid this...")
            return String.localizedStringWithFormat(text, viewModel.formattedPercentageDiscounted)
        case .paymentToday:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.edgecase.today.alert.title",
                                                            comment: "A discount is indicated on this invoice...")
        case .payByCash:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.infobanner.edgecase.cash.alert.title",
                                                            comment: "A discount is indicated on this invoice...")
        default:
            return nil
        }
    }

    func createEdgeCaseAlert() -> UIAlertController? {
        guard let message = edgeCaseMessage else {
            return nil
        }

        let alert = UIAlertController(title: message,
                                      message: "",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.alert.ok",
                                                                                     comment: "OK"),
                                     style: .default)
        alert.addAction(okAction)
        return alert
    }
}
