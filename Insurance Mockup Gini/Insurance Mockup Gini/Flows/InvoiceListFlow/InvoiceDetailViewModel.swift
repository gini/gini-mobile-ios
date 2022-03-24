//
//  InvoiceDetailViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import Foundation

protocol InvoiceDetailViewModelDelegate: AnyObject {
    func didTapBack()
}

final class InvoiceDetailViewModel {
    var invoiceDetailViewModel: NewInvoiceDetailViewModel
    weak var delegate: InvoiceDetailViewModelDelegate?

    init(invoiceDetail: NewInvoiceDetailViewModel) {
        self.invoiceDetailViewModel = invoiceDetail
    }

    func didTapBack() {
        delegate?.didTapBack()
    }
}
