//
//  TabBarCoordinator.swift
//  Gini
//
//  Inspired from quacklabs/customTabBarSwift @ GitHub
//
//  Created by David Vizaknai on 21.03.2022.
//


import UIKit

class TabBarCoordinator: UITabBarController {
    var customTabBar: CustomTabBar!
    var tabBarHeight: CGFloat = 107.0
    var coordinators = [Coordinator]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBar()
    }
    
    private func loadTabBar() {
        let tabItems: [TabBarItem] = [.home, .invoices, .addInvoice, .sessions, .medicines]
        self.setupCustomTabBar(tabItems)

        var tabBarViewControllers = [UIViewController]()
        var coordinators = [Coordinator]()

        tabItems.forEach { item in
            switch item {
            case .home:
                let coordinator = HomeScreenCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
                tabBarViewControllers.append(coordinator.rootViewController)
            case .invoices:
                let coordinator = InvoiceFlowCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
                tabBarViewControllers.append(coordinator.rootViewController)
            case .addInvoice:
                let coordinator = NewInvoiceFlowCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
                tabBarViewControllers.append(coordinator.rootViewController)
            case .sessions:
                let coordinator = SessionsCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
                tabBarViewControllers.append(coordinator.rootViewController)
            case .medicines:
                let coordinator = MedicineFlowCoordinator()
                coordinator.start()
                coordinators.append(coordinator)
                tabBarViewControllers.append(coordinator.rootViewController)
            }
        }

        self.coordinators = coordinators
        self.viewControllers = tabBarViewControllers
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
        self.selectedIndex = tab
    }
}
