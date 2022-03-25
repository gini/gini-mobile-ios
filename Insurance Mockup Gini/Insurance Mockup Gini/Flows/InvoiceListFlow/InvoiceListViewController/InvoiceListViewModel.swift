//
//  InvoiceListViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 25.03.2022.
//

import Foundation
import SwiftUI

protocol InvoiceListViewModelDelegate: AnyObject {
    func didSelectInvoice(with id: String)
}

final class InvoiceListViewModel: ObservableObject {
    weak var delegate: InvoiceListViewModelDelegate?

    @Published var activeFilter: FilterOptions = .all

    @Published var thisMonthList: [InvoiceItemCellViewModel] = []
    @Published var lastMonthList: [InvoiceItemCellViewModel] = []

    private var dataModel: InvoiceListDataModel

    init(dataModel: InvoiceListDataModel) {
        self.dataModel = dataModel
    }

    func updateFilter(_ filter: FilterOptions) {
        activeFilter = filter
        updateThisMonthList()
        updateLastMonthList()
    }

    func didSelectInvoice(with id: String) {
        delegate?.didSelectInvoice(with: id)
    }

    // MARK: - Private

    private func updateThisMonthList() {
        switch activeFilter {
        case .all:
            thisMonthList = dataModel.invoiceList
        case .open:
            thisMonthList = dataModel.invoiceList.filter { $0.reimbursed == .notSent }
        case .unpaid:
            thisMonthList = dataModel.invoiceList.filter { $0.paid == false }
        case .reimbursed:
            thisMonthList = dataModel.invoiceList.filter { $0.reimbursed == .reimbursed }
        }
    }

    private func updateLastMonthList() {
        switch activeFilter {
        case .all:
            lastMonthList = dataModel.oldInvoiceList
        case .open:
            lastMonthList = dataModel.oldInvoiceList.filter { $0.reimbursed == .notSent }
        case .unpaid:
            lastMonthList = dataModel.oldInvoiceList.filter { $0.paid == false }
        case .reimbursed:
            lastMonthList = dataModel.oldInvoiceList.filter { $0.reimbursed == .reimbursed }
        }
    }
}

