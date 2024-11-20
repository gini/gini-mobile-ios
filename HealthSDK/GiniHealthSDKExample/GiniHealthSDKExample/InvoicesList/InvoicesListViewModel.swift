//
//  InvoicesListViewModel.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import UIKit
import GiniCaptureSDK
import GiniHealthSDK
import GiniUtilites

struct DocumentWithExtractions: Codable {
    var documentId: String
    var amountToPay: String?
    var paymentDueDate: String?
    var recipient: String?
    var isPayable: Bool?
    var hasMultipleDocuments: Bool?
    var doctorName: String?
    var iban: String?
    var purpose: String?

    init(documentId: String, extractionResult: GiniHealthSDK.ExtractionResult) {
        self.documentId = documentId
        self.amountToPay = extractionResult.payment?.first?.first(where: { $0.name == ExtractionType.amountToPay.rawValue })?.value
        self.paymentDueDate = extractionResult.extractions.first(where: { $0.name == ExtractionType.paymentDueDate.rawValue })?.value
        self.recipient = extractionResult.payment?.first?.first(where: { $0.name == ExtractionType.paymentRecipient.rawValue })?.value
        self.isPayable = extractionResult.extractions.first(where: { $0.name == ExtractionType.paymentState.rawValue })?.value == PaymentState.payable.rawValue
        self.hasMultipleDocuments = extractionResult.extractions.first(where: { $0.name == ExtractionType.containsMultipleDocs.rawValue })?.value == true.description
        self.doctorName = extractionResult.extractions.first(where: { $0.name == ExtractionType.doctorName.rawValue })?.value
        self.iban = extractionResult.payment?.first?.first(where: { $0.name == ExtractionType.iban.rawValue })?.value
        self.purpose = extractionResult.payment?.first?.first(where: { $0.name == ExtractionType.paymentPurpose.rawValue })?.value
    }
}

final class InvoicesListViewModel {
    
    private let coordinator: InvoicesListCoordinator
    private var documentService: GiniHealthSDK.DefaultDocumentService

    private let hardcodedInvoicesController: HardcodedInvoicesControllerProtocol
    var paymentComponentsController: PaymentComponentsController
    private let giniHealthConfiguration = GiniHealthConfiguration.shared

    var invoices: [DocumentWithExtractions]

    let noInvoicesText = NSLocalizedString("gini.health.example.invoicesList.missingInvoices.text", comment: "")
    let titleText = NSLocalizedString("gini.health.example.invoicesList.title", comment: "")
    let uploadInvoicesText = NSLocalizedString("gini.health.example.uploadInvoices.button.title", comment: "")
    let cancelText = NSLocalizedString("gini.health.example.cancel.button.title", comment: "")
    let errorTitleText = NSLocalizedString("gini.health.example.invoicesList.error", comment: "")

    let backgroundColor: UIColor = GiniColor(light: .white, 
                                             dark: .black).uiColor()
    let tableViewSeparatorColor: UIColor = GiniColor(light: .lightGray, 
                                                     dark: .darkGray).uiColor()
    
    private let tableViewCell: UITableViewCell.Type = InvoiceTableViewCell.self
    private var errors: [String] = []

    let dispatchGroup = DispatchGroup()
    var shouldRefetchExtractions = false
    var documentIdToRefetch: String?

    init(coordinator: InvoicesListCoordinator,
         invoices: [DocumentWithExtractions]? = nil,
         documentService: GiniHealthSDK.DefaultDocumentService,
         hardcodedInvoicesController: HardcodedInvoicesControllerProtocol,
         paymentComponentsController: PaymentComponentsController) {
        self.coordinator = coordinator
        self.hardcodedInvoicesController = hardcodedInvoicesController
        self.invoices = invoices ?? hardcodedInvoicesController.getInvoicesWithExtractions()
        self.documentService = documentService
        self.paymentComponentsController = paymentComponentsController
        self.paymentComponentsController.delegate = self
    }
    
    func viewDidLoad() {}
    
