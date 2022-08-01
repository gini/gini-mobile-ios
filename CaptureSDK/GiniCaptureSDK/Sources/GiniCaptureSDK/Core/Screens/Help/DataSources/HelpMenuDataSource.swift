//
//  HelpMenuDataSource.swift
//  
//
//  Created by Krzysztof Kryniecki on 28/07/2022.
//

import Foundation
import UIKit

protocol HelpMenuDataSourceDelegate: UIViewController {
    func didSelecthelpItem(didSelect item: HelpMenuDataSource.Item)
}

public class HelpMenuDataSource: NSObject {
    private lazy var defaultItems: [Item] = {
        var defaultItems: [Item] = [ .noResultsTips]
        
        if giniConfiguration.shouldShowSupportedFormatsScreen {
            defaultItems.append(.supportedFormats)
        }
        
        if giniConfiguration.openWithEnabled {
            defaultItems.append(.openWithTutorial)
        }
        return defaultItems
    }()
    
    weak var delegate: HelpMenuDataSourceDelegate?
    
    lazy var menuItems: [Item] = {
        var items: [Item] = []
        items.append(contentsOf: defaultItems)
        items.append(contentsOf: giniConfiguration.customMenuItems)
        return items
    }()

    private let giniConfiguration: GiniConfiguration

    init(
        configuration: GiniConfiguration
) {
        giniConfiguration = configuration
        super.init()
    }

    public enum Item {
        case noResultsTips
        case openWithTutorial
        case supportedFormats
        case custom(String, UIViewController)
        
        var title: String {
            switch self {
            case .noResultsTips:
                return .localized(resource: HelpStrings.menuFirstItemText)
            case .openWithTutorial:
                return .localized(resource: HelpStrings.menuSecondItemText)
            case .supportedFormats:
                return .localized(resource: HelpStrings.menuThirdItemText)
            case .custom(let title, _):
                return title
            }
        }
        
        var viewController: UIViewController {
            let viewController: UIViewController
            switch self {
            case .noResultsTips:
                let title: String = .localized(resource: ImageAnalysisNoResultsStrings.titleText)
                let topViewText: String = .localized(resource: ImageAnalysisNoResultsStrings.warningHelpMenuText)
                viewController = ImageAnalysisNoResultsViewController(title: title,
                                                                      subHeaderText: nil,
                                                                      topViewText: topViewText,
                                                                      topViewIcon: nil)
            case .openWithTutorial:
                viewController = OpenWithTutorialViewController()
            case .supportedFormats:
                viewController = SupportedFormatsViewController()
            case .custom(_, let customViewController):
                viewController = customViewController
            }
            return viewController
            
        }
    }
}

// MARK: - UITableViewDataSource

extension HelpMenuDataSource: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    public func configureCell(
        cell: UITableViewCell,
        indexPath: IndexPath
    ) {
        cell.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenCellsBackgroundColor)
        cell.textLabel?.text = menuItems[indexPath.row].title
        cell.textLabel?.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.accessoryType = .disclosureIndicator
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HelpMenuViewController.helpMenuCellIdentifier, for: indexPath)
        self.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HelpMenuDataSource: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.clipsToBounds = true
        if menuItems.count == 1 {
          cell.round(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], withRadius: 8)
        } else {
            if indexPath.row == 0 {
                cell.round(corners: [.topLeft, .topRight], withRadius: 8)
            }
            if indexPath.row == menuItems.count - 1 {
                cell.round(corners: [.bottomLeft, .bottomRight], withRadius: 8)
            }
        }
    }

    public func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        let item = menuItems[indexPath.row]
        self.delegate?.didSelecthelpItem(didSelect: item)
    }
}
