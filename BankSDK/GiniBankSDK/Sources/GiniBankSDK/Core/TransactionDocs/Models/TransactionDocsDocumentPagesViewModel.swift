//
//  TransactionDocsDocumentPagesViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

final class TransactionDocsDocumentPagesViewModel: DocumentPagesViewModelProtocol {
    private let originalImages: [UIImage]
    private var amountToPay: Price
    private var iban: String

    private(set) var bottomInfoItems: [String] = []
    var rightBarButtonAction: (() -> Void)?

    init(originalImages: [UIImage], extractions: TransactionDocsExtractions) {
        self.originalImages = originalImages
        self.amountToPay = extractions.amountToPay
        self.iban = extractions.iban
        if amountToPay.value != 0 {
            self.bottomInfoItems.append(amountToPayString)
        }
        if !iban.isEmpty {
            self.bottomInfoItems.append(ibanString)
        }
    }

    func imagesForDisplay() -> [UIImage] {
        return originalImages
    }

    var amountToPayString: String {
        let localizableText = "ginibank.transactionDocs.preview.amountToPay"
        let localizedString = NSLocalizedStringPreferredGiniBankFormat(localizableText,
                                                                       comment: "Amount to Pay")
        return String.concatenateWithSeparator(localizedString,
                                               amountToPay.localizedStringWithCurrencyCode ?? "")
    }

    var ibanString: String {
        let localizableText = "ginibank.transactionDocs.preview.iban"
        let localizedString = NSLocalizedStringPreferredGiniBankFormat(localizableText,
                                                                       comment: "IBAN")
        return String.concatenateWithSeparator(localizedString,
                                               iban)
    }
}
