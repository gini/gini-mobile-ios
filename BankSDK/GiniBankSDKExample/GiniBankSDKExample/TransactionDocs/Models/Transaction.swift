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
}
