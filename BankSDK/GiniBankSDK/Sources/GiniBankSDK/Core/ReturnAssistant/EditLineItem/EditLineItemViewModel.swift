//
//  EditLineItemViewModel.swift
//  
//
//  Created by David Vizaknai on 08.03.2023.
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
        lineItem.name = name
        lineItem.price = Price(value: price, currencyCode: currency)
        lineItem.quantity = quantity
        delegate?.didSave(lineItem: lineItem, on: self)
    }

    func didTapCancel() {
        delegate?.didCancel(on: self)
    }
}
