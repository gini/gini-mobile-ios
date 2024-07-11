//
//  AppCoordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK
import GiniMerchantSDK

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
    
    private lazy var merchant = GiniMerchant(id: clientID, secret: clientPassword, domain: clientDomain)
    private lazy var paymentComponentsController = PaymentComponentsController(giniMerchant: merchant)
    
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
        paymentComponentsController.delegate = self
        paymentComponentsController.loadPaymentProviders()
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
    
    func processBankUrl() {
        rootViewController.dismiss(animated: true)
        showReturnMessage()
        
    }
    
    fileprivate func showSelectAPIScreen() {
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
    
    fileprivate func showScreenAPI(with pages: [GiniCapturePage]? = nil) {
        let screenAPICoordinator = ScreenAPICoordinator(configuration: giniConfiguration,
                                                        importedDocuments: pages?.map { $0.document },
                                                        hardcodedInvoicesController: HardcodedInvoicesController(),
                                                        paymentComponentController: paymentComponentsController)
        
        screenAPICoordinator.delegate = self
        
        merchant.delegate = self
        screenAPICoordinator.giniMerchant = merchant
        
        screenAPICoordinator.start(documentService: merchant.documentService)
        add(childCoordinator: screenAPICoordinator)
        
        rootViewController.present(screenAPICoordinator.rootViewController, animated: true)
    }
    
    private var testDocument: Document?
    private var testDocumentExtractions: [GiniMerchantSDK.Extraction]?

    private var showPaymentReviewScreen = true
    private var isAmountFieldEditable = false

    fileprivate func showPaymentReviewWithTestDocument() {
        merchant.delegate = self
        let configuration = GiniMerchantConfiguration()
        merchant.setConfiguration(configuration)

        if let document = self.testDocument {
            self.selectAPIViewController.showActivityIndicator()

            self.merchant.fetchDataForReview(documentId: document.id) { result in
                switch result {
                case .success(let data):
                    self.merchant.documentService.extractions(for: data.document, cancellationToken: CancellationToken()) { [weak self] result in
                        switch result {
                        case let .success(extractionResult):
                            print("✅Successfully fetched extractions for id: \(document.id)")
                            let invoice = DocumentWithExtractions(documentID: document.id,
                                                                  extractionResult: extractionResult)
                            self?.showInvoicesList(invoices: [invoice])
                        case let .failure(error):
                            print("❌Obtaining extractions from document with id \(document.id) failed with error: \(String(describing: error))")
                        }
                    }
                case .failure(let error):
                    print("❌ Document data fetching failed: \(String(describing: error))")
                    self.selectAPIViewController.hideActivityIndicator()
                }
            }
        } else {
            // Upload the test document image
            let testDocumentImage = UIImage(named: "testDocument")!
            let testDocumentData = testDocumentImage.jpegData(compressionQuality: 1)!

            self.selectAPIViewController.showActivityIndicator()

            self.merchant.documentService.createDocument(fileName: nil,
                                                       docType: nil,
                                                       type: .partial(testDocumentData),
                                                       metadata: nil) { result in
                switch result {
                case .success(let createdDocument):
                    let partialDocInfo = GiniMerchantSDK.PartialDocumentInfo(document: createdDocument.links.document)
                    self.merchant.documentService.createDocument(fileName: nil,
                                                               docType: nil,
                                                               type: .composite(CompositeDocumentInfo(partialDocuments: [partialDocInfo])),
                                                               metadata: nil) { [weak self] result in
                        switch result {
                        case .success(let compositeDocument):
                            self?.merchant.setDocumentForReview(documentId: compositeDocument.id) { [weak self] result in
                                switch result {
                                case .success(let extractions):
                                    self?.testDocument = compositeDocument
                                    self?.testDocumentExtractions = extractions

                                    self?.merchant.documentService.extractions(for: compositeDocument, cancellationToken: CancellationToken()) { [weak self] result in
                                        switch result {
                                        case let .success(extractionResult):
                                            print("✅Successfully fetched extractions for id: \(compositeDocument.id)")
                                            let invoice = DocumentWithExtractions(documentID: compositeDocument.id,
                                                                                  extractionResult: extractionResult)
                                            self?.showInvoicesList(invoices: [invoice])
                                        case let .failure(error):
                                            print("❌Obtaining extractions from document with id \(compositeDocument.id) failed with error: \(String(describing: error))")
                                        }
                                    }
                                case .failure(let error):
                                    print("❌ Setting document for review failed: \(String(describing: error))")
                                    self?.selectAPIViewController.hideActivityIndicator()
                                }
                            }
                        case .failure(let error):
                            print("❌ Document creation failed: \(String(describing: error))")
                            self?.selectAPIViewController.hideActivityIndicator()
                        }
                    }
                case .failure(let error):
                    print("❌ Document creation failed: \(String(describing: error))")
                    self.selectAPIViewController.hideActivityIndicator()
                }
            }
        }
    }

    fileprivate func showOpenWithSwitchDialog(for pages: [GiniCapturePage]) {
        let alertViewController = UIAlertController(title: "Importierte Datei",
                                                    message: "Möchten Sie die importierte Datei mit dem " +
                                                    "Gini Merchant SDK verwenden?",
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
    
    fileprivate func showReturnMessage() {
        let alertViewController = UIAlertController(title: "Congratulations",
                                                    message: "Payment was successful 🎉",
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
        self.selectAPIViewController.hideActivityIndicator()
        let configuration = GiniMerchantConfiguration()
        
        // Show the close button to dismiss the payment review screen
        configuration.showPaymentReviewCloseButton = true
        configuration.paymentReviewStatusBarStyle = .lightContent
        configuration.showPaymentReviewScreen = showPaymentReviewScreen
        configuration.isAmountFieldEditable = isAmountFieldEditable

        merchant.setConfiguration(configuration)
        merchant.delegate = self

        let invoicesListCoordinator = InvoicesListCoordinator()
        paymentComponentsController = PaymentComponentsController(giniMerchant: merchant)
        invoicesListCoordinator.start(documentService: merchant.documentService,
                                      hardcodedInvoicesController: HardcodedInvoicesController(),
                                      paymentComponentsController: paymentComponentsController,
                                      invoices: invoices)
        add(childCoordinator: invoicesListCoordinator)
        rootViewController.present(invoicesListCoordinator.rootViewController, animated: true)
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
        }
    }
}

// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true)
        self.remove(childCoordinator: coordinator)
    }
    
    func presentInvoicesList(invoices: [DocumentWithExtractions]?) {
        self.showInvoicesList(invoices: invoices)
    }
}

