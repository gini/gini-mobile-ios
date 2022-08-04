//
//  SupportedFormatsViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 10/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class SupportedFormatsViewControllerTests: XCTestCase {
    
    var supportedFormatsViewController = HelpFormatsViewController(giniConfiguration: .shared)
    let initialGiniConfiguration = GiniConfiguration.shared
    
    var sections: [HelpFormatsCollectionSection] =  [
        (.localized(resource: HelpStrings.supportedFormatsSection1Title),
         [.localized(resource: HelpStrings.supportedFormatsSection1Item1Text)],
         UIImageNamedPreferred(named: "supportedFormatsIcon"),
         GiniConfiguration.shared.supportedFormatsIconColor),
        (.localized(resource: HelpStrings.supportedFormatsSection2Title),
         [.localized(resource: HelpStrings.supportedFormatsSection2Item1Text),
          .localized(resource: HelpStrings.supportedFormatsSection2Item2Text)],
         UIImageNamedPreferred(named: "nonSupportedFormatsIcon"),
         GiniConfiguration.shared.nonSupportedFormatsIconColor)
    ]
    
    override func setUp() {
        super.setUp()
        _ = supportedFormatsViewController.view
    }
    
    func testSectionsCount() {
        let sectionsCount = sections.count
        let tableSectionsCount = supportedFormatsViewController.dataSource.numberOfSections(in: supportedFormatsViewController.tableView)

        XCTAssertEqual(sectionsCount, tableSectionsCount,
                       "sections count and table sections count should be always equal")
    }
    
    func testSectionItemsCount() {

        let section2ItemsCount = sections[1].items.count
        let tableSection2ItemsCount = supportedFormatsViewController.dataSource
            .tableView(supportedFormatsViewController.tableView,
                       numberOfRowsInSection: 1)
        
        XCTAssertEqual(section2ItemsCount,
                       tableSection2ItemsCount,
                       "items count inside section 2 and table section 2 items count should be always equal")
    }
    
    func testFirstSectionItemsCountFileImportDisabled() {
        setFileImportSupportedTypes(to: .none)
        supportedFormatsViewController = HelpFormatsViewController(giniConfiguration: .shared)
        
        _ = supportedFormatsViewController.view
        
        let section1items = supportedFormatsViewController.dataSource.tableView(supportedFormatsViewController.tableView,
                                                                     numberOfRowsInSection: 0)
        
        XCTAssertEqual(section1items, 1, "items count in section 1 should be 1 when file import is disabled")
    }
    
    func testFirstSectionItemsCountFileImportDisabledForImages() {
        setFileImportSupportedTypes(to: .pdf)
        supportedFormatsViewController = HelpFormatsViewController(giniConfiguration: .shared)
        
        _ = supportedFormatsViewController.view
        
        let section1items = supportedFormatsViewController.dataSource.tableView(supportedFormatsViewController.tableView,
                                                                     numberOfRowsInSection: 0)
        
        XCTAssertEqual(section1items, 2,
                       "items count in section 1 should be 2 when file import is enabled only for pdfs")
    }
    
    func testSecondSectionProperties() {
        let indexPath = IndexPath(row: 0, section: 1)
        let section = sections[indexPath.section]
        let sectionImage = section.itemsImage
        let sectionImageBackgroundColor = section.itemsImageBackgroundColor
        let sectionItemsCount = section.items.count
        let sectionTitle = section.title
        
        let cell = supportedFormatsViewController.dataSource.tableView(supportedFormatsViewController.tableView, cellForRowAt: indexPath)
            as? HelpFormatCell
        let headerTitle = supportedFormatsViewController.dataSource.tableView(supportedFormatsViewController.tableView, titleForHeaderInSection: indexPath.section)
        let tableViewSectionItemsCount = supportedFormatsViewController
            .tableView
            .numberOfRows(inSection: indexPath.section)
        
        XCTAssertNotNil(cell, "cell in this table view should always be of type HelpFormatCell")
        XCTAssertEqual(sectionImage, cell?.iconImageView?.image,
                       "cell image should be equal to section image since it is the same for each item in the section")
        XCTAssertEqual(sectionTitle, headerTitle,
                       "header title should be equal to section title")
        XCTAssertEqual(sectionItemsCount, tableViewSectionItemsCount,
                       "section items count and table section items count should be always equal")
    }
    
    func testSectionTitle() {
        let section1Title = sections[0].title
        let tableSection1Title = supportedFormatsViewController.dataSource.tableView(supportedFormatsViewController.tableView,
                                                                          titleForHeaderInSection: 0)
        
        XCTAssertEqual(section1Title, tableSection1Title,
                       "table view section 1 title should be equal to the one declare on initialization")
    }
    
    func testRowSelectionDisabled() {
        let selectionState = supportedFormatsViewController.tableView.allowsSelection
        
        XCTAssertFalse(selectionState, "table view cell selection should not be allowed")
    }
    
    override func tearDown() {
        super.tearDown()
        GiniConfiguration.shared = initialGiniConfiguration
    }
    
    fileprivate func setFileImportSupportedTypes(to supportedTypes: GiniConfiguration.GiniCaptureImportFileTypes) {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.fileImportSupportedTypes = supportedTypes
        GiniConfiguration.shared = giniConfiguration
    }
}
