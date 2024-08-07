//
//  OrderCellViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniUtilites
import UIKit

final class OrderCellViewModel {
    private var order: Order

    init(_ order: Order) {
        self.order = order
    }
    
    var recipientNameText: String {
        order.recipient
    }
    
    var amountToPayText: String {
        if let amountToPayFormatted = Price(extractionString: order.amountToPay) {
            return amountToPayFormatted.string ?? ""
        }
        return ""
    }

    var ibanText: String {
        order.iban
    }

    var isRecipientLabelHidden: Bool {
        recipientNameText.isEmpty
    }
}
