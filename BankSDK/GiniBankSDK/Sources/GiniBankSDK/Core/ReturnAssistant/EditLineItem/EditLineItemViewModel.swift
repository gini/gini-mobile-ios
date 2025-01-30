//
//  EditLineItemViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniCaptureSDK
import Foundation

protocol EditLineItemViewModelDelegate: AnyObject {
    func didSave(lineItem: DigitalInvoice.LineItem, on viewModel: EditLineItemViewModel)
    func didCancel(on viewModel: EditLineItemViewModel)
}

final class EditLineItemViewModel {
    weak var delegate: EditLineItemViewModelDelegate?
    private var lineItem: DigitalInvoice.LineItem
    private(set) var itemsChanged: [GiniLineItemAnalytics] = []

    var name: String? {
        return lineItem.name
    }

    var price: Decimal {
        return lineItem.price.value
    }

    var currency: String {
        return lineItem.price.currencyCode
    }

    var quantity: Int {
        return lineItem.quantity
    }

    let index: Int

    init(lineItem: DigitalInvoice.LineItem, index: Int) {
        self.lineItem = lineItem
        self.index = index
    }

    func didTapSave(name: String?, price: Decimal, currency: String, quantity: Int) {
        if name != lineItem.name {
            itemsChanged.append(GiniLineItemAnalytics.name)
        }
        lineItem.name = name

        if price != lineItem.price.value {
            itemsChanged.append(GiniLineItemAnalytics.price)
        }
        lineItem.price = Price(value: price, currencyCode: currency)
        if quantity != lineItem.quantity {
            itemsChanged.append(GiniLineItemAnalytics.quantity)
        }
        lineItem.quantity = quantity
        delegate?.didSave(lineItem: lineItem, on: self)
    }

    func didTapCancel() {
        delegate?.didCancel(on: self)
    }
}
