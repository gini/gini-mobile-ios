//
//  AppCoordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniHealthAPILibrary
import GiniHealthSDK
import GiniInternalPaymentSDK
import GiniUtilites

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    fileprivate let window: UIWindow
    fileprivate var screenAPIViewController: UIViewController?
    var rootViewController: UIViewController {
        return selectAPIViewController
    }
    lazy var selectAPIViewController: SelectAPIViewController = {
        let selectAPIViewController = SelectAPIViewController()
        selectAPIViewController.delegate = self
        selectAPIViewController.debugMenuPresenter = self
        selectAPIViewController.clientId = clientID
        return selectAPIViewController
    }()
    
    lazy var giniConfiguration: GiniConfiguration = {
        let giniConfiguration = GiniConfiguration.shared
        giniConfiguration.debugModeOn = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.openWithEnabled = true
        giniConfiguration.qrCodeScanningEnabled = true
        giniConfiguration.multipageEnabled = true
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 10 * 1024 * 1024
            if document.data.count > maxFileSize {
                let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als 10MB")
                return CustomDocumentValidationResult.failure(withError: error)
            }
            return CustomDocumentValidationResult.success()
        }
        return giniConfiguration
    }()

    private lazy var health = GiniHealth(id: clientID, secret: clientPassword, domain: clientDomain)

    private lazy var giniHealthConfiguration: GiniHealthConfiguration = {
        let configuration = GiniHealthConfiguration()
        // Show the close button to dismiss the payment review screen
        configuration.paymentReviewStatusBarStyle = .lightContent
        return configuration
    }()

    private var documentMetadata: GiniHealthSDK.Document.Metadata?
    private let documentMetadataBranchId = "GiniHealthExampleIOS"
    private let documentMetadataAppFlowKey = "AppFlow"
    
    init(window: UIWindow) {
        self.window = window
        print("------------------------------------\n\n",
              "📸 Gini Capture SDK for iOS (\(GiniCapture.versionString))\n\n",
              "      - Client id:  \(clientID)\n",
              "      - Client email domain:  \(clientDomain)",
              "\n\n------------------------------------\n")
    }
    
    func start() {
        self.showSelectAPIScreen()
    }
    
    func processExternalDocument(withUrl url: URL, sourceApplication: String?) {
        
        // 1. Build the document
        let documentBuilder = GiniCaptureDocumentBuilder(documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        
        documentBuilder.build(with: url) { [weak self] (document) in
            
            guard let self = self else { return }
            
            // When a document is imported with "Open with", a dialog allowing to choose between both APIs
            // is shown in the main screen. Therefore it needs to go to the main screen if it is not there yet.
            self.popToRootViewControllerIfNeeded()
            
            // 2. Validate the document
            if let document = document {
                do {
                    try GiniCapture.validate(document,
                                             withConfig: self.giniConfiguration)
                    self.showOpenWithSwitchDialog(for: [GiniCapturePage(document: document, error: nil)])
                } catch {
                    self.showExternalDocumentNotValidDialog()
                }
            }
        }
    }
    
    func processBankUrl(url: URL) {
        rootViewController.dismiss(animated: true)
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        if let queryItems = components.queryItems {
            if let paymentRequestId = queryItems.first(where: { $0.name == "paymentRequestId" })?.value {
                selectAPIViewController.showActivityIndicator()
                health.getPaymentRequest(by: paymentRequestId) { [weak self] result in
                    DispatchQueue.main.async {
                        self?.selectAPIViewController.hideActivityIndicator()
                    }
                    switch result {
                    case .success(let paymentRequest):
                        GiniUtilites.Log("Successfully obtained payment request", event: .success)
                        DispatchQueue.main.async {
                            self?.showReturnMessage(message: self?.messageFor(status: PaymentStatus(rawValue: paymentRequest.status)) ?? "")
                        }
                    case .failure(let error):
                        GiniUtilites.Log("Failed to retrieve payment request: \(error.localizedDescription)", event: .error)
                    }
                }
            }
        }
    }
    
    private enum PaymentStatus: String {
        case paid
        case paidAdjusted = "paid_adjusted"
    }

    private func messageFor(status: PaymentStatus?) -> String {
        switch status {
        case .paid:
            return "Payment was successful 🎉"
        case .paidAdjusted:
            return "Payment was successful 🎉 with adjusted amount"
        default:
            return "Payment was unsuccessful 😢"
        }
    }
    
    fileprivate func showSelectAPIScreen() {
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
    
    fileprivate func showScreenAPI(with pages: [GiniCapturePage]? = nil) {
        let metadata = GiniHealthAPILibrary.Document.Metadata(branchId: documentMetadataBranchId,
                                                              additionalHeaders: [documentMetadataAppFlowKey: "ScreenAPI"])

        let screenAPICoordinator = ScreenAPICoordinator(configuration: giniConfiguration,
                                                        importedDocuments: pages?.map { $0.document },
                                                        client: GiniHealthAPILibrary.Client(id: clientID,
                                                                                            secret: clientPassword,
                                                                                            domain: clientDomain),
                                                                                            documentMetadata: metadata,
                                                        hardcodedInvoicesController: HardcodedInvoicesController())
        
        screenAPICoordinator.delegate = self
        
        health.delegate = self
        screenAPICoordinator.giniHealth = health
        
        let apiLib = health.giniApiLib
        screenAPICoordinator.start(healthAPI: apiLib)
        add(childCoordinator: screenAPICoordinator)
        
        rootViewController.present(screenAPICoordinator.rootViewController, animated: true)
    }
    
    private var testDocument: GiniHealthSDK.Document?
    private var testDocumentExtractions: [GiniHealthSDK.Extraction]?

    fileprivate func showPaymentReviewWithTestDocument() {
        health.delegate = self
        health.setConfiguration(giniHealthConfiguration)

        if let document = self.testDocument {
            self.selectAPIViewController.showActivityIndicator()
            
            self.health.fetchDataForReview(documentId: document.id) { result in
                switch result {
                case .success(let data):
                    self.health.documentService.extractions(for: data.document, cancellationToken: CancellationToken()) { [weak self] result in
                        switch result {
                        case let .success(extractionResult):
                            GiniUtilites.Log("Successfully fetched extractions for id: \(document.id)", event: .success)
                            let invoice = DocumentWithExtractions(documentId: document.id,
                                                                  extractionResult: extractionResult)
                            self?.showInvoicesList(invoices: [invoice])
                        case let .failure(error):
                            GiniUtilites.Log("Obtaining extractions from document with id \(document.id) failed with error: \(String(describing: error))", event: .error)
                        }
                    }
                case .failure(let error):
                    GiniUtilites.Log("Document data fetching failed: \(String(describing: error))", event: .error)
                    self.selectAPIViewController.hideActivityIndicator()
                }
            }
        } else {
            // Upload the test document image
            let testDocumentImage = UIImage(named: "testDocument")!
            let testDocumentData = testDocumentImage.jpegData(compressionQuality: 1)!
            
            self.selectAPIViewController.showActivityIndicator()
            
            self.health.documentService.createDocument(fileName: nil,
                                                       docType: nil,
                                                       type: .partial(testDocumentData),
                                                       metadata: nil) { result in
                switch result {
                case .success(let createdDocument):
                    let partialDocInfo = GiniHealthSDK.PartialDocumentInfo(document: createdDocument.links.document)
                    self.health.documentService.createDocument(fileName: nil,
                                                               docType: nil,
                                                               type: .composite(CompositeDocumentInfo(partialDocuments: [partialDocInfo])),
                                                               metadata: nil) { [weak self] result in
                        switch result {
                        case .success(let compositeDocument):
                            self?.health.setDocumentForReview(documentId: compositeDocument.id) { [weak self] result in
                                switch result {
                                case .success(let extractions):
                                    self?.testDocument = compositeDocument
                                    self?.testDocumentExtractions = extractions

                                    self?.health.documentService.extractions(for: compositeDocument, cancellationToken: CancellationToken()) { [weak self] result in
                                        switch result {
                                        case let .success(extractionResult):
                                            GiniUtilites.Log("Successfully fetched extractions for id: \(compositeDocument.id)", event: .success)
                                            let invoice = DocumentWithExtractions(documentId: compositeDocument.id,
                                                                                  extractionResult: extractionResult)
                                            self?.showInvoicesList(invoices: [invoice])
                                        case let .failure(error):
                                            GiniUtilites.Log("Obtaining extractions from document with id \(compositeDocument.id) failed with error: \(String(describing: error))", event: .error)
                                        }
                                    }
                                case .failure(let error):
                                    GiniUtilites.Log("Setting document for review failed: \(String(describing: error))", event: .error)
                                    self?.selectAPIViewController.hideActivityIndicator()
                                }
                            }
                        case .failure(let error):
                            GiniUtilites.Log("Document creation failed: \(String(describing: error))", event: .error)
                            self?.selectAPIViewController.hideActivityIndicator()
                        }
                    }
                case .failure(let error):
                    GiniUtilites.Log("Document creation failed: \(String(describing: error))", event: .error)
                    self.selectAPIViewController.hideActivityIndicator()
                }
            }
        }
    }
    
    fileprivate func showOpenWithSwitchDialog(for pages: [GiniCapturePage]) {
        let alertViewController = UIAlertController(title: "Importierte Datei",
                                                    message: "Möchten Sie die importierte Datei mit dem " +
                                                    "Gini Health SDK verwenden?",
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Ja", style: .default) { [weak self] _ in
            self?.showScreenAPI(with: pages)
        })
        
        rootViewController.present(alertViewController, animated: true)
    }
    
    fileprivate func showExternalDocumentNotValidDialog() {
        let alertViewController = UIAlertController(title: "Ungültiges Dokument",
                                                    message: "Dies ist kein gültiges Dokument",
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true)
        })
        
        rootViewController.present(alertViewController, animated: true)
    }
    
    fileprivate func showReturnMessage(message: String) {
        let alertViewController = UIAlertController(title: "Congratulations",
                                                    message: message,
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true)
        })
        
        rootViewController.present(alertViewController, animated: true)
    }
    
    fileprivate func popToRootViewControllerIfNeeded() {
        self.childCoordinators.forEach { coordinator in
            coordinator.rootViewController.dismiss(animated: true)
            self.remove(childCoordinator: coordinator)
        }
    }
    
    fileprivate func showInvoicesList(invoices: [DocumentWithExtractions]? = nil) {
        DispatchQueue.main.async {
            self.selectAPIViewController.hideActivityIndicator()
        }

        giniHealthConfiguration.useInvoiceWithoutDocument = false
        health.setConfiguration(giniHealthConfiguration)
        health.delegate = self

        let invoicesListCoordinator = InvoicesListCoordinator()
        DispatchQueue.main.async {
            invoicesListCoordinator.start(documentService: self.health.documentService,
                                          hardcodedInvoicesController: HardcodedInvoicesController(),
                                          health: self.health,
                                          invoices: invoices)
            self.add(childCoordinator: invoicesListCoordinator)
            self.rootViewController.present(invoicesListCoordinator.rootViewController, animated: true)
        }
    }

    fileprivate func showOrdersList(orders: [Order]? = nil) {
        DispatchQueue.main.async {
            self.selectAPIViewController.hideActivityIndicator()
        }

        giniHealthConfiguration.useInvoiceWithoutDocument = true
        health.setConfiguration(giniHealthConfiguration)
        health.delegate = self
        
        let orderListCoordinator = OrderListCoordinator()
        orderListCoordinator.start(documentService: health.documentService,
                                   hardcodedOrdersController: HardcodedOrdersController(),
                                   health: health,
                                   orders: orders)
        add(childCoordinator: orderListCoordinator)
        rootViewController.present(orderListCoordinator.rootViewController, animated: true)
    }
}

