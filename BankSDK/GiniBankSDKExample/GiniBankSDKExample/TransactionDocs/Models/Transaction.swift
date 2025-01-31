//
//  Transaction.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//


import Foundation

struct Transaction: Codable {
    let date: Date
    let paiedAmount: String
    let paymentPurpose: String
    let paymentRecipient: String
    let iban: String?
    let paymentReference: String
    let attachments: [Attachment]

    var transactionInfo: [TransactionInfo] {
        [
            TransactionInfo(title: NSLocalizedString("transaction.details.date",
                                                     comment: "Transaction Date"),
                            value: date.toFormattedString()),
            TransactionInfo(title: NSLocalizedString("transaction.details.amount",
                                                     comment: "Amount"),
                            value: paiedAmount),
            TransactionInfo(title: NSLocalizedString("transaction.details.purpose",
                                                     comment: "Payment Purpose"),
                            value: paymentPurpose),
            TransactionInfo(title: NSLocalizedString("transaction.details.recipient",
                                                     comment: "Recipient"),
                            value: paymentRecipient),
            iban.map { TransactionInfo(title: NSLocalizedString("transaction.details.iban",
                                                                comment: "IBAN"),
                                       value: $0) },
            TransactionInfo(title: NSLocalizedString("transaction.details.reference",
                                                     comment: "Reference"),
                            value: paymentReference)
        ]
            .compactMap { $0 } // Remove nil values
            .filter { !$0.value.isEmpty } // Include only non-empty values
    }
}
