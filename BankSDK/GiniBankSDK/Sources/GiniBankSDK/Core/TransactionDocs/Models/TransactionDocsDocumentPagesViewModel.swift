//
//  TransactionDocsDocumentPagesViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class TransactionDocsDocumentPagesViewModel: DocumentPagesViewModelProtocol {
    private let originalImages: [UIImage]
    private var amountToPay: Price
    private var iban: String
    private var transactionProcessed: Bool = false
    private(set) var bottomInfoItems: [String] = []

    var rightBarButtonAction: (() -> Void)?

    init(originalImages: [UIImage],
         extractions: TransactionDocsExtractions,
         transactionProcessed: Bool = false) {
        self.originalImages = originalImages
        self.amountToPay = extractions.amountToPay
        self.iban = extractions.iban
        self.transactionProcessed = transactionProcessed

        if amountToPay.value != 0 {
            bottomInfoItems.append(amountToPayString)
        }
        if !iban.isEmpty {
            bottomInfoItems.append(ibanString)
        }
    }

    func imagesForDisplay() -> [UIImage] {
        return originalImages
    }

    var amountToPayString: String {
        let localizableText = transactionProcessed
        ? "ginibank.transactionDocs.preview.amount"
        : "ginibank.transactionDocs.preview.amountToPay"
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
