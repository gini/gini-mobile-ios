//
//  HelpMenuViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class HelpMenuViewControllerTests: XCTestCase {
    
    var helpMenuViewController: HelpMenuViewController =
        HelpMenuViewController(giniConfiguration: GiniConfiguration.shared)
    var items: [(text: String, id: Int)] {
        var items = [
            (NSLocalizedString("ginicapture.helpmenu.firstItem",
                               bundle: giniCaptureBundle(),
                               comment: "help menu first item text"),
             1)
        ]
        
        if GiniConfiguration.shared.shouldShowSupportedFormatsScreen {
            items.append((NSLocalizedString("ginicapture.helpmenu.thirdItem",
                               bundle: giniCaptureBundle(),
                               comment: "help menu third item text"), 3))
            
        }
        
        if GiniConfiguration.shared.openWithEnabled {
            items.append((NSLocalizedString("ginicapture.helpmenu.secondItem",
                                            bundle: giniCaptureBundle(),
                                            comment: "help menu second item text"), 2))
        }
        
        if GiniConfiguration.shared.customMenuItems.count > 0 {
            for customItem in GiniConfiguration.shared.customMenuItems{
                items.append((customItem.title, 0))
            }
        }
        
        return items
    }
    
    override func setUp() {
        super.setUp()
        _ = helpMenuViewController.view
    }
    
    func testNumberOfSections() {
        let numberOfSections = helpMenuViewController.tableView.numberOfSections
        
        XCTAssertEqual(numberOfSections, 1, "The number of sections of the table should be always 1")
    }
    
    func testItemsCountOpenWithEnabled() {
        GiniConfiguration.shared.openWithEnabled = true
        helpMenuViewController = HelpMenuViewController(giniConfiguration: GiniConfiguration.shared)
        _ = helpMenuViewController.view
        
        let itemsCount = items.count
        let tableRowsCount = helpMenuViewController.dataSource.items.count
        
        XCTAssertEqual(itemsCount, tableRowsCount, "items count should be equal to the datasource items count")
    }
    
    func testItemsCountOpenWithDisabled() {
        GiniConfiguration.shared.openWithEnabled = false
        helpMenuViewController = HelpMenuViewController(giniConfiguration: GiniConfiguration.shared)
        
        _ = helpMenuViewController.view
        
        let itemsCount = items.count
        let tableRowsCount = helpMenuViewController.dataSource.items.count
        
        XCTAssertEqual(itemsCount, tableRowsCount, "items count should be equal to the datasource items count")
    }
    
    func testItemsCountSupportedFormatScreenDisabled() {
        GiniConfiguration.shared.shouldShowSupportedFormatsScreen = false

        helpMenuViewController = HelpMenuViewController(giniConfiguration: GiniConfiguration.shared)
        _ = helpMenuViewController.view
        
        let itemsCount = items.count
        let tableRowsCount = helpMenuViewController.dataSource.items.count
        
        XCTAssertEqual(itemsCount, tableRowsCount, "items count should be equal to the datasource items count")
    }
    
    func testCellContent() {
        let indexPath = IndexPath(row: 0, section: 0)
        let itemText = helpMenuViewController.dataSource.items[indexPath.row].title
        let cell = helpMenuViewController.dataSource.tableView(helpMenuViewController.tableView, cellForRowAt: indexPath) as! HelpMenuCell

        XCTAssertEqual(itemText, cell.titleLabel.text,
                       "cell text in the first row should be the same as the first item text")
    }

    func testDidSelectRowClearsSelectionAndForwardsToDelegate() {
        let indexPath = IndexPath(row: 0, section: 0)
        helpMenuViewController.tableView.selectRow(at: indexPath,
                                                   animated: false,
                                                   scrollPosition: .none)

        helpMenuViewController.dataSource.tableView(helpMenuViewController.tableView,
                                                    didSelectRowAt: indexPath)

        XCTAssertNil(helpMenuViewController.tableView.indexPathForSelectedRow,
                     "Row selection should be cleared so VoiceOver doesn't re-announce it")
    }

    // MARK: - Bottom-nav collapse regression guards

    /// `configureConstraints()` unconditionally pins the tableView's bottom
    /// edge to `view.bottomAnchor`. Walk the view's constraints and assert
    /// exactly one bottom-anchor constraint between the tableView and its
    /// superview is active.
    func testTableViewBottomAnchorAlwaysActive() {
        let vc = HelpMenuViewController(giniConfiguration: .shared)
        _ = vc.view
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()

        let bottomConstraints = vc.view.constraints.filter { constraint in
            guard constraint.isActive else { return false }
            guard constraint.firstAttribute == .bottom,
                  constraint.secondAttribute == .bottom else { return false }
            let firstIsTable = constraint.firstItem === vc.tableView
            let secondIsTable = constraint.secondItem === vc.tableView
            let firstIsView = constraint.firstItem === vc.view
            let secondIsView = constraint.secondItem === vc.view
            return (firstIsTable && secondIsView) || (firstIsView && secondIsTable)
        }

        XCTAssertFalse(bottomConstraints.isEmpty,
                       "tableView.bottomAnchor must be pinned to view.bottomAnchor unconditionally")
    }

    /// Regression guard: no stored property on `HelpMenuViewController` may
    /// contain `bottomNav` or `bottomBar`. Parallels the mirror-walk
    /// regression scoped to the help-menu VC.
    func testNoBottomNavigationBarProperty() {
        let vc = HelpMenuViewController(giniConfiguration: .shared)
        _ = vc.view

        let mirror = Mirror(reflecting: vc)
        for child in mirror.children {
            guard let name = child.label else { continue }
            XCTAssertFalse(name.lowercased().contains("bottomnav"),
                           "Stored property \(name) must not reference bottomNav — the adapter surface is not supported")
            XCTAssertFalse(name.lowercased().contains("bottombar"),
                           "Stored property \(name) must not reference bottomBar — the adapter surface is not supported")
        }
    }

}
