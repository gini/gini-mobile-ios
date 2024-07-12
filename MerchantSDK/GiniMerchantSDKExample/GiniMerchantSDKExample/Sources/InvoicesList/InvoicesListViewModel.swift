//
//  InvoicesListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniCaptureSDK
import GiniMerchantSDK

struct DocumentWithExtractions: Codable {
    var documentID: String
    var amountToPay: String?
    var paymentDueDate: String?
    var recipient: String?
    var isPayable: Bool?
    var iban: String?
    var purpose: String?

    init(documentID: String, extractionResult: GiniMerchantSDK.ExtractionResult) {
        self.documentID = documentID
        self.amountToPay = extractionResult.payment?.first?.first(where: {$0.name == ExtractionType.amountToPay.rawValue})?.value
        self.paymentDueDate = extractionResult.extractions.first(where: {$0.name == ExtractionType.paymentDueDate.rawValue})?.value
        self.recipient = extractionResult.payment?.first?.first(where: {$0.name == ExtractionType.paymentRecipient.rawValue})?.value
        self.isPayable = extractionResult.extractions.first(where: {$0.name == ExtractionType.paymentState.rawValue})?.value == PaymentState.payable.rawValue
        self.iban = extractionResult.extractions.first(where: {$0.name == ExtractionType.iban.rawValue})?.value
        self.purpose = extractionResult.extractions.first(where: {$0.name == ExtractionType.paymentPurpose.rawValue})?.value
    }
}

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private var documentService: GiniMerchantSDK.DefaultDocumentService

    private let hardcodedInvoicesController: HardcodedInvoicesControllerProtocol
    var paymentComponentsController: PaymentComponentsController

    var invoices: [DocumentWithExtractions]

    let noInvoicesText = NSLocalizedString("example.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("example.invoicesList.title", comment: "")
    let uploadInvoicesText = NSLocalizedString("example.uploadInvoices.button.title", comment: "")
    let cancelText = NSLocalizedString("example.cancel.button.title", comment: "")
    let errorTitleText = NSLocalizedString("example.invoicesList.error", comment: "")

    let backgroundColor: UIColor = GiniColor(light: .white, 
                                             dark: .black).uiColor()
    let tableViewSeparatorColor: UIColor = GiniColor(light: .lightGray, 
                                                     dark: .darkGray).uiColor()
    
    private let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    private var errors: [String] = []

    let dispatchGroup = DispatchGroup()
    var shouldRefetchExtractions = false
    var documentIDToRefetch: String?

    init(coordinator: InvoicesListCoordinator,
         invoices: [DocumentWithExtractions]? = nil,
         documentService: GiniMerchantSDK.DefaultDocumentService,
         hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
         paymentComponentsController: PaymentComponentsController) {
        self.coordinator = coordinator
        self.hardcodedInvoicesController = hardcodedInvoicesController
        self.invoices = invoices ?? hardcodedInvoicesController.getInvoicesWithExtractions()
        self.documentService = documentService
        self.paymentComponentsController = paymentComponentsController
        self.paymentComponentsController.delegate = self
//        self.paymentComponentsController.viewDelegate = self
//        self.paymentComponentsController.bottomViewDelegate = self
    }
    
    func viewDidLoad() {
        paymentComponentsController.loadPaymentProviders()
    }
        
    func refetchExtractions() {
        guard shouldRefetchExtractions else { return }
        guard let documentIDToRefetch else { return }
        DispatchQueue.main.async {
            self.coordinator.invoicesListViewController?.showActivityIndicator()
        }
        self.documentService.fetchDocument(with: documentIDToRefetch) { [weak self] result in
            switch result {
            case .success(let document):
                self?.loadExtractions(document)
            case .failure(let error):
                self?.errors.append(error.localizedDescription)
                self?.showErrorsIfAny()
            }
        }
    }

    private func setDispatchGroupNotifier() {
        dispatchGroup.notify(queue: .main) {
            self.showErrorsIfAny()
            if !self.invoices.isEmpty {
                self.hardcodedInvoicesController.storeInvoicesWithExtractions(invoices: self.invoices)
                self.coordinator.invoicesListViewController?.hideActivityIndicator()
                self.coordinator.invoicesListViewController?.reloadTableView()
            }
        }
    }
    fileprivate func loadExtractions(_ document: Document) {
        documentService.extractions(for: document, cancellationToken: CancellationToken()) { [weak self] resultExtractions in
            switch resultExtractions {
            case .success(let extractions):
                self?.shouldRefetchExtractions = false
                self?.documentIDToRefetch = nil
                let recipient = extractions.payment?.first?.first(where: {$0.name == "payment_recipient"})?.value
                let amountToPay = extractions.payment?.first?.first(where: {$0.name == "amount_to_pay"})?.value
                self?.hardcodedInvoicesController.updateDocumentExtractions(documentID: document.id, recipient: recipient, amountToPay: amountToPay)
                self?.invoices = self?.hardcodedInvoicesController.getInvoicesWithExtractions() ?? []
                DispatchQueue.main.async { [weak self] in
                    self?.coordinator.invoicesListViewController?.hideActivityIndicator()
                    self?.coordinator.invoicesListViewController?.reloadTableView()
                }
            case .failure(let error):
                self?.errors.append(error.localizedDescription)
                self?.showErrorsIfAny()
            }
        }
    }

    
    private func showErrorsIfAny() {
        if !errors.isEmpty {
            let uniqueErrorMessages = Array(Set(errors))
            DispatchQueue.main.async {
                self.coordinator.invoicesListViewController.showErrorAlertView(error: uniqueErrorMessages.joined(separator: ", "))
            }
            errors = []
        }
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
        setDispatchGroupNotifier()
    }

    private func uploadDocuments(dataDocuments: [Data]) {
        for giniDocument in dataDocuments {
            dispatchGroup.enter()
            self.documentService.createDocument(fileName: nil,
                                                docType: .invoice,
                                                type: .partial(giniDocument),
                                                metadata: nil) { [weak self] result in
                switch result {
                case .success(let createdDocument):
                    print("Successfully created document with id: \(createdDocument.id)")
                    self?.documentService.extractions(for: createdDocument,
                                                      cancellationToken: CancellationToken()) { [weak self] result in
                        switch result {
                        case let .success(extractionResult):
                            print("Successfully fetched extractions for id: \(createdDocument.id)")
                            self?.invoices.append(DocumentWithExtractions(documentID: createdDocument.id,
                                                                          extractionResult: extractionResult))
                        case let .failure(error):
                            print("Obtaining extractions from document with id \(createdDocument.id) failed with error: \(String(describing: error))")
                            self?.errors.append(error.message)
                        }
                        self?.dispatchGroup.leave()
                    }
                case .failure(let error):
                    print("Document creation failed: \(String(describing: error))")
                    self?.errors.append(error.message)
                    self?.dispatchGroup.leave()
                }
            }
        }
    }
}

extension InvoicesListViewModel: PaymentComponentsControllerProtocol {
    func didFetchedPaymentProviders() {
        DispatchQueue.main.async {
            self.coordinator.invoicesListViewController.reloadTableView()
        }
    }

    func isLoadingStateChanged(isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                self.coordinator.invoicesListViewController.showActivityIndicator()
            } else {
                self.coordinator.invoicesListViewController.hideActivityIndicator()
            }
        }
    }
}



extension InvoicesListViewModel: GiniMerchantTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onToTheBankButtonClicked:
            self.shouldRefetchExtractions = true
            print("✅ To the banking app button was tapped,\(String(describing: event.info))")
        case .onCloseButtonClicked:
            refetchExtractions()
            print("✅ Close screen was triggered")
        case .onCloseKeyboardButtonClicked:
            print("✅ Close keyboard was triggered")
        }
    }
}