//
//  NewInvoiceDetailViewModel.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 23.03.2022.
//

import UIKit
import Combine
import GiniHealthAPILibrary
import SwiftUI
import GiniHealthSDK


enum PaymentOptionSheetPosition: CGFloat, CaseIterable {
    case middle = 300, hidden = -100
}

protocol NewInvoiceDetailViewModelDelegate: AnyObject {
    func didTapPay(withExtraction extraction: [Extraction], document: Document?)
    func saveNewInvoice(invoice: Invoice, shouldShowConfirmation: Bool)
    func didTapSendInvoice()
    func didTapCancel()
    func didSelectDocument(_ image: Image)
}

class NewInvoiceDetailViewModel: ObservableObject {
    var companyName: String
    var amountWithCurrency: String
    var price: Double
    var creationDate: String
    var dueDate: String
    var iban: String
    var numberOfDaysUntilDue: Int
    var reimbursmentStatus: ReimbursmentState
    var iconTitle = "teeth_icon"
    var sheetViewModel = ButtonSheetViewModel()
    var adress = "Musterstrasse 11, 1234 Musterstadt"
    var description = "Prophylaxe"
    var paid: Bool
    var result: [Extraction]
    var document: Document?

    var invoiceHeaderViewModel: InvoiceDetailHeaderViewModel
    var invoiceDetailListViewModel: InvoiceDetailListViewModel

    private var invoice: Invoice
    private var healthSDK: GiniHealth

    @Published var paymentOptionSheetPosition: PaymentOptionSheetPosition = .hidden
    @Published var images = [Data]()

    var selectedImage = PassthroughSubject<Image, Never>()
    var disposeBag = [AnyCancellable]()
    
    weak var delegate: NewInvoiceDetailViewModelDelegate?

    init(invoice: Invoice, healthSDK: GiniHealth) {
        self.healthSDK = healthSDK
        self.invoice = invoice
        self.result = invoice.extractions
        self.document = invoice.document
        amountWithCurrency = "\(invoice.price) \(invoice.currency)"
        price = invoice.price
        companyName = invoice.invoiceTitle
        iban = invoice.iban
        creationDate = invoice.creationDate.getFormattedDate(format: "dd MMMM, yyyy")
        dueDate = invoice.dueDate.getFormattedDate(format: "dd MMMM, yyyy")
        paid = invoice.paid
        reimbursmentStatus = invoice.reimbursmentStatus
        invoiceHeaderViewModel = InvoiceDetailHeaderViewModel(invoice: invoice)
        invoiceDetailListViewModel = InvoiceDetailListViewModel(invoice: invoice)

        numberOfDaysUntilDue = Int((invoice.dueDate - Date()) / (24*60*60))
        sheetViewModel.delegate = self

        DocumentImageFetcher.fetchDocumentPreviews(for: document, with: healthSDK) { [weak self] dataImages in
            self?.images = dataImages
        }

        selectedImage.sink { [weak self] image in
            self?.delegate?.didSelectDocument(image)
        }.store(in: &disposeBag)
    }

    func didTapCancel() {
        delegate?.didTapCancel()
    }
}

extension NewInvoiceDetailViewModel: ButtonSheetViewModelDelegate {
    func didTapPayAndSave() {
        delegate?.saveNewInvoice(invoice: invoice, shouldShowConfirmation: false)
        delegate?.didTapPay(withExtraction: result, document: document)
    }

    func didTapPayAndSubmit() {
        invoice.reimbursmentStatus = .sent
        delegate?.saveNewInvoice(invoice: invoice, shouldShowConfirmation: false)
        delegate?.didTapPay(withExtraction: result, document: document)
    }

    func didTapSubmit() {
        invoice.reimbursmentStatus = .sent
        delegate?.saveNewInvoice(invoice: invoice, shouldShowConfirmation: false)
        delegate?.didTapSendInvoice()
    }

    func didTapSave() {
        delegate?.saveNewInvoice(invoice: invoice, shouldShowConfirmation: true)
    }
}
