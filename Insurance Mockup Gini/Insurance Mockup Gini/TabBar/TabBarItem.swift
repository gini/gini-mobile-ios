//
//  TabBarItem.swift
//  Gini
//
//  Inspired from quacklabs/customTabBarSwift @ GitHub
//
//  Created by David Vizaknai on 21.03.2022.
//


// Changed by Agha Saad Rehman

import UIKit

enum TabBarItem: CaseIterable {
    case home
    case invoices
    case addInvoice
    case sessions
    case medicines
    
    var icon: UIImage? {
        switch self {
        case .home:
            return UIImage(named: "icon_home")!
        case .invoices:
            return UIImage(named: "icon_invoices")!
        case .addInvoice:
            return UIImage(named: "icon_plus")!
        case .sessions:
            return UIImage(named: "icon_calendar")!
        case .medicines:
            return UIImage(named: "icon_pill")!
        }
    }
    
    var displayTitle: String {
        switch self {
        case .home:
            return "Home"
        case .invoices:
            return "Invoices"
        case .addInvoice:
            return ""
        case .sessions:
            return "Sessions"
        case .medicines:
            return "Medicines"
        }
    }
}