// MARK: GiniMerchantDelegate

extension AppCoordinator: GiniMerchantDelegate {
    func shouldHandleErrorInternally(error: GiniMerchantError) -> Bool {
        return true
    }
    
    func didCreatePaymentRequest(paymentRequestID: String) {
        print("✅ Created payment request with id \(paymentRequestID)")
    }
}

// MARK: GiniMerchantTrackingDelegate

extension AppCoordinator: GiniMerchantTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onToTheBankButtonClicked:
            print("📝 To the banking app button was tapped,\(String(describing: event.info))")
        case .onCloseButtonClicked:
            print("📝 Close screen was triggered")
        case .onCloseKeyboardButtonClicked:
            print("📝 Close keyboard was triggered")
        }
    }
}

// MARK: PaymentComponentControllerDelegate

extension AppCoordinator: PaymentComponentsControllerProtocol {
    func isLoadingStateChanged(isLoading: Bool) {
        if isLoading {
            selectAPIViewController.showActivityIndicator()
        } else {
            selectAPIViewController.hideActivityIndicator()
        }
    }
    
    func didFetchedPaymentProviders() {
        //
    }
}

//MARK: - DebugMenuPresenterDelegate

extension AppCoordinator: DebugMenuPresenter {
    func presentDebugMenu() {
        let debugMenuViewController = DebugMenuViewController(showReviewScreen: showPaymentReviewScreen, isAmountFieldEditable: isAmountFieldEditable)
        debugMenuViewController.delegate = self
        rootViewController.present(debugMenuViewController, animated: true)
    }
}

extension AppCoordinator: DebugMenuDelegate {
    func didChangeReviewScreenSwitchValue(isOn: Bool) {
        self.showPaymentReviewScreen = isOn
    }
    
    func didChangeAmountEditableSwitchValue(isOn: Bool) {
        self.isAmountFieldEditable = isOn
    }
}
