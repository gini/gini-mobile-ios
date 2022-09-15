//
//  AppCoordinator.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import Foundation
import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary
import GiniBankSDK

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

    lazy var configuration: GiniBankConfiguration = {
        let configuration = GiniBankConfiguration()
        configuration.debugModeOn = true
        configuration.fileImportSupportedTypes = .pdf_and_images
        configuration.openWithEnabled = true
        configuration.qrCodeScanningEnabled = true
        configuration.multipageEnabled = true
        configuration.flashToggleEnabled = true
        configuration.navigationBarItemTintColor = .white
        configuration.navigationBarTintColor = Colors.Gini.blue
        configuration.localizedStringsTableName = "LocalizableCustomName"
        configuration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 5 * 1024 * 1024
            if document.data.count > maxFileSize {
                let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als 5MB")
                return CustomDocumentValidationResult.failure(withError: error)
            }
            return CustomDocumentValidationResult.success()
        }
//        let customMenuItem = HelpMenuViewController.Item.custom("Custom menu item", CustomMenuItemViewController())
//        configuration.customMenuItems = [customMenuItem]
//        configuration.albumsScreenSelectMorePhotosTextColor = GiniColor(lightModeColor: .systemBlue, darkModeColor: .systemBlue)
        
        // A few return assistant customisation examples
//        configuration.digitalInvoiceLineItemEditButtonTintColor = Colors.Gini.bluishGreen
//        configuration.lineItemBorderColor = Colors.Gini.paleGreen
//        configuration.digitalInvoiceLineItemToggleSwitchTintColor = Colors.Gini.springGreen
//        configuration.digitalInvoiceLineItemsDisabledColor = Colors.Gini.raspberry.withAlphaComponent(0.2)
//        configuration.lineItemDetailsContentHighlightedColor = Colors.Gini.paleGreen

        // A few camera screen customisation examples
//        configuration.navigationBarItemFont = UIFont.systemFont(ofSize: 20, weight: .bold)
//        configuration.navigationBarCameraTitleHelpButton = "? Help"
//        configuration.cameraPreviewFrameColor = .init(lightModeColor: UIColor.init(white: 0.5, alpha: 0.1), darkModeColor: UIColor.init(white: 0.5, alpha: 0.3))
//        configuration.cameraButtonsViewBackgroundColor = .init(lightModeColor: UIColor.darkGray, darkModeColor: UIColor.darkGray)
//        configuration.cameraContainerViewBackgroundColor = .init(lightModeColor: UIColor.darkGray, darkModeColor: UIColor.darkGray)
//
//        configuration.multipagePageSuccessfullUploadIconBackgroundColor = .systemGreen
//        configuration.multipagePageFailureUploadIconBackgroundColor = .systemRed
//        configuration.enableReturnReasons = false
        
    // If you need to scale your font please use our method `scaledFont()`. Please, find the example below.
//    let customFontToBeScaled = UIFont.scaledFont(UIFont(name: "Avenir", size: 20) ?? UIFont.systemFont(ofSize: 7, weight: .regular), textStyle: .caption1)
//    configuration.updateFont(customFontToBeScaled, for: .caption1)
        
    // If you would like to pass us already scaled font.
