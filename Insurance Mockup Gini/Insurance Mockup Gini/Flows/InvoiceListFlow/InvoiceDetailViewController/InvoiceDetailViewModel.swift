//
//  InvoiceDetailViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import Foundation
import SwiftUI
import GiniHealthAPILibrary
import GiniHealthSDK

protocol InvoiceDetailViewModelDelegate: AnyObject {
    func didTapBack()
    func didSelectPay(invoice: Invoice)
    func didSelectShowReimbursmentDoc()
    func didSelectDocument(_ image: Image)
}

final class InvoiceDetailViewModel: ObservableObject {
    var companyName: String { return invoice.invoiceTitle }
    var amountWithCurrency: String { return "\(invoice.price) \(invoice.currency)" }
    var price: Double { return invoice.price }
    var creationDate: String { return invoice.creationDate.getFormattedDate(format: "dd MMMM, yyyy") }
    var dueDate: String { return invoice.dueDate.getFormattedDate(format: "dd MMMM, yyyy") }
    var iban: String { return invoice.iban }
    var numberOfDaysUntilDue: Int { return Int((invoice.dueDate - Date()) / (24*60*60)) }
    var reimbursmentStatus: ReimbursmentState { return invoice.reimbursmentStatus }
    var iconTitle = "icon_dentist"
    var adress = "Musterstrasse 11, 1234 Musterstadt"
    var description = "Prophylaxe"
    var paid: Bool { return invoice.paid }
    var result: [Extraction] { return invoice.extractions }
    var document: Document? { return invoice.document }

    var invoiceHeaderViewModel: InvoiceDetailHeaderViewModel
    var invoiceDetailListViewModel: InvoiceDetailListViewModel
    @Published var images = [Image]()

    private var invoice: Invoice

    weak var delegate: InvoiceDetailViewModelDelegate?

    init(invoice: Invoice, giniHealth: GiniHealth) {
        self.invoice = invoice
        invoiceHeaderViewModel = InvoiceDetailHeaderViewModel(invoice: invoice)
        invoiceDetailListViewModel = InvoiceDetailListViewModel(invoice: invoice)

        images = [Image("invoice1"), Image("invoice2")]
//        DocumentImageFetcher.fetchDocumentPreviews(for: invoice.document, with: giniHealth) { [weak self] images in
//            self?.images = images.map({ Image(uiImage: $0) })
//        }
    }

    func didTapBack() {
        delegate?.didTapBack()
    }

    func didSelectPay() {
        delegate?.didSelectPay(invoice: invoice)
    }

    func didSelectShowReimbursmentDoc() {
        delegate?.didSelectShowReimbursmentDoc()
    }

    func didSelectDocument(_ image: Image) {
        delegate?.didSelectDocument(image)
    }
}
