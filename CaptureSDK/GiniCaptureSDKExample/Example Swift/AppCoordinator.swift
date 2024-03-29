//
//  AppCoordinator.swift
//  GiniCapture_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import GiniBankAPILibrary
import GiniCaptureSDK
import UIKit

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
        let giniConfiguration = GiniConfiguration.shared
        giniConfiguration.debugModeOn = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.openWithEnabled = true
        giniConfiguration.qrCodeScanningEnabled = true
        giniConfiguration.multipageEnabled = true
        giniConfiguration.flashToggleEnabled = true
//        giniConfiguration.bottomNavigationBarEnabled = true
        giniConfiguration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 5 * 1024 * 1024
            if document.data.count > maxFileSize {
                let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als 5MB")
                return CustomDocumentValidationResult.failure(withError: error)
            }
            return CustomDocumentValidationResult.success()
        }
        let customMenuItem = HelpMenuItem.custom("Custom menu item", CustomMenuItemViewController())
        giniConfiguration.customMenuItems = [customMenuItem]
        
        // If you need to scale your font please use our method `scaledFont()`. Please, find the example below.
//        let customFontToBeScaled = UIFont.scaledFont(UIFont(name: "Avenir", size: 20) ?? UIFont.systemFont(ofSize: 7, weight: .regular), textStyle: .caption1)
//        giniConfiguration.updateFont(customFontToBeScaled, for: .caption1)
        
        // If you would like to pass us already scaled font.
//        let customScaledFont = UIFontMetrics(forTextStyle: .caption2).scaledFont(for: UIFont.systemFont(ofSize: 28))
//        giniConfiguration.updateFont(customScaledFont, for: .caption2)
        // Custom navigation view controller
//        let navigationViewController = UINavigationController()
//        navigationViewController.navigationBar.backgroundColor = GiniColor(light: .purple, dark: .lightGray).uiColor()
//        giniConfiguration.customNavigationController = navigationViewController

//        giniConfiguration.noResultNavigationBarBottomAdapter = CustomBottomNavigationBarAdapter()
//        giniConfiguration.helpNavigationBarBottomAdapter = CustomBottomNavigationBarAdapter()
//        giniConfiguration.imagePickerNavigationBarBottomAdapter = CustomBottomNavigationBarAdapter()
//        giniConfiguration.reviewNavigationBarBottomAdapter = CustomReviewScreenBottomNavigationBarAdapter()
//        giniConfiguration.onboardingNavigationBarBottomAdapter = CustomOnboardingBottomNavigationBarAdapter()
//        giniConfiguration.cameraNavigationBarBottomAdapter = CustomCameraBottomNavigationBarAdapter()

        return giniConfiguration
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
        showSelectAPIScreen()
    }

    func processExternalDocument(withUrl url: URL, sourceApplication: String?) {
        // 1. Build the document
        let documentBuilder = GiniCaptureDocumentBuilder(documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith

        documentBuilder.build(with: url) { [weak self] document in

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
            } else {
                self.showExternalDocumentNotValidDialog()
            }
        }
    }

    fileprivate func showSelectAPIScreen() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    fileprivate func showScreenAPI(with pages: [GiniCapturePage]? = nil) {
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                             additionalHeaders: [documentMetadataAppFlowKey: "ScreenAPI"])
        let screenAPICoordinator = ScreenAPICoordinator(configuration: giniConfiguration,
                                                        importedDocuments: pages?.map { $0.document },
                                                        client: client,
                                                        documentMetadata: documentMetadata)
        screenAPICoordinator.delegate = self
        screenAPICoordinator.start()
        add(childCoordinator: screenAPICoordinator)

        rootViewController.present(screenAPICoordinator.rootViewController, animated: true, completion: nil)
    }

    fileprivate func showSettings() {
        let settingsViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "settingsViewController") as? SettingsViewController)!
        settingsViewController.delegate = self
        settingsViewController.giniConfiguration = giniConfiguration
        settingsViewController.modalPresentationStyle = .overFullScreen
        settingsViewController.modalTransitionStyle = .crossDissolve

        rootViewController.present(settingsViewController, animated: true, completion: nil)
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
            alertViewController.dismiss(animated: true, completion: nil)
        })

        rootViewController.present(alertViewController, animated: true, completion: nil)
    }

    fileprivate func showExternalDocumentNotValidDialog() {
        let title = NSLocalizedStringPreferredFormat("import.data.error.title", comment: "Import error")
        let description = NSLocalizedStringPreferredFormat("import.data.error.description",
                                                           comment: "Import error description")

        let alertViewController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })

        rootViewController.present(alertViewController, animated: true, completion: nil)
    }

    fileprivate func popToRootViewControllerIfNeeded() {
        childCoordinators.forEach { coordinator in
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
            showScreenAPI()
        }
    }

    func selectAPI(viewController: SelectAPIViewController, didTapSettings: ()) {
        showSettings()
    }
}

extension AppCoordinator: SettingsViewControllerDelegate {
    func settings(settingViewController: SettingsViewController,
                  didChangeConfiguration configuration: GiniConfiguration) {
        giniConfiguration = configuration
    }
}

// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        remove(childCoordinator: coordinator)
    }
}
