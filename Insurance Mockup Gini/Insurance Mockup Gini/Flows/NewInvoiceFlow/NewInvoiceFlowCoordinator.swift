//
//  NewInvoiceFlowCoordinator.swift
//  Insurance Mockup Gini
//
//  Created by David Vizaknai on 22.03.2022.
//

import UIKit
import GiniCaptureSDK
import GiniBankAPILibrary

final class NewInvoiceFlowCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return navigationController
    }

    private lazy var client = CredentialsManager.fetchClientFromBundle()
    private var documentMetadata: Document.Metadata?
    private let documentMetadataBranchId = "GVLExampleIOS"
    private let documentMetadataAppFlowKey = "AppFlow"

    lazy var giniConfiguration: GiniConfiguration = {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.openWithEnabled = true
        giniConfiguration.qrCodeScanningEnabled = true
        giniConfiguration.multipageEnabled = true
        giniConfiguration.flashToggleEnabled = true
        giniConfiguration.navigationBarItemTintColor = .red
        giniConfiguration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 5 * 1024 * 1024
            if document.data.count > maxFileSize {
                let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als 5MB")
                return CustomDocumentValidationResult.failure(withError: error)
            }
            return CustomDocumentValidationResult.success()
        }
        let customMenuItem = HelpMenuViewController.Item.custom("Custom menu item", CustomMenuItemViewController())
        giniConfiguration.customMenuItems = [customMenuItem]
        return giniConfiguration
    }()

    var navigationController: UINavigationController!

    func start() {
        let viewController = NewInvoiceFlowViewController()
        viewController.delegate = self
        navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.isHidden = true
    }

    func showScanningFlow() {
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                                     additionalHeaders: [documentMetadataAppFlowKey: "ScreenAPI"])

        let coordinator = ScreenAPICoordinator(configuration: giniConfiguration,
                                               importedDocuments: nil,
                                               client: client,
                                               documentMetadata: documentMetadata)
        coordinator.delegate = self
        coordinator.start()

        add(childCoordinator: coordinator)
        rootViewController.present(coordinator.rootViewController, animated: true, completion: nil)
    }
}

extension NewInvoiceFlowCoordinator: ScreenAPICoordinatorDelegate {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: (), withResults results: [Extraction]?) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        remove(childCoordinator: coordinator)

        // TODO: Continue from here
    }
}

extension NewInvoiceFlowCoordinator: NewInvoiceFlowViewControllerDelegate{
    func didSelectNewInvoice() {
        showScanningFlow()
    }
}