//    let customScaledFont = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 28))
//    configuration.updateFont(customScaledFont, for: .caption2)
//    configuration.primaryButtonBorderWidth = 10
//    configuration.primaryButtonShadowColor = UIColor.red.cgColor
//    configuration.primaryButtonShadowRadius = 10
//    configuration.primaryButtonShadowOpacity = 0.7
//    configuration.primaryButtonCornerRadius = 10
//    configuration.customOnboardingPages = [OnboardingPageNew(imageName: "captureSuggestion1", title: "Page 1", description: "Description for page 1")]
        
       return configuration
    }()
    
    private lazy var client: Client = CredentialsManager.fetchClientFromBundle()
    private var documentMetadata: Document.Metadata?
    private let documentMetadataBranchId = "GVLExampleIOS"
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
        self.showSelectAPIScreen()
    }
    
    func processExternalDocument(withUrl url: URL, sourceApplication: String?) {
        
        let captureConfiguration = configuration.captureConfiguration()
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
                                             withConfig: captureConfiguration)
                    self.showOpenWithSwitchDialog(for: [GiniCapturePage(document: document, error: nil)])
                } catch {
                    self.showExternalDocumentNotValidDialog()
                }
            }
        }
    }
    
    fileprivate func showSelectAPIScreen() {
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
    
    fileprivate func showScreenAPI(with pages: [GiniCapturePage]? = nil) {
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                             additionalHeaders: [documentMetadataAppFlowKey: "ScreenAPI"])
        let screenAPICoordinator = ScreenAPICoordinator(configuration: configuration,
                                                        importedDocuments: pages?.map { $0.document },
                                                        client: client,
                                                        documentMetadata: documentMetadata)
        screenAPICoordinator.delegate = self
        screenAPICoordinator.start()
        add(childCoordinator: screenAPICoordinator as Coordinator)
        
        rootViewController.present(screenAPICoordinator.rootViewController, animated: true, completion: nil)
    }
    
    fileprivate func showComponentAPI(with pages: [GiniCapturePage]? = nil) {
        let componentAPICoordinator = ComponentAPICoordinator(pages: pages ?? [],
                                                              configuration: configuration,
                                                              documentService: componentAPIDocumentService())
        componentAPICoordinator.delegate = self
        componentAPICoordinator.start()
        add(childCoordinator: componentAPICoordinator)
        
        rootViewController.present(componentAPICoordinator.rootViewController, animated: true, completion: nil)
    }
    
    fileprivate func componentAPIDocumentService() -> ComponentAPIDocumentServiceProtocol {
        let lib = GiniBankAPI.Builder(client: client).build()
        
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                             additionalHeaders: [documentMetadataAppFlowKey: "ComponentAPI"])
        return ComponentAPIDocumentsService(lib: lib, documentMetadata: documentMetadata)
    }
    
    fileprivate func showSettings() {
        let settingsViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "settingsViewController") as? SettingsViewController)!
        settingsViewController.delegate = self
        settingsViewController.giniConfiguration = configuration.captureConfiguration()
        settingsViewController.modalPresentationStyle = .overFullScreen
        settingsViewController.modalTransitionStyle = .crossDissolve
        
        rootViewController.present(settingsViewController, animated: true, completion: nil)
    }
    
    fileprivate func showOpenWithSwitchDialog(for pages: [GiniCapturePage]) {
        let alertViewController = UIAlertController(title: "Importierte Datei",
                                                    message: "Möchten Sie die importierte Datei mit dem " +
            "ScreenAPI oder ComponentAPI verwenden?",
                                                    preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Screen API", style: .default) {[weak self] _ in
            self?.showScreenAPI(with: pages)
        })
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
    
    fileprivate func popToRootViewControllerIfNeeded() {
        self.childCoordinators.forEach { coordinator in
            coordinator.rootViewController.dismiss(animated: true, completion: nil)
            self.remove(childCoordinator: coordinator)
        }
    }
}

// MARK: SelectAPIViewControllerDelegate

extension AppCoordinator: SelectAPIViewControllerDelegate {
    
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniPayBankApiType) {
        switch api {
        case .screen:
            showScreenAPI()
        case .component:
            showComponentAPI()
        }
    }
    
    func selectAPI(viewController: SelectAPIViewController, didTapSettings: ()) {
        showSettings()
    }
}

extension AppCoordinator: SettingsViewControllerDelegate {
    func settings(settingViewController: SettingsViewController,
                  didChangeConfiguration captureConfiguration: GiniConfiguration) {
        configuration.updateConfiguration(withCaptureConfiguration: captureConfiguration)
    }
}

// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    func screenAPIShowNoResults(coordinator: ScreenAPICoordinator) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.remove(childCoordinator: coordinator as Coordinator)
        
        let customNoResultsScreen = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "noResultScreen") as? NoResultViewController)!
        customNoResultsScreen.delegate = self
        rootViewController.present(customNoResultsScreen, animated: true)
    }
    
    func screenAPIShouldRestart(coordinator: ScreenAPICoordinator) {
        coordinator.rootViewController.dismiss(animated: false, completion: nil)
        coordinator.start()
        rootViewController.present(coordinator.rootViewController, animated: false, completion: nil)
    }
    
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.remove(childCoordinator: coordinator as Coordinator)
    }
}

// MARK: ComponentAPICoordinatorDelegate

extension AppCoordinator: ComponentAPICoordinatorDelegate {
    func componentAPI(coordinator: ComponentAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.remove(childCoordinator: coordinator)
    }
}

// MARK: - NoResultsScreenDelegate
extension AppCoordinator: NoResultsScreenDelegate {
    func noResults(viewController: NoResultViewController, didTapRetry: ()) {
        viewController.dismiss(animated: true)
        showScreenAPI()
    }
}
