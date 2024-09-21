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
    private var expiryDate: Date

    var bottomInfoItems: [String] {
        return [amountToPayString, ibanString, expiryDateString]
    }
    var rightBarButtonAction: (() -> Void)?

    init(originalImages: [UIImage],
         amountToPay: Price,
         iban: String,
         expiryDate: Date) {
        self.originalImages = originalImages
        self.amountToPay = amountToPay
        self.iban = iban
        self.expiryDate = expiryDate
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

    var expiryDateString: String {
        let localizableText = "ginibank.transactionDocs.preview.expiryDate"
        let localizedString = NSLocalizedStringPreferredGiniBankFormat(localizableText,
                                                            comment: "Expiry date")
        return String.concatenateWithSeparator(localizedString,
                                               expiryDate.currentShortString)
    }
}
