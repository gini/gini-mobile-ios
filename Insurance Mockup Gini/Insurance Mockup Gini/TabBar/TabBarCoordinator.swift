//
//  TabBarCoordinator.swift
//  Gini
//
//  Inspired from quacklabs/customTabBarSwift @ GitHub
//
//  Created by David Vizaknai on 21.03.2022.
//

import UIKit
import GiniCaptureSDK
import GiniHealthSDK
import GiniHealthAPILibrary

class TabBarCoordinator: UITabBarController {
    var customTabBar: CustomTabBar!
    var tabBarHeight: CGFloat = 107.0
    var coordinators = [Coordinator]()

    var newInvoiceFlowCoordinator: ComponentAPICoordinator?

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
        checkIfAnyBankingAppsInstalled() {
            let componentAPICoordinator = ComponentAPICoordinator(pages: [],
                                                                  configuration: self.giniConfiguration,
                                                                  documentService: self.componentAPIDocumentService(),
                                                                  giniHealth: self.health)
            componentAPICoordinator.delegate = self
            componentAPICoordinator.start()
            self.newInvoiceFlowCoordinator = componentAPICoordinator

            self.present(componentAPICoordinator.rootViewController, animated: true, completion: nil)
        }
    }

    fileprivate func componentAPIDocumentService() -> ComponentAPIDocumentServiceProtocol {
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                             additionalHeaders: [documentMetadataAppFlowKey: "ComponentAPI"])
        return ComponentAPIDocumentsService(lib: apiLib, documentMetadata: documentMetadata)
    }

    fileprivate func checkIfAnyBankingAppsInstalled(completion: @escaping () -> Void) {
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
                self.present(alertViewController, animated: true, completion: nil)
            }
        }
    }
}


//extension TabBarCoordinator: ScreenAPICoordinatorDelegate {
//    func screenAPIDidFinish(coordinator: ScreenAPICoordinator, shouldSwitchToInvoiceTab: Bool) {
//        coordinator.rootViewController.dismiss(animated: true, completion: nil)
//        newInvoiceFlowCoordinator = nil
//
//        if shouldSwitchToInvoiceTab {
//            self.selectedIndex = 1
//
////            let invoice = InvoiceItemCellViewModel(iconName: "icon_dentist", title: "New invoice", paid: true, reimbursed: .reimbursed, price: "2345 EUR")
////            (coordinators[1] as? InvoiceFlowCoordinator)?.addNewInvoice(invoice: invoice)
//        }
//    }
//}

// MARK: ComponentAPICoordinatorDelegate

extension TabBarCoordinator: ComponentAPICoordinatorDelegate {
    func componentAPI(coordinator: ComponentAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.newInvoiceFlowCoordinator = nil
    }
}
