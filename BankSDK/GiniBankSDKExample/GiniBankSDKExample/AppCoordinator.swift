//
//  AppCoordinator.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

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
        let configuration = GiniBankConfiguration.shared
        configuration.debugModeOn = true
        configuration.fileImportSupportedTypes = .pdf_and_images
        configuration.openWithEnabled = true
        configuration.qrCodeScanningEnabled = true
        configuration.multipageEnabled = true
        configuration.flashToggleEnabled = true
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

		configuration.onboardingShowAtLaunch = false
		configuration.onboardingShowAtFirstLaunch = true
		
		configuration.returnAssistantEnabled = false
//        configuration.cameraNavigationBarBottomAdapter = CustomCameraBottomNavigationBarAdapter()
//        configuration.onlyQRCodeScanningEnabled = true
//        configuration.bottomNavigationBarEnabled = true
//        configuration.noResultNavigationBarBottomAdapter = CustomBottomNavigationBarAdapter()
//        configuration.helpNavigationBarBottomAdapter = CustomBottomNavigationBarAdapter()
//        configuration.imagePickerNavigationBarBottomAdapter = CustomBottomNavigationBarAdapter()
//        configuration.reviewNavigationBarBottomAdapter = CustomReviewScreenBottomNavigationBarAdapter()
//        configuration.onboardingNavigationBarBottomAdapter = CustomOnboardingBottomNavigationBarAdapter()
//        configuration.cameraNavigationBarBottomAdapter = CustomCameraBottomNavigationBarAdapter()
//        configuration.digitalInvoiceHelpNavigationBarBottomAdapter = CustomBottomNavigationBarAdapter()
//        configuration.digitalInvoiceOnboardingNavigationBarBottomAdapter = CustomDigitalInvoiceOnboardingBottomNavigationBarAdapter()
//        configuration.digitalInvoiceNavigationBarBottomAdapter = CustomDigitalInvoiceBottomNavigationBarAdapter()

//        let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())
//        configuration.customMenuItems = [customMenuItem]

//        configuration.enableReturnReasons = false
//		configuration.shouldShowDragAndDropTutorial = true
        
    // If you need to scale your font please use our method `scaledFont()`. Please, find the example below.
//    let customFontToBeScaled = UIFont.scaledFont(UIFont(name: "Avenir", size: 20) ?? UIFont.systemFont(ofSize: 7, weight: .regular), textStyle: .caption1)
//    configuration.updateFont(customFontToBeScaled, for: .caption1)
        
    // If you would like to pass us already scaled font.
//    let customScaledFont = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 28))
//    configuration.updateFont(customScaledFont, for: .caption2)

//		configuration.customOnboardingPages = [OnboardingPage(imageName: "captureSuggestion1",
//															  title: "Page 1",
//															  description: "Description for page 1")]
        //configuration.onboardingAlignCornersIllustrationAdapter = CustomOnboardingIllustrationAdapter(animationName: "page1Animation", backgroundColor: UIColor.red)
        //configuration.onboardingLightingIllustrationAdapter = CustomOnboardingIllustrationAdapter(animationName: "cameraAnimation", backgroundColor: UIColor.yellow)
        //configuration.onboardingMultiPageIllustrationAdapter = CustomOnboardingIllustrationAdapter(animationName: "uploadAnimation", backgroundColor: UIColor.green)
        //configuration.onboardingQRCodeIllustrationAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation", backgroundColor: UIColor.blue)
//        configuration.digitalInvoiceOnboardingIllustrationAdapter = CustomOnboardingIllustrationAdapter(animationName: "magicAnimation", backgroundColor: UIColor.blue)

//       //  Custom loading indicator customization example for the analysis screen
//        let customLoadingIndicator = CustomLoadingIndicator()
//        configuration.customLoadingIndicator = customLoadingIndicator

//      // Custom loading indicator customization example for the on button laoding indicator
//        let customButtonLoadingIndicator = OnButtonLoading()
//        configuration.onButtonLoadingIndicator = customButtonLoadingIndicator
        
        // Custom navigation view controller
//        let navigationViewController = UINavigationController()
//        navigationViewController.navigationBar.backgroundColor = GiniColor(light: .purple, dark: .lightGray).uiColor()
//        configuration.customNavigationController = navigationViewController

        // Custom button configuration example
//        configuration.primaryButtonConfiguration = ButtonConfiguration(backgroundColor: .yellow,
//                                                                       borderColor: .red,
//                                                                       titleColor: .green,
//                                                                       shadowColor: .clear,
//                                                                       cornerRadius: 22,
//                                                                       borderWidth: 4,
//                                                                       shadowRadius: 0,
//                                                                       withBlurEffect: false)
		
