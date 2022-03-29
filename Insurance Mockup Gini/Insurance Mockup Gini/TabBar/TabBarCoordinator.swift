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
    private var customTabBar: CustomTabBar!
    private var tabBarHeight: CGFloat = 107.0
    private var coordinators = [Coordinator]()

    private var newInvoiceFlowCoordinator: ComponentAPICoordinator?

    private lazy var giniConfiguration: GiniConfiguration = {
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
    private lazy var apiLib = GiniHealthAPI.Builder(client: client).build()
    private lazy var health = GiniHealth(with: apiLib)

    private var documentMetadata: Document.Metadata?
    private let documentMetadataBranchId = "GiniHealthExampleIOS"
    private let documentMetadataAppFlowKey = "AppFlow"

    private var dataModel: InvoiceListDataModel


    init() {
        self.dataModel = InvoiceListDataModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
                let coordinator = InvoiceFlowCoordinator(dataModel: dataModel)
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
        customTabBar.itemTapped = { [weak self] tab in
            self?.changeTab(tab: tab)
        }

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
    
    private func changeTab(tab: Int) {
        if tab == 2 {
            showScanningFlow()
            return
        }
        self.selectedIndex = tab
    }

    private func showScanningFlow() {
        checkIfAnyBankingAppsInstalled() { [weak self] in
            guard let self = self else { return }
            let componentAPICoordinator = ComponentAPICoordinator(pages: [],
                                                                  configuration: self.giniConfiguration,
                                                                  documentService: self.componentAPIDocumentService(),
                                                                  giniHealth: self.health)
            componentAPICoordinator.delegate = self
            self.newInvoiceFlowCoordinator = componentAPICoordinator
            componentAPICoordinator.start()

            self.present(componentAPICoordinator.rootViewController, animated: true, completion: nil)
        }
    }

    private func componentAPIDocumentService() -> ComponentAPIDocumentServiceProtocol {
        documentMetadata = Document.Metadata(branchId: documentMetadataBranchId,
                                             additionalHeaders: [documentMetadataAppFlowKey: "ComponentAPI"])
        return ComponentAPIDocumentsService(lib: apiLib, documentMetadata: documentMetadata)
    }

    private func checkIfAnyBankingAppsInstalled(completion: @escaping () -> Void) {
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

    func showInvoiceDetail() {
        newInvoiceFlowCoordinator?.abortCoordinator()
        self.selectedIndex = 1
        (coordinators.first(where: { $0 is InvoiceFlowCoordinator }) as? InvoiceFlowCoordinator)?.showInvoiceDetail(with: "123445")
    }
}

// MARK: ComponentAPICoordinatorDelegate

extension TabBarCoordinator: ComponentAPICoordinatorDelegate {
    func componentAPIDidSelectSave(invoice: Invoice) {
        dataModel.addNewInvoice(invoice: invoice)
    }

    func componentAPI(coordinator: ComponentAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.newInvoiceFlowCoordinator = nil
    }
}
