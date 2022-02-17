//
//  AppCoordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniCaptureSDK
import GiniHealthAPILibrary
import GiniHealthSDK

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    fileprivate let window: UIWindow
    fileprivate var screenAPIViewController: UIViewController?
    var rootViewController: UIViewController {
        return selectAPIViewController
    }
    lazy var selectAPIViewController: SelectAPIViewController = {
        let selectAPIViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "selectAPIViewController") as? SelectAPIViewController)!
        selectAPIViewController.delegate = self
        selectAPIViewController.clientId = self.client.id
        return selectAPIViewController
    }()
    
    lazy var giniConfiguration: GiniConfiguration = {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.openWithEnabled = true
        giniConfiguration.qrCodeScanningEnabled = true
        giniConfiguration.multipageEnabled = true
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.navigationBarItemTintColor = .white
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
    
    private lazy var client: Client = CredentialsManager.fetchClientFromBundle()
    lazy var apiLib = GiniHealthAPI.Builder(client: client).build()
    lazy var health = GiniHealth(with: apiLib)

    private var documentMetadata: Document.Metadata?
    private let documentMetadataBranchId = "GiniHealthExampleIOS"
    private let documentMetadataAppFlowKey = "AppFlow"

    init(window: UIWindow) {
        self.window = window
        print("------------------------------------\n\n",
              "📸 Gini Capture SDK for iOS (\(GiniCapture.versionString))\n\n",
            "      - Client id:  \(client.id)\n",
            "      - Client email domain:  \(client.domain)",
            "\n\n------------------------------------\n")
    }
    
    func start() {
        try! apiLib.removeStoredCredentials()
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
    
    func processBankUrl() {
            self.popToRootViewControllerIfNeeded()
            showReturnMessage()
        }
    
    fileprivate func showSelectAPIScreen() {
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
    
    
    fileprivate func showComponentAPI(with pages: [GiniCapturePage]? = nil) {
        checkIfAnyBankingAppsInstalled(from: self.rootViewController) {
            let componentAPICoordinator = ComponentAPICoordinator(pages: pages ?? [],
                                                                  configuration: self.giniConfiguration,
                                                                  documentService: self.componentAPIDocumentService(),
                                                                  giniHealth: self.health)
            componentAPICoordinator.delegate = self
            componentAPICoordinator.start()
            self.add(childCoordinator: componentAPICoordinator)

            self.rootViewController.present(componentAPICoordinator.rootViewController, animated: true, completion: nil)
        }
    }
    
    private var testDocument: Document?
    private var testDocumentExtractions: [Extraction]?
    
    fileprivate func checkIfAnyBankingAppsInstalled(from viewController: UIViewController, completion: @escaping () -> Void) {
        health.checkIfAnyPaymentProviderAvailable { result in
            switch(result) {
            case .success(_):
                completion()
            case .failure(_):
                let alertViewController = UIAlertController(title: "",
                                                            message: "We didn't find any banking apps installed",
                                                            preferredStyle: .alert)
                
                alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    alertViewController.dismiss(animated: true, completion: nil)
                })
                viewController.present(alertViewController, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func showPaymentReviewWithTestDocument() {
        let configuration = GiniHealthConfiguration()
        // Font configuration
        let regularFont = UIFont(name: "Avenir", size: 15) ?? UIFont.systemFont(ofSize: 15)
        configuration.customFont = GiniFont(regular: regularFont, bold: regularFont, light: regularFont, thin: regularFont)
        // Pay button configuration
        configuration.payButtonTextColor = GiniColor(lightModeColor: .white, darkModeColor: .white)
        
        // Page indicator color configuration
        configuration.currentPageIndicatorTintColor = GiniColor(lightModeColor: .systemBlue, darkModeColor: .systemBlue)
        configuration.pageIndicatorTintColor = GiniColor(lightModeColor: .darkGray, darkModeColor: .darkGray)
        
        // Show the close button to dismiss the payment review screen
        configuration.showPaymentReviewCloseButton = true
        health.delegate = self
        health.setConfiguration(configuration)
        
        checkIfAnyBankingAppsInstalled(from: self.rootViewController) {
            if let document = self.testDocument, let extractions = self.testDocumentExtractions {
                // Show the payment review screen
                let vc = PaymentReviewViewController.instantiate(with: self.health, document: document, extractions: extractions, trackingDelegate: self)
                self.rootViewController.present(vc, animated: true)
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
                        let partialDocInfo = PartialDocumentInfo(document: createdDocument.links.document)
                        self.health.documentService.createDocument(fileName: nil,
                                                                docType: nil,
                                                                type: .composite(CompositeDocumentInfo(partialDocuments: [partialDocInfo])),
                                                                metadata: nil) { result in
                            switch result {
                            case .success(let compositeDocument):
                                self.health.setDocumentForReview(documentId: compositeDocument.id) { result in
                                    switch result {
                                    case .success(let extractions):
                                        self.testDocument = compositeDocument
                                        self.testDocumentExtractions = extractions
                                        
                                        // Show the payment review screen
                                        let vc = PaymentReviewViewController.instantiate(with: self.health, document: compositeDocument, extractions: extractions, trackingDelegate: self)
                                        self.rootViewController.present(vc, animated: true)
                                    case .failure(let error):
                                        print("❌ Setting document for review failed: \(String(describing: error))")
                                    }
                                    self.selectAPIViewController.hideActivityIndicator()
                                }
                            case .failure(let error):
                                print("❌ Document creation failed: \(String(describing: error))")
                                self.selectAPIViewController.hideActivityIndicator()
                            }
                        }
                    case .failure(let error):
                        print("❌ Document creation failed: \(String(describing: error))")
                        self.selectAPIViewController.hideActivityIndicator()
                    }
                }
            }
        }
    }
    
    fileprivate func componentAPIDocumentService() -> ComponentAPIDocumentServiceProtocol {
        
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                             additionalHeaders: [documentMetadataAppFlowKey: "ComponentAPI"])
        return ComponentAPIDocumentsService(lib: apiLib, documentMetadata: documentMetadata)
    }
    
    
    fileprivate func showOpenWithSwitchDialog(for pages: [GiniCapturePage]) {
        let alertViewController = UIAlertController(title: "Importierte Datei",
                                                    message: "Möchten Sie die importierte Datei mit dem " +
            "ScreenAPI oder ComponentAPI verwenden?",
                                                    preferredStyle: .alert)
               
        alertViewController.addAction(UIAlertAction(title: "Component API", style: .default) { [weak self] _ in
            self?.showComponentAPI(with: pages)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func showExternalDocumentNotValidDialog() {
        let alertViewController = UIAlertController(title: "Ungültiges Dokument",
                                                    message: "Dies ist kein gültiges Dokument",
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func showReturnMessage() {
        let alertViewController = UIAlertController(title: "Congratulations",
                                                    message: "Payment was successful 🎉",
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func popToRootViewControllerIfNeeded() {
        self.childCoordinators.forEach { coordinator in
            coordinator.rootViewController.dismiss(animated: true, completion: nil)
            self.remove(childCoordinator: coordinator)
        }
    }
}

// MARK: SelectAPIViewControllerDelegate

extension AppCoordinator: SelectAPIViewControllerDelegate {
    
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniCaptureAPIType) {
        switch api {
        case .screen:
            break
        case .component:
            showComponentAPI()
        case .paymentReview:
            showPaymentReviewWithTestDocument()
        }
    }
    
}

// MARK: ComponentAPICoordinatorDelegate

extension AppCoordinator: ComponentAPICoordinatorDelegate {
    func componentAPI(coordinator: ComponentAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.remove(childCoordinator: coordinator)
    }
}

// MARK: GiniHealthDelegate

extension AppCoordinator: GiniHealthDelegate {
    func shouldHandleErrorInternally(error: GiniHealthError) -> Bool {
        return true
    }
    
    func didCreatePaymentRequest(paymentRequestID: String) {
        print("✅ Created payment request with id \(paymentRequestID)")
    }
}

// MARK: GiniHealthTrackingDelegate

extension AppCoordinator: GiniHealthTrackingDelegate {
    func onPaymentReviewScreenEvent(event: TrackingEvent<PaymentReviewScreenEventType>) {
        switch event.type {
        case .onNextButtonClicked:
            print("📝 Next button was tapped")
        case .onCloseButtonClicked:
            print("📝 Close screen was triggered")
        case .onCloseKeyboardButtonClicked:
            print("📝 Close keyboard was triggered")
        case .onBankSelectionButtonClicked:
            print("📝 Bank selection button was tapped,\(String(describing: event.info))")
        }
    }
}
