//
//  InvoiceListViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import Foundation

protocol InvoiceListViewModelDelegate: AnyObject {
    func didTapBack()
}

final class InvoiceListViewModel {
//    var invoiceDetailViewModel: NewInvoiceDetailViewModel
    weak var delegate: InvoiceDetailViewModelDelegate?

//    init() {
//
//    }

    func didTapBack() {
        delegate?.didTapBack()
    }
}

