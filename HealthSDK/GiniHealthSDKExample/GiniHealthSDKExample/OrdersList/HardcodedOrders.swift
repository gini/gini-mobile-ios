//
//  HardcodedOrdersControllerProtocol.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//



import Foundation
import GiniUtilites

protocol HardcodedOrdersControllerProtocol {
    var orders: [Order] { get }

    func updateOrder(updatedOrder: Order)
}

class Order: Codable {
    var amountToPay = ""
    var recipient = ""
    var iban = ""
    var purpose = ""
    var expirationDate: Date?

    var price: Price {
        Price(extractionString: amountToPay) ??
        Price(value: .zero, currencyCode: "€")
    }

    convenience init(amountToPay: String, recipient: String, iban: String, purpose: String) {
        self.init()
        self.amountToPay = amountToPay
        self.recipient = recipient
        self.iban = iban
        self.purpose = purpose
    }
}

final class HardcodedOrdersController: HardcodedOrdersControllerProtocol {

    private var ordersList: [Order] = [
        Order(amountToPay: "709.97:€", recipient: "OTTO GMBH & CO KG", iban: "DE75201207003100124444", purpose: "RF7411164022"),
        Order(amountToPay: "54.97:€", recipient: "Tchibo GmbH", iban: "DE14200800000816170700", purpose: "10020302020"),
        Order(amountToPay: "126.62:€", recipient: "Zalando SE", iban: "DE86210700200123010101", purpose: "938929192"),
        Order(amountToPay: "114.88:€", recipient: "bonprix Handelsgesellschaft mbH", iban: "DE68201207003100755555", purpose: "020329984871123"),
        Order(amountToPay: "80.13:€", recipient: "Klarna", iban: "DE13760700120500154000", purpose: "00425818528311423079")
    ]

    var orders: [Order] {
        ordersList
    }

    func updateOrder(updatedOrder: Order) {
        if let index = ordersList.firstIndex(where: { $0.iban == updatedOrder.iban }) {
            ordersList[index] = updatedOrder
        }
    }
}
