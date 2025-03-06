//
//  Transaction.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation
import GiniCaptureSDK

struct Transaction: Codable {
    let identifier: String
    let date: Date
    let paiedAmount: String
    let paymentPurpose: String
    let paymentRecipient: String
    let iban: String?
    let paymentReference: String
    var attachments: [Attachment]

    // Initialize with a unique identifier
    init(
        identifier: String = UUID().uuidString, // Generate a random unique identifier if not provided
        date: Date,
        paiedAmount: String,
        paymentPurpose: String,
        paymentRecipient: String,
        iban: String?,
        paymentReference: String,
        attachments: [Attachment]
    ) {
        self.identifier = identifier
        self.date = date
        self.paiedAmount = paiedAmount
        self.paymentPurpose = paymentPurpose
        self.paymentRecipient = paymentRecipient
        self.iban = iban
        self.paymentReference = paymentReference
        self.attachments = attachments
    }

    var transactionInfo: [TransactionInfo] {
        [
            TransactionInfo(title: NSLocalizedStringPreferredFormat("transaction.details.date",
                                                                    fallbackKey: "Transaction Date",
                                                                    comment: "Transaction Date",
                                                                    isCustomizable: true),
                            value: date.toFormattedString()),
            TransactionInfo(title: NSLocalizedStringPreferredFormat("transaction.details.amount",
                                                                    fallbackKey: "Amount",
                                                                    comment: "Amount",
                                                                    isCustomizable: true),
                            value: paiedAmount),
            TransactionInfo(title: NSLocalizedStringPreferredFormat("transaction.details.purpose",
                                                                    fallbackKey: "Payment Purpose",
                                                                    comment: "Payment Purpose",
                                                                    isCustomizable: true),
                            value: paymentPurpose),
            TransactionInfo(title: NSLocalizedStringPreferredFormat("transaction.details.recipient",
                                                                    fallbackKey: "Recipient",
                                                                    comment: "Recipient",
                                                                    isCustomizable: true),
                            value: paymentRecipient),
            iban.map { TransactionInfo(title: NSLocalizedStringPreferredFormat("transaction.details.iban",
                                                                               fallbackKey: "IBAN",
                                                                               comment: "IBAN",
                                                                               isCustomizable: true),
                                       value: $0) },
            TransactionInfo(title: NSLocalizedStringPreferredFormat("transaction.details.reference",
                                                                    fallbackKey: "Reference",
                                                                    comment: "Reference",
                                                                    isCustomizable: true),
                            value: paymentReference)
        ]
            .compactMap { $0 } // Remove nil values
            .filter { !$0.value.isEmpty } // Include only non-empty values
    }
}
