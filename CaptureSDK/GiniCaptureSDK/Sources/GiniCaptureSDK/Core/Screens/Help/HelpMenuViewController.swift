//
//  HelpMenuViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `HelpMenuViewControllerDelegate` protocol defines methods that allow you to handle table item selection actions.
 
 - note: Component API only.
 */

public protocol HelpMenuViewControllerDelegate: AnyObject {
    func help(_ menuViewController: HelpMenuViewController, didSelect item: HelpMenuViewController.Item)
}

/**
 The `HelpMenuViewController` provides explanations on how to take better pictures, how to
 use the _Open with_ feature and which formats are supported by the Gini Capture SDK. 
 */

final public class HelpMenuViewController: UITableViewController {
    
    public weak var delegate: HelpMenuViewControllerDelegate?
    let giniConfiguration: GiniConfiguration
    let tableRowHeight: CGFloat = 64
    var helpMenuCellIdentifier = "helpMenuCellIdentifier"
    
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
    lazy var menuItems: [Item] = []

    lazy var defaultItems: [Item] = {
        var defaultItems: [Item] = [ .noResultsTips]
        
        if giniConfiguration.shouldShowSupportedFormatsScreen {
            defaultItems.append(.supportedFormats)
        }
        
        if giniConfiguration.openWithEnabled {
            defaultItems.append(.openWithTutorial)
        }
        
        return defaultItems
    }()
    
    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }
    
    func configureMenuItems() {
        menuItems.append(contentsOf: defaultItems)
        menuItems.append(contentsOf: giniConfiguration.customMenuItems)
    }
    
    fileprivate func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: helpMenuCellIdentifier)
        tableView.rowHeight = tableRowHeight
        
        tableView.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenBackgroundColor)
        
        // In iOS it is .automatic by default, having an initial animation when the view is loaded.
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    fileprivate func configureMainView() {
        title = .localized(resource: HelpStrings.menuTitle)
    }
    
    fileprivate func configureLayout() {
        configureMainView()
        configureTableView()
        configureMenuItems()
        edgesForExtendedLayout = []
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UITableViewDataSource

extension HelpMenuViewController {
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: helpMenuCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.from(giniColor: giniConfiguration.helpScreenCellsBackgroundColor)
        cell.textLabel?.text = menuItems[indexPath.row].title
        cell.textLabel?.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuItems[indexPath.row]
        
        guard delegate == nil else {
            delegate?.help(self, didSelect: item)
            return
        }
    }
    
}
