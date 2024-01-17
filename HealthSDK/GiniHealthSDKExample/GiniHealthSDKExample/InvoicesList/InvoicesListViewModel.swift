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

protocol InvoicesCoordinatorProtocol: AnyObject {
}

protocol InvoicesViewControllerProtocol: AnyObject {
    func showActivityIndicator()
    func hideActivityIndicator()
    func reloadTableView()
}

struct DocumentWithExtractions {
    var document: Document
    var extractionResult: ExtractionResult
}

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private weak var viewController: InvoicesViewControllerProtocol?
    private var health: GiniHealth
    
    private var hardcodedDocuments: [GiniHealthAPILibrary.Document]?
    private let dispatchGroup = DispatchGroup()
    
    var invoices: [DocumentWithExtractions] = []
    
    let noInvoicesText = "No Invoices"
    let titleText = "Invoices List"
    let uploadInvoicesText = "↑ invoices"
    
    let backgroundColor: UIColor = GiniColor(light: .white, dark: .black).uiColor()
    let tableViewSeparatorCalor: UIColor = GiniColor(light: .lightGray, dark: .darkGray).uiColor()
    
    let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    
    init(coordinator: InvoicesListCoordinator, viewController: InvoicesViewControllerProtocol? = nil, invoices: [DocumentWithExtractions]? = nil, giniHealth: GiniHealth) {
        self.coordinator = coordinator
        self.viewController = viewController
        self.invoices = invoices ?? []
        self.health = giniHealth
    }
    
    @objc
    func uploadInvoices() {
        viewController?.showActivityIndicator()
        HardcodedInvoicesController().obtainInvoicesHardcoded { [weak self] invoicesData in
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
                            self?.invoices.append(DocumentWithExtractions(document: createdDocument, extractionResult: extractionResult))
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
            self.viewController?.hideActivityIndicator()
            self.viewController?.reloadTableView()
        }
    }
    
    
}
