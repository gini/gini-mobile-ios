//
//  InvoiceDetailViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 24.03.2022.
//

import Foundation
import Combine
import SwiftUI
import GiniHealthAPILibrary
import GiniHealthSDK

protocol InvoiceDetailViewModelDelegate: AnyObject {
    func didTapBack()
    func didSelectPay(invoice: Invoice)
    func didSelectShowReimbursmentDoc()
    func didSelectSubmitForClaim(onInvoiceWith id: String)
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
    var iconTitle = "teeth_icon"
    var adress = "Musterstrasse 11, 1234 Musterstadt"
    var description: String { return invoice.description }
    var paid: Bool { return invoice.paid }
    var result: [Extraction] { return invoice.extractions }
    var document: Document? { return invoice.document }

    var selectedImage = PassthroughSubject<Image, Never>()

    var invoiceHeaderViewModel: InvoiceDetailHeaderViewModel
    var invoiceDetailListViewModel: InvoiceDetailListViewModel
    @Published var images = [Data]()

    private var invoice: Invoice

    var disposeBag = [AnyCancellable]()
    weak var delegate: InvoiceDetailViewModelDelegate?

    init(invoice: Invoice, giniHealth: GiniHealth) {
        self.invoice = invoice
        invoiceHeaderViewModel = InvoiceDetailHeaderViewModel(invoice: invoice)
        invoiceDetailListViewModel = InvoiceDetailListViewModel(invoice: invoice)

        DocumentImageFetcher.fetchDocumentPreviews(for: invoice.document, with: giniHealth) { [weak self] images in
            // This if is just for mocking data
            if images.count == 0 {
                let imageNames = ["invoice1", "invoice2"]
                imageNames.forEach { imageName in
                    if let uiImage = UIImage(named: imageName), let imageData = uiImage.jpegData(compressionQuality: 1) {
                        self?.images.append(imageData)
                    }
                }
            } else {
                self?.images = images
            }
        }

        selectedImage.sink { [weak self] image in
            self?.didSelectDocument(image)
        }.store(in: &disposeBag)
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

    func didSelectSubmitForClaim() {
        invoice.reimbursmentStatus = .sent
        delegate?.didSelectSubmitForClaim(onInvoiceWith: invoice.invoiceID)
        objectWillChange.send()
    }

    func didSelectDocument(_ image: Image) {
        delegate?.didSelectDocument(image)
    }
}
