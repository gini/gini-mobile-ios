//
//  ScreenAPICoordinator.swift
//  GiniHealthSDKExample
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary
import GiniCaptureSDK
import GiniHealthSDK
import GiniHealthAPILibrary
import GiniInternalPaymentSDK
import GiniUtilites
import UIKit

protocol ScreenAPICoordinatorDelegate: AnyObject {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ())
    func presentInvoicesList(invoices: [DocumentWithExtractions]?)
    func presentError(title: String, message: String)
}

final class ScreenAPICoordinator: NSObject, Coordinator, GiniHealthTrackingDelegate, GiniCaptureResultsDelegate {
    
    weak var delegate: ScreenAPICoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return screenAPIViewController
    }
    
    var giniHealth: GiniHealth?
    var screenAPIViewController: UINavigationController!
    
    let client: GiniHealthAPILibrary.Client
    let documentMetadata: GiniHealthAPILibrary.Document.Metadata?
    weak var analysisDelegate: AnalysisDelegate?
    var visionDocuments: [GiniCaptureDocument]?
    var visionConfiguration: GiniConfiguration
    private var captureExtractedResults: [GiniBankAPILibrary.Extraction] = []
    private var hardcodedInvoicesController: HardcodedInvoicesController
    
    // {extraction name} : {entity name}
    private let editableSpecificExtractions = ["paymentRecipient" : "companyname", "paymentReference" : "reference", "paymentPurpose" : "text", "iban" : "iban", "bic" : "bic", "amountToPay" : "amount"]
    
    init(configuration: GiniConfiguration,
         importedDocuments documents: [GiniCaptureDocument]?,
         client: GiniHealthAPILibrary.Client,
         documentMetadata: GiniHealthAPILibrary.Document.Metadata?,
         hardcodedInvoicesController: HardcodedInvoicesController) {
        visionConfiguration = configuration
        visionDocuments = documents
        self.client = client
        self.documentMetadata = documentMetadata
        self.hardcodedInvoicesController = hardcodedInvoicesController
        super.init()
    }
    
    func start(healthAPI: GiniHealthAPI) {
        let viewController = GiniCapture.viewController(importedDocuments: visionDocuments,
                                                        configuration: visionConfiguration,
                                                        resultsDelegate: self,
                                                        networkingService: HealthNetworkingService(lib: healthAPI))
        screenAPIViewController = RootNavigationController(rootViewController: viewController)
        screenAPIViewController.setNavigationBarHidden(true, animated: false)
        screenAPIViewController.delegate = self
        screenAPIViewController.interactivePopGestureRecognizer?.delegate = nil
    }
    
    func onPaymentReviewScreenEvent(event: GiniHealthSDK.TrackingEvent<GiniHealthSDK.PaymentReviewScreenEventType>) {
    }
    
    // MARK: - GiniCaptureResultsDelegate
    
    func giniCaptureDidCancelAnalysis() {
        screenAPIViewController.dismiss(animated: true)
    }
    
    func giniCaptureDidEnterManually() {
        screenAPIViewController.dismiss(animated: true)
    }
    
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
        captureExtractedResults = result.extractions.map { $0.value }

        guard let healthSDK = self.giniHealth, let docId = result.document?.id else { return }

        checkIfDocumentIsPayable(for: docId, using: healthSDK) { [weak self] isPayable in
            guard isPayable else {
                self?.presentErrorForNonPayableDocument()
                return
            }

            self?.checkIfDocumentContainsMultipleInvoices(docId: docId, using: healthSDK)
        }
    }

    private func checkIfDocumentContainsMultipleInvoices(docId: String, using healthSDK: GiniHealth) {
        healthSDK.checkIfDocumentContainsMultipleInvoices(docId: docId) { [weak self] result in
            switch result {
            case .success(let multipleInvoices):
                if !multipleInvoices {
                    self?.fetchDocumentDataForReview(docId: docId, using: healthSDK)
                } else {
                    self?.presentErrorForMultipleInvoicesInDocument()
                }
            case .failure(let error):
                GiniUtilites.Log("Check if document contains multiple invoices failed with: \(String(describing: error))",
                                 event: .error)
            }
        }
    }

    private func createHealthExtractions(from extractions: [GiniBankAPILibrary.Extraction]) -> [GiniHealthAPILibrary.Extraction] {
        return extractions.map { extraction in
            GiniHealthAPILibrary.Extraction(box: nil,
                                            candidates: extraction.candidates,
                                            entity: extraction.entity,
                                            value: extraction.value,
                                            name: extraction.name)
        }
    }

    private func checkIfDocumentIsPayable(for docId: String, using healthSDK: GiniHealth, completion: @escaping (Bool) -> Void) {
        healthSDK.checkIfDocumentIsPayable(docId: docId) { resultPayable in
            switch resultPayable {
            case .success(let payable):
                completion(payable)
            case .failure(let error):
                GiniUtilites.Log("Check if document is payable failed with: \(String(describing: error))",
                                 event: .error)
                completion(false)
            }
        }
    }

    private func fetchDocumentDataForReview(docId: String, using healthSDK: GiniHealth) {
        healthSDK.fetchDataForReview(documentId: docId) { [weak self] resultReview in
            switch resultReview {
            case .success(let data):
                self?.fetchExtractions(for: data.document, healthSDK: healthSDK)
            case .failure(let error):
                GiniUtilites.Log("Document data fetching failed: \(String(describing: error))",
                                 event: .error)
            }
        }
    }

    private func fetchExtractions(for document: GiniHealthSDK.Document, healthSDK: GiniHealth) {
        healthSDK.documentService.extractions(for: document, cancellationToken: CancellationToken()) { [weak self] result in
            switch result {
            case .success(let extractionResult):
                GiniUtilites.Log("Successfully fetched extractions for id: \(document.id)",
                                 event: .success)
                self?.handleSuccessfulExtractions(extractionResult, for: document.id)
            case .failure(let error):
                GiniUtilites.Log("Obtaining extractions from document with id \(document.id) failed with error: \(String(describing: error))",
                                 event: .error)
            }
        }
    }

    private func handleSuccessfulExtractions(_ extractionResult: GiniHealthSDK.ExtractionResult, for documentId: String) {
        let invoice = DocumentWithExtractions(documentId: documentId, extractionResult: extractionResult)
        self.hardcodedInvoicesController.appendInvoiceWithExtractions(invoice: invoice)

        DispatchQueue.main.async {
            self.rootViewController.dismiss(animated: true) {
                self.delegate?.presentInvoicesList(invoices: [invoice])
            }
        }
    }

    private func presentErrorForNonPayableDocument() {
        DispatchQueue.main.async {
            self.rootViewController.dismiss(animated: true) {
                let nonPayableTitleErrorText = NSLocalizedString("gini.health.example.error.invoice.not.payable", comment: "")
                self.delegate?.presentError(title: nonPayableTitleErrorText, message: "")
            }
        }
    }

    private func presentErrorForMultipleInvoicesInDocument() {
        DispatchQueue.main.async {
            self.rootViewController.dismiss(animated: true) {
                let multipleInvoicesTitleErrorText = NSLocalizedString("gini.health.example.error.contains.multiple.invoices", comment: "")
                self.delegate?.presentError(title: multipleInvoicesTitleErrorText, message: "")
            }
        }
    }
}
// MARK: - UINavigationControllerDelegate

extension ScreenAPICoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is PaymentReviewViewController {
            delegate?.screenAPI(coordinator: self, didFinish: ())
        }
        return nil
    }
}