//		configuration.giniErrorLoggerIsOn = true
       return configuration
    }()
    
    private lazy var client: Client = CredentialsManager.fetchClientFromBundle()
    private var documentMetadata: Document.Metadata?
    private let documentMetadataBranchId = "GVLExampleIOS"
    private let documentMetadataAppFlowKey = "AppFlow"
    private let groupName = "group.bank.extension.test"
    private let imageDataKey = "imageData"

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
                    self.showOpenWithSwitchDialog(
                        for: [GiniCapturePage(document: document, error: nil)])
                } catch  {
                    self.rootViewController.showErrorDialog(for: error, positiveAction: nil)
                }            // When a document is imported with "Open with", a dialog allowing to choose between both APIs
                // is shown in the main screen. Therefore it needs to go to the main screen if it is not there yet.

            }
        }
    }
    
    func processExternalDocumentFromPhotos(withUrl url: URL, sourceApplication: String?) {
        let captureConfiguration = configuration.captureConfiguration()
        // 1. Build the document
        let documentBuilder = GiniCaptureDocumentBuilder(documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        
        // Get saved imageData which was save in the extension from the group extension UserDefaults
        // Build document with imageData because it's not possible to do it for the url from Photos
        if let userDefaults = UserDefaults(suiteName: groupName) {
            if let data = userDefaults.value(forKey: imageDataKey) {
             if let doc = documentBuilder.build(with: data as! Data, fileName: "image") {
                     // When a document is imported with "Open with", a dialog allowing to choose between both APIs
                     // is shown in the main screen. Therefore it needs to go to the main screen if it is not there yet.

                     self.popToRootViewControllerIfNeeded()
                     do {
                         try GiniCapture.validate(doc,
                                                  withConfig: captureConfiguration)
                         self.showOpenWithSwitchDialog(
                             for: [GiniCapturePage(document: doc, error: nil)])
                     } catch  {
                         self.rootViewController.showErrorDialog(for: error, positiveAction: nil)
                     }
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
		screenAPICoordinator.rootViewController.modalPresentationStyle = .overFullScreen
		screenAPICoordinator.rootViewController.modalTransitionStyle = .coverVertical
        rootViewController.present(screenAPICoordinator.rootViewController, animated: true)
    }
    
    fileprivate func showSettings() {
		let settingsViewController = SettingsViewController(giniConfiguration: configuration.captureConfiguration())
		settingsViewController.delegate = self
		settingsViewController.modalPresentationStyle = .overFullScreen
		settingsViewController.modalTransitionStyle = .coverVertical
		rootViewController.present(settingsViewController, animated: true)
    }

    fileprivate func showOpenWithSwitchDialog(for pages: [GiniCapturePage]) {
        let title = NSLocalizedStringPreferredFormat("import.data.title", comment: "Import data")
        let description = NSLocalizedStringPreferredFormat("import.data.description",
                                                           comment: "Import data description")
        let startButtonTitle = NSLocalizedStringPreferredFormat("import.startButtonTitle",
                                                                 comment: "Yes")
        let cancelButtonTitle = NSLocalizedStringPreferredFormat("import.cancelButtonTitle",
                                                                 comment: "No")
        let alertViewController = UIAlertController(title: title, message: description, preferredStyle: .alert)

        alertViewController.addAction(UIAlertAction(title: startButtonTitle, style: .default) { [weak self] _ in
            self?.showScreenAPI(with: pages)
        })
        alertViewController.addAction(UIAlertAction(title: cancelButtonTitle, style: .default) { _ in
            alertViewController.dismiss(animated: true)
        })


        rootViewController.present(alertViewController, animated: true)
    }

    fileprivate func showExternalDocumentNotValidDialog() {
        let title = NSLocalizedStringPreferredFormat("import.data.error.title", comment: "Import error")
        let description = NSLocalizedStringPreferredFormat("import.data.error.description",
                                                           comment: "Import error description")

        let alertViewController = UIAlertController(title: title, message: description, preferredStyle: .alert)
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
}

// MARK: SelectAPIViewControllerDelegate

extension AppCoordinator: SelectAPIViewControllerDelegate {
	
	func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniPayBankApiType) {
		guard case .screen = api else { return }
		showScreenAPI()
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
    func screenAPIShouldRestart(coordinator: ScreenAPICoordinator) {
        coordinator.rootViewController.dismiss(animated: false)
        coordinator.start()
        rootViewController.present(coordinator.rootViewController, animated: false)
    }
    
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true)
        self.remove(childCoordinator: coordinator as Coordinator)
    }
}
