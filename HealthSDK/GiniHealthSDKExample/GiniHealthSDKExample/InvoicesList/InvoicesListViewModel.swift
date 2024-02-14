//
//  InvoicesListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniHealthAPILibrary
import GiniCaptureSDK
import GiniHealthSDK

struct Bank: Codable {
    let name: String
    let iconName: String
    let accentColor: GiniHealthSDK.CodableColor
    let textColor: GiniHealthSDK.CodableColor

    init() {
        name = "Sparkasse"
        iconName = "sparkasseBankIcon"
        accentColor = GiniHealthSDK.CodableColor(uiColor: .red)
        textColor = GiniHealthSDK.CodableColor(uiColor: .white)
    }

    internal init(name: String, 
                  iconName: String,
                  accentColor: CodableColor,
                  textColor: CodableColor) {
        self.name = name
        self.iconName = iconName
        self.accentColor = accentColor
        self.textColor = textColor
    }
}

struct DocumentWithExtractions: Codable {
    var documentID: String
    var amountToPay: String?
    var paymentDueDate: String?
    var recipient: String?
    var isPayable: Bool = false
    // TODO: - Will be replace in next task with real data
    var bank: Bank

    init(documentID: String, extractionResult: GiniHealthAPILibrary.ExtractionResult, bank: Bank) {
        self.documentID = documentID
        self.amountToPay = extractionResult.payment?.first?.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractionResult.extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractionResult.payment?.first?.first(where: {$0.name == "payment_recipient"})?.value
        self.bank = bank
    }
    
    init(documentID: String, extractions: [GiniHealthAPILibrary.Extraction], bank: Bank) {
        self.documentID = documentID
        self.amountToPay = extractions.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractions.first(where: {$0.name == "payment_recipient"})?.value
        self.bank = bank
    }
}

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private var documentService: GiniHealthAPILibrary.DefaultDocumentService

    private let hardcodedInvoicesController: HardcodedInvoicesControllerProtocol
    var paymentComponentsController: PaymentComponentsController

    var invoices: [DocumentWithExtractions]

    // TODO: - Only for testing purpose - these values will come from API
    let banks: [Bank] = [
        Bank(name: "Sparkasse", iconName: "sparkasseBankIcon", accentColor: GiniHealthSDK.CodableColor(uiColor: UIColor.red), textColor: GiniHealthSDK.CodableColor(uiColor: .white)),
        Bank(name: "Deutsche Kreditbank", iconName: "kreditBankIcon", accentColor: GiniHealthSDK.CodableColor(uiColor: UIColor.systemBlue), textColor: GiniHealthSDK.CodableColor(uiColor: .white)),
        Bank(name: "Deutsche Bank", iconName: "deutscheBankIcon", accentColor: GiniHealthSDK.CodableColor(uiColor: UIColor.blue), textColor: GiniHealthSDK.CodableColor(uiColor: .white))
    ]

    let noInvoicesText = NSLocalizedString("giniHealthSDKExample.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("giniHealthSDKExample.invoicesList.title", comment: "")
    let uploadInvoicesText = NSLocalizedString("giniHealthSDKExample.uploadInvoices.button.title", comment: "")
    let cancelText = NSLocalizedString("giniHealthSDKExample.cancel.button.title", comment: "")
    let errorTitleText = NSLocalizedString("giniHealthSDKExample.invoicesList.error", comment: "")

    let backgroundColor: UIColor = GiniColor(light: .white, 
                                             dark: .black).uiColor()
    let tableViewSeparatorColor: UIColor = GiniColor(light: .lightGray, 
                                                     dark: .darkGray).uiColor()
    
    private let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    private var errors: [String] = []

    init(coordinator: InvoicesListCoordinator,
         invoices: [DocumentWithExtractions]? = nil,
         documentService: GiniHealthAPILibrary.DefaultDocumentService,
         hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
         paymentComponentsController: PaymentComponentsController) {
        self.coordinator = coordinator
        self.hardcodedInvoicesController = hardcodedInvoicesController
        self.invoices = invoices ?? hardcodedInvoicesController.getInvoicesWithExtractions()
        self.documentService = documentService
        self.paymentComponentsController = paymentComponentsController
    }
    
    @objc
    func uploadInvoices() {
        coordinator.invoicesListViewController?.showActivityIndicator()
        hardcodedInvoicesController.obtainInvoicePhotosHardcoded { [weak self] invoicesData in
            if !invoicesData.isEmpty {
                self?.uploadDocuments(dataDocuments: invoicesData)
            } else {
                self?.coordinator.invoicesListViewController.hideActivityIndicator()
            }
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
                                                                          extractionResult: extractionResult, bank: self?.banks.randomElement() ?? Bank()))
                            self?.paymentComponentsController.checkIfDocumentIsPayable(docId: createdDocument.id, completion: { result in
                                switch result {
                                case let .success(isPayable):
                                    Log("Successfully checked if document \(createdDocument.id) is payable", event: .success)
                                    if let indexDocument = self?.invoices.firstIndex(where: { $0.documentID == createdDocument.id }) {
                                        self?.invoices[indexDocument].isPayable = isPayable
                                    }
                                case let .failure(error):
                                    Log("Checking if document \(createdDocument.id) is payable failed with error: \(String(describing: error))", event: .error)
                                    self?.errors.append(error.localizedDescription)
                                }
                                dispatchGroup.leave()
                            })
                        case let .failure(error):
                            Log("Obtaining extractions from document with id \(createdDocument.id) failed with error: \(String(describing: error))", event: .error)
                            self?.errors.append(error.message)
                            dispatchGroup.leave()
                        }
                    }
                case .failure(let error):
                    Log("Document creation failed: \(String(describing: error))", event: .error)
                    self?.errors.append(error.message)
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if !self.errors.isEmpty {
                let uniqueErrorMessages = Array(Set(self.errors))
                self.coordinator.invoicesListViewController.showErrorAlertView(error: uniqueErrorMessages.joined(separator: ", "))
            }
            self.hardcodedInvoicesController.storeInvoicesWithExtractions(invoices: self.invoices)
            self.coordinator.invoicesListViewController?.hideActivityIndicator()
            self.coordinator.invoicesListViewController?.reloadTableView()
        }
    }
}
