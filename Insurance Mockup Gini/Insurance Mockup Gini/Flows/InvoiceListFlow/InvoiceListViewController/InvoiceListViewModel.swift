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
    @Published var infoBannerShowing: Bool = false

    private var dataModel: InvoiceListDataModel

    init(dataModel: InvoiceListDataModel) {
        self.dataModel = dataModel

        dataModel.updateList = { [weak self] in
            guard let self = self else { return }
            self.updateFilter(self.activeFilter)
        }

        dataModel.updateInfoBannerVisibility = { [weak self] visibility in
            self?.infoBannerShowing = visibility
        }
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
            thisMonthList = dataModel.invoiceList.filter({ InvoiceListViewModel.isDateInThisMonth($0.creationDate) })
        case .open:
            thisMonthList = dataModel.invoiceList.filter({ InvoiceListViewModel.isDateInThisMonth($0.creationDate) }).filter { $0.reimbursed != .reimbursed || !$0.paid }
        case .unpaid:
            thisMonthList = dataModel.invoiceList.filter({ InvoiceListViewModel.isDateInThisMonth($0.creationDate) }).filter { $0.paid == false }
        case .reimbursed:
            thisMonthList = dataModel.invoiceList.filter({ InvoiceListViewModel.isDateInThisMonth($0.creationDate) }).filter { $0.reimbursed == .reimbursed }
        }
    }

    private func updateLastMonthList() {
        switch activeFilter {
        case .all:
            lastMonthList = dataModel.invoiceList.filter({ !InvoiceListViewModel.isDateInThisMonth($0.creationDate) })
        case .open:
            lastMonthList = dataModel.invoiceList.filter({ !InvoiceListViewModel.isDateInThisMonth($0.creationDate) }).filter { $0.reimbursed != .reimbursed || !$0.paid }
        case .unpaid:
            lastMonthList = dataModel.invoiceList.filter({ !InvoiceListViewModel.isDateInThisMonth($0.creationDate) }).filter { $0.paid == false }
        case .reimbursed:
            lastMonthList = dataModel.invoiceList.filter({ !InvoiceListViewModel.isDateInThisMonth($0.creationDate) }).filter { $0.reimbursed == .reimbursed }
        }
    }

    static func isDateInThisMonth(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
}

