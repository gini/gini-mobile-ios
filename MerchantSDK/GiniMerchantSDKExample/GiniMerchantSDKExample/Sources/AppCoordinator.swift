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

        add(childCoordinator: screenAPICoordinator)
        
        rootViewController.present(screenAPICoordinator.rootViewController, animated: true)
    }
    
    private var testDocument: Document?
    private var testDocumentExtractions: [GiniMerchantSDK.Extraction]?

    private let configuration = GiniMerchantConfiguration()

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
    
    fileprivate func showInvoicesList(invoices: [InvoiceItem]? = nil) {
        self.selectAPIViewController.hideActivityIndicator()
        
        // Show the close button to dismiss the payment review screen
        configuration.showPaymentReviewCloseButton = true
        configuration.paymentReviewStatusBarStyle = .lightContent

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
            break
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
    
    func presentInvoicesList(invoices: [InvoiceItem]?) {
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
        let debugMenuViewController = DebugMenuViewController(showReviewScreen: configuration.showPaymentReviewScreen, isAmountFieldEditable: configuration.isAmountFieldEditable)
        debugMenuViewController.delegate = self
        rootViewController.present(debugMenuViewController, animated: true)
    }
}

extension AppCoordinator: DebugMenuDelegate {
    func didChangeReviewScreenSwitchValue(isOn: Bool) {
        configuration.showPaymentReviewScreen = isOn
    }
    
    func didChangeAmountEditableSwitchValue(isOn: Bool) {
        configuration.isAmountFieldEditable = isOn
    }
}
