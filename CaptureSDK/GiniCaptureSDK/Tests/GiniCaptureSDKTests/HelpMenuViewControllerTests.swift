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
        let tableRowsCount = helpMenuViewController.menuItems.count
        
        XCTAssertEqual(itemsCount, tableRowsCount, "items count should be equal to the datasource items count")
    }
    
    func testItemsCountOpenWithDisabled() {
        GiniConfiguration.shared.openWithEnabled = false
        helpMenuViewController = HelpMenuViewController(giniConfiguration: GiniConfiguration.shared)
        
        _ = helpMenuViewController.view
        
        let itemsCount = items.count
        let tableRowsCount = helpMenuViewController.menuItems.count
        
        XCTAssertEqual(itemsCount, tableRowsCount, "items count should be equal to the datasource items count")
    }
    
    func testItemsCountSupportedFormatScreenDisabled() {
        GiniConfiguration.shared.shouldShowSupportedFormatsScreen = false

        helpMenuViewController = HelpMenuViewController(giniConfiguration: GiniConfiguration.shared)
        _ = helpMenuViewController.view
        
        let itemsCount = items.count
        let tableRowsCount = helpMenuViewController.menuItems.count
        
        XCTAssertEqual(itemsCount, tableRowsCount, "items count should be equal to the datasource items count")
    }
    
    func testCellContent() {
        let indexPath = IndexPath(row: 0, section: 0)
        let itemText = helpMenuViewController.menuItems[indexPath.row].title
        let cellAccesoryType = UITableViewCell.AccessoryType.disclosureIndicator
        
        let cell = helpMenuViewController.tableView(helpMenuViewController.tableView, cellForRowAt: indexPath)
        
        XCTAssertEqual(itemText, cell.textLabel?.text,
                       "cell text in the first row should be the same as the first item text")
        
        XCTAssertEqual(cellAccesoryType,
                       cell.accessoryType,
                       "cell accesory type should be and a disclosure indicator")
    }
    
    func testTableRowheight() {
        let tableRowHeight = helpMenuViewController.tableView.rowHeight
        
        XCTAssertEqual(tableRowHeight, helpMenuViewController.tableRowHeight, "table row height should match")
    }
    
}
