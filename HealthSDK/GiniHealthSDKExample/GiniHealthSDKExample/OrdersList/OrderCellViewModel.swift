//
//  OrderCellViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import Foundation
import GiniUtilites
import UIKit

final class OrderCellViewModel {
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private var order: Order

    init(_ order: Order) {
        self.order = order
    }
    
    var idText: String? {
        order.id
    }
    
    var recipientNameText: String {
        order.recipient
    }
    
    var amountToPayText: String {
        Price(extractionString: order.amountToPay)?.string ?? ""
    }

    var ibanText: String {
        order.iban
    }
    
    var expirationDateText: String? {
        guard let date = order.expirationDate as Date? else {
            return nil
        }
        
        return OrderCellViewModel.formatter.string(from: date)
    }

    var isRecipientLabelHidden: Bool {
        recipientNameText.isEmpty
    }
}