    func refetchExtractions() {
        guard shouldRefetchExtractions else { return }
        guard let documentIdToRefetch else { return }
        DispatchQueue.main.async {
            self.coordinator.invoicesListViewController?.showActivityIndicator()
        }
        self.documentService.fetchDocument(with: documentIdToRefetch) { [weak self] result in
            switch result {
            case .success(let document):
                self?.documentService.extractions(for: document, cancellationToken: CancellationToken()) { resultExtractions in
                    switch resultExtractions {
                    case .success(let extractions):
                        self?.shouldRefetchExtractions = false
                        self?.documentIdToRefetch = nil
                        self?.hardcodedInvoicesController.updateDocumentExtractions(documentId: document.id, extractions: extractions)
                        self?.invoices = self?.hardcodedInvoicesController.getInvoicesWithExtractions() ?? []
                        DispatchQueue.main.async {
                            self?.coordinator.invoicesListViewController?.hideActivityIndicator()
                            self?.coordinator.invoicesListViewController?.reloadTableView()
                        }
                    case .failure(let error):
                        self?.errors.append(error.localizedDescription)
                        self?.showErrorsIfAny()
                    }
                }
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

    private func showErrorsIfAny() {
        if !errors.isEmpty {
            let uniqueErrorMessages = Array(Set(errors))
            DispatchQueue.main.async {
                self.coordinator.invoicesListViewController.hideActivityIndicator()
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
                    GiniUtilites.Log("Successfully created document with id: \(createdDocument.id)", event: .success)
                    self?.documentService.extractions(for: createdDocument,
                                                      cancellationToken: CancellationToken()) { [weak self] result in
                        switch result {
                        case let .success(extractionResult):
                            GiniUtilites.Log("Successfully fetched extractions for id: \(createdDocument.id)", event: .success)
                            self?.invoices.append(DocumentWithExtractions(documentId: createdDocument.id,
                                                                          extractionResult: extractionResult))
                        case let .failure(error):
                            GiniUtilites.Log("Obtaining extractions from document with id \(createdDocument.id) failed with error: \(String(describing: error))", event: .error)
                            self?.errors.append(error.message)
                        }
                        self?.dispatchGroup.leave()
                    }
                case .failure(let error):
                    GiniUtilites.Log("Document creation failed: \(String(describing: error))", event: .error)
                    self?.errors.append(error.message)
                    self?.dispatchGroup.leave()
                }
            }
        }
    }

    func checkForErrors(documentID: String) {
        if !checkDocumentForMultipleInvoices(documentID: documentID) {
            checkDocumentIsPayable(documentID: documentID)
        }
    }

    private func checkDocumentIsPayable(documentID: String) {
        if let document = invoices.first(where: { $0.documentId == documentID }) {
            if !(document.isPayable ?? false) {
                errors.append("\(NSLocalizedStringPreferredFormat("gini.health.example.error.invoice.not.payable", comment: ""))")
                showErrorsIfAny()
            }
        }
    }

    @discardableResult
    private func checkDocumentForMultipleInvoices(documentID: String) -> Bool {
        if let document = invoices.first(where: { $0.documentId == documentID }) {
            if document.hasMultipleDocuments ?? false {
                errors.append("\(NSLocalizedStringPreferredFormat("gini.health.example.error.contains.multiple.invoices", comment: ""))")
                showErrorsIfAny()
                return true
            }
        }
        return false
    }
}

extension InvoicesListViewModel {
    func didTapOnOpenFlow(documentId: String?) {
        documentIdToRefetch = documentId
        guard !checkDocumentForMultipleInvoices(documentID: documentId ?? "") else { return }
        paymentComponentsController.startPaymentFlow(documentId: documentId, paymentInfo: obtainPaymentInfo(for: documentId), navigationController: self.coordinator.invoicesListNavigationController, trackingDelegate: self)
    }

    private func obtainPaymentInfo(for documentId: String?) -> PaymentInfo? {
        guard let index = invoices.firstIndex(where: { $0.documentId == documentId }) else {
            return nil
        }
        return PaymentInfo(recipient: invoices[index].recipient ?? "",
                           iban: invoices[index].iban ?? "",
                           bic: "",
                           amount: invoices[index].amountToPay ?? "",
                           purpose: invoices[index].purpose ?? "",
                           paymentUniversalLink: paymentComponentsController.selectedPaymentProvider?.universalLinkIOS ?? "",
                           paymentProviderId: paymentComponentsController.selectedPaymentProvider?.id ?? "")
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

extension InvoicesListViewModel: GiniHealthTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onToTheBankButtonClicked:
            self.shouldRefetchExtractions = true
            GiniUtilites.Log("To the banking app button was tapped,\(String(describing: event.info))", event: .success)
        case .onCloseButtonClicked:
            refetchExtractions()
            GiniUtilites.Log("Close screen was triggered", event: .success)
        case .onCloseKeyboardButtonClicked:
            GiniUtilites.Log("Close keyboard was triggered", event: .success)
        }
    }
}
