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

    typealias FilterCount = [FilterOptions: Int]

    @Published var activeFilter: FilterOptions = .all
    @Published var filterCount: FilterCount = [FilterOptions.all: 0, FilterOptions.open: 0, FilterOptions.unpaid: 0, FilterOptions.reimbursed: 0]

    @Published var thisMonthList: [InvoiceItemCellViewModel] = []
    @Published var lastMonthList: [InvoiceItemCellViewModel] = []
    @Published var infoBannerShowing: Bool = false
    private var infoBannerAlreadyShown = false

    private var dataModel: InvoiceListDataModel

    init(dataModel: InvoiceListDataModel) {
        self.dataModel = dataModel

        dataModel.updateList = { [weak self] in
            guard let self = self else { return }
            self.updateFilter(self.activeFilter)
            self.updateFilterCount()
        }

        dataModel.updateInfoBannerVisibility = { [weak self] visibility in
            guard let self = self else { return }
            if !self.infoBannerAlreadyShown {
                self.infoBannerShowing = visibility
            }
        }

        updateFilterCount()
    }

    func updateFilterCount() {
        filterCount[.all] = 0 // This filter should not show the count
        filterCount[.unpaid] = dataModel.invoiceList.filter { !$0.paid }.count
        filterCount[.open] = dataModel.invoiceList.filter { $0.reimbursed != .reimbursed || !$0.paid }.count
        filterCount[.reimbursed] = dataModel.invoiceList.filter { $0.reimbursed == .reimbursed }.count
    }

    func updateFilter(_ filter: FilterOptions) {
        activeFilter = filter
        updateThisMonthList()
        updateLastMonthList()
    }

    func didSelectInvoice(with id: String) {
        delegate?.didSelectInvoice(with: id)
    }

    func viewDidDissapear() {
        if infoBannerShowing {
            infoBannerAlreadyShown = true
            infoBannerShowing = false
        }
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

