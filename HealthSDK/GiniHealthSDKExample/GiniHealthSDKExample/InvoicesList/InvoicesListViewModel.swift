//
//  InvoicesListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import UIKit
import GiniHealthSDK
import GiniHealthAPILibrary
import GiniCaptureSDK
import GiniBankAPILibrary

protocol InvoicesCoordinatorProtocol: AnyObject {
}

protocol InvoicesViewControllerProtocol: AnyObject {
    func showActivityIndicator()
    func hideActivityIndicator()
    func reloadTableView()
}

struct DocumentWithExtractions: Codable {
    var documentID: String
    var amountToPay: String?
    var paymentDueDate: String?
    var recipient: String?
    
    init(documentID: String, extractionResult: GiniHealthAPILibrary.ExtractionResult) {
        self.documentID = documentID
        self.amountToPay = extractionResult.payment?.first?.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractionResult.extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractionResult.payment?.first?.first(where: {$0.name == "payment_recipient"})?.value
    }
    
    init(documentID: String, extractions: [GiniBankAPILibrary.Extraction]) {
        self.documentID = documentID
        self.amountToPay = extractions.first(where: {$0.name == "amount_to_pay"})?.value
        self.paymentDueDate = extractions.first(where: {$0.name == "payment_due_date"})?.value
        self.recipient = extractions.first(where: {$0.name == "payment_recipient"})?.value
    }
}

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private weak var viewController: InvoicesViewControllerProtocol?
    private var health: GiniHealth
    
    private var hardcodedDocuments: [GiniHealthAPILibrary.Document]?
    private let dispatchGroup = DispatchGroup()
    private let hardcodedInvoicesController: HardcodedInvoicesControllerProtocol
    
    var invoices: [DocumentWithExtractions] = []
    
    let noInvoicesText = "No Invoices"
    let titleText = "Invoices List"
    let uploadInvoicesText = "↑ invoices"
    
    let backgroundColor: UIColor = GiniColor(light: .white, dark: .black).uiColor()
    let tableViewSeparatorCalor: UIColor = GiniColor(light: .lightGray, dark: .darkGray).uiColor()
    
    let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    
    init(coordinator: InvoicesListCoordinator, viewController: InvoicesViewControllerProtocol? = nil, invoices: [DocumentWithExtractions]? = nil, giniHealth: GiniHealth, hardcodedInvoicesController: HardcodedInvoicesControllerProtocol) {
        self.coordinator = coordinator
        self.viewController = viewController
        self.hardcodedInvoicesController = hardcodedInvoicesController
        self.invoices = invoices ?? hardcodedInvoicesController.getInvoicesWithExtractions()
        self.health = giniHealth
    }
    
    @objc
    func uploadInvoices() {
        viewController?.showActivityIndicator()
        hardcodedInvoicesController.obtainInvoicePhotosHardcoded { [weak self] invoicesData in
            self?.uploadDocuments(dataDocuments: invoicesData)
        }
    }
    
    private func uploadDocuments(dataDocuments: [Data]) {
        for giniDocument in dataDocuments {
            dispatchGroup.enter()
            self.health.documentService.createDocument(fileName: nil,
                                                       docType: .invoice,
                                                       type: .partial(giniDocument),
                                                       metadata: nil) { [weak self] result in
                switch result {
                case .success(let createdDocument):
                    print("✅ Successfully created document with id: \(createdDocument.id)")
                    self?.health.documentService.extractions(for: createdDocument, cancellationToken: CancellationToken()) { [weak self] result in
                        switch result {
                        case let .success(extractionResult):
                            print("✅ Successfully fetched extractions for id: \(createdDocument.id)")
                            self?.invoices.append(DocumentWithExtractions(documentID: createdDocument.id, extractionResult: extractionResult))
                        case let .failure(error):
                            print("❌ Setting document for review failed: \(String(describing: error))")
                        }
                        self?.dispatchGroup.leave()
                    }
                case .failure(let error):
                    print("❌ Document creation failed: \(String(describing: error))")
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.hardcodedInvoicesController.storeInvoicesWithExtractions(invoices: self.invoices)
            self.viewController?.hideActivityIndicator()
            self.viewController?.reloadTableView()
        }
    }
    
    
}
