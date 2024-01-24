//
//  InvoicesListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary
import GiniCaptureSDK
import GiniBankAPILibrary
import GiniHealthSDK

struct DocumentWithExtractions: Codable {
    var documentID: String
    var amountToPay: String?
    var paymentDueDate: String?
    var recipient: String?
    var isPayable: Bool?
    
    init(documentID: String, extractionResult: GiniHealthAPILibrary.ExtractionResult) {
        self.documentID = documentID
        self.amountToPay = extractionResult.payment?.first?.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractionResult.extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractionResult.payment?.first?.first(where: {$0.name == "payment_recipient"})?.value
        self.isPayable = !(extractionResult.payment?.first?.first(where: {$0.name == "iban"})?.value.isEmpty ?? true)
    }
    
    init(documentID: String, extractions: [GiniBankAPILibrary.Extraction]) {
        self.documentID = documentID
        self.amountToPay = extractions.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractions.first(where: {$0.name == "payment_recipient"})?.value
        self.isPayable = !(extractions.first(where: {$0.name == "iban"})?.value.isEmpty ?? true)
    }
}

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private var documentService: GiniHealthAPILibrary.DefaultDocumentService
    var giniHealthConfiguration: GiniHealthConfiguration
    
    private let hardcodedInvoicesController: HardcodedInvoicesControllerProtocol
    
    var invoices: [DocumentWithExtractions] = []
    
    let noInvoicesText = NSLocalizedString("giniHealthSDKExample.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("giniHealthSDKExample.invoicesList.title", comment: "")
    let uploadInvoicesText = NSLocalizedString("giniHealthSDKExample.uploadInvoices.button.title", comment: "")
    let errorUploadingTitleText = NSLocalizedString("giniHealthSDKExample.invoicesList.erorrUploading", comment: "")
    
    let backgroundColor: UIColor = GiniColor(light: .white, 
                                             dark: .black).uiColor()
    let tableViewSeparatorColor: UIColor = GiniColor(light: .lightGray, 
                                                     dark: .darkGray).uiColor()
    
    private let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    private var errors: [GiniHealthAPILibrary.GiniError] = []
    
    init(coordinator: InvoicesListCoordinator,
         invoices: [DocumentWithExtractions]? = nil,
         documentService: GiniHealthAPILibrary.DefaultDocumentService,
         hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
         giniHealthConfiguration: GiniHealthConfiguration) {
        self.coordinator = coordinator
        self.hardcodedInvoicesController = hardcodedInvoicesController
        self.invoices = invoices ?? hardcodedInvoicesController.getInvoicesWithExtractions()
        self.documentService = documentService
        self.giniHealthConfiguration = giniHealthConfiguration
    }
    
    @objc
    func uploadInvoices() {
        coordinator.invoicesListViewController?.showActivityIndicator()
        hardcodedInvoicesController.obtainInvoicePhotosHardcoded { [weak self] invoicesData in
            self?.uploadDocuments(dataDocuments: invoicesData)
        }
    }
    
    private func uploadDocuments(dataDocuments: [Data]) {
        errors = []
        let dispatchGroup = DispatchGroup()
        for giniDocument in dataDocuments {
            dispatchGroup.enter()
            self.documentService.createDocument(fileName: nil,
                                                docType: .invoice,
                                                type: .partial(giniDocument),
                                                metadata: nil) { [weak self] result in
                switch result {
                case .success(let createdDocument):
                    Log("Successfully created document with id: \(createdDocument.id)", event: .success)
                    self?.documentService.extractions(for: createdDocument,
                                                      cancellationToken: CancellationToken()) { [weak self] result in
                        switch result {
                        case let .success(extractionResult):
                            Log("Successfully fetched extractions for id: \(createdDocument.id)", event: .success)
                            self?.invoices.append(DocumentWithExtractions(documentID: createdDocument.id, 
                                                                          extractionResult: extractionResult))
                        case let .failure(error):
                            Log("Setting document for review failed: \(String(describing: error))", event: .error)
                            self?.errors.append(error)
                        }
                        dispatchGroup.leave()
                    }
                case .failure(let error):
                    Log("Document creation failed: \(String(describing: error))", event: .error)
                    self?.errors.append(error)
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if !self.errors.isEmpty {
                let errorMessages = self.errors.map( { $0.message })
                let uniqueErrorMessages = Array(Set(errorMessages))
                self.coordinator.invoicesListViewController.showErrorAlertView(error: uniqueErrorMessages.joined(separator: ", "))
            }
            self.hardcodedInvoicesController.storeInvoicesWithExtractions(invoices: self.invoices)
            self.coordinator.invoicesListViewController?.hideActivityIndicator()
            self.coordinator.invoicesListViewController?.reloadTableView()
        }
    }
}