// MARK: SelectAPIViewControllerDelegate

extension AppCoordinator: SelectAPIViewControllerDelegate {
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniCaptureAPIType) {
        switch api {
        case .screen:
            showScreenAPI()
        case .component:
            break
        case .paymentReview:
            showPaymentReviewWithTestDocument()
        case .invoicesList:
            showInvoicesList()
        case .ordersList:
            showOrdersList()
        }
    }
}

// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    func presentError(title: String, message: String) {
        self.rootViewController.showError(title, message: message)
    }
    
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true)
        self.remove(childCoordinator: coordinator)
    }
    
    func presentInvoicesList(invoices: [DocumentWithExtractions]?) {
        self.showInvoicesList(invoices: invoices)
    }
}

// MARK: GiniHealthDelegate

extension AppCoordinator: GiniHealthDelegate {
    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        return true
    }
    
    func didCreatePaymentRequest(paymentRequestId: String) {
        GiniUtilites.Log("Created payment request with id \(paymentRequestId)", event: .success)
        DispatchQueue.main.async {
            guard let invoicesListCoordinator = self.childCoordinators.first as? InvoicesListCoordinator else {
                return
            }
            invoicesListCoordinator.invoicesListViewController.presentedViewController?.dismiss(animated: true)
        }
    }
}

//MARK: - DebugMenuPresenterDelegate

extension AppCoordinator: DebugMenuPresenter {
    func presentDebugMenu() {
        let debugMenuViewController = DebugMenuViewController(showReviewScreen: giniHealthConfiguration.showPaymentReviewScreen,
                                                              useBottomPaymentComponent: giniHealthConfiguration.useBottomPaymentComponentView,
                                                              paymentComponentConfiguration: health.paymentComponentConfiguration)
        debugMenuViewController.delegate = self
        rootViewController.present(debugMenuViewController, animated: true)
    }
}

//MARK: - DebugMenuDelegate
extension AppCoordinator: DebugMenuDelegate {
    func didChangeSwitchValue(type: SwitchType, isOn: Bool) {
        switch type {
        case .showReviewScreen:
            giniHealthConfiguration.showPaymentReviewScreen = isOn
        case .showBrandedView:
            health.paymentComponentConfiguration.isPaymentComponentBranded = isOn
        case .useBottomPaymentComponent:
            giniHealthConfiguration.useBottomPaymentComponentView = isOn
        }
    }

    func didPickNewLocalization(localization: GiniLocalization) {
        giniHealthConfiguration.customLocalization = localization
        health.setConfiguration(giniHealthConfiguration)
    }
}
