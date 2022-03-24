//
//  TabBarCoordinator.swift
//  Gini
//
//  Inspired from quacklabs/customTabBarSwift @ GitHub
//
//  Created by David Vizaknai on 21.03.2022.
//

import GiniBankAPILibrary
import GiniCaptureSDK
import UIKit

class TabBarCoordinator: UITabBarController {
    var customTabBar: CustomTabBar!
    var tabBarHeight: CGFloat = 107.0
    var coordinators = [Coordinator]()

    var newInvoiceFlowCoordinator: Coordinator?

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
        giniConfiguration.navigationBarItemTintColor = .white
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
    }
    
    private func loadTabBar() {
        let tabItems: [TabBarItem] = [.home, .invoices, .addInvoice, .sessions, .medicines]
        self.setupCustomTabBar(tabItems)

        var coordinators = [Coordinator]()

        tabItems.forEach { item in
            switch item {
            case .home:
                let coordinator = HomeScreenCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
            case .invoices:
                let coordinator = InvoiceFlowCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
            case .addInvoice:
                let coordinator = NewInvoiceFlowCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
            case .sessions:
                let coordinator = SessionsCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
            case .medicines:
                let coordinator = MedicineFlowCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
            }
        }

        self.coordinators = coordinators
        self.viewControllers = coordinators.map({  $0.rootViewController })
        self.selectedIndex = 0 // default our selected index to the first item
    }
    
    // Build the custom tab bar and hide default
    private func setupCustomTabBar(_ items: [TabBarItem]) {
        let frame = CGRect(x: tabBar.frame.origin.x, y: tabBar.frame.origin.x, width: tabBar.frame.width, height: tabBarHeight)

        // hide the tab bar
        tabBar.isHidden = true
        
        customTabBar = CustomTabBar(menuItems: items, frame: frame)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        customTabBar.itemTapped = changeTab

        view.addSubview(customTabBar)

        // Add positioning constraints to place the nav menu right where the tab bar should be
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            customTabBar.widthAnchor.constraint(equalToConstant: tabBar.frame.width),
            customTabBar.heightAnchor.constraint(equalToConstant: tabBarHeight),
            customTabBar.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor)
        ])
        
        view.layoutIfNeeded()
    }
    
    func changeTab(tab: Int) {
        if tab == 2 {
            showScanningFlow()
            return
        }
        self.selectedIndex = tab
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

        newInvoiceFlowCoordinator = coordinator
        present(coordinator.rootViewController, animated: true, completion: nil)
    }
}


extension TabBarCoordinator: ScreenAPICoordinatorDelegate {
    func screenAPIDidFinish(coordinator: ScreenAPICoordinator, shouldSwitchToInvoiceTab: Bool) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        newInvoiceFlowCoordinator = nil

        if shouldSwitchToInvoiceTab {
            self.selectedIndex = 1
        }
    }
}
