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
    
    var supportedFormatsViewController = SupportedFormatsViewController()
    let initialGiniConfiguration = GiniConfiguration.shared
    
    var sections: [SupportedFormatCollectionSection] = [
        (.localized(resource: HelpStrings.supportedFormatsSection1Title),
         [.localized(resource: HelpStrings.supportedFormatsSection1Item1Text),
          .localized(resource: HelpStrings.supportedFormatsSection1Item2Text),
          .localized(resource: HelpStrings.supportedFormatsSection1Item3Text)],
         UIImage(named: "supportedFormatsIcon",
                 in: giniCaptureBundle(),
                 compatibleWith: nil),
         GiniConfiguration.shared.supportedFormatsIconColor),
        (.localized(resource: HelpStrings.supportedFormatsSection2Title),
         [.localized(resource: HelpStrings.supportedFormatsSection2Item1Text),
          .localized(resource: HelpStrings.supportedFormatsSection2Item2Text)],
         UIImage(named: "nonSupportedFormatsIcon",
                 in: giniCaptureBundle(),
                 compatibleWith: nil),
         GiniConfiguration.shared.nonSupportedFormatsIconColor)
    ]
    
    override func setUp() {
        super.setUp()
        _ = supportedFormatsViewController.view
    }
    
    func testSectionsCount() {
        let sectionsCount = sections.count
        let tableSectionsCount = supportedFormatsViewController
            .numberOfSections(in: supportedFormatsViewController.tableView)

        XCTAssertEqual(sectionsCount, tableSectionsCount,
                       "sections count and table sections count should be always equal")
    }
    
    func testSectionItemsCount() {

        let section2ItemsCount = sections[1].items.count
        let tableSection2ItemsCount = supportedFormatsViewController
            .tableView(supportedFormatsViewController.tableView,
                       numberOfRowsInSection: 1)
        
        XCTAssertEqual(section2ItemsCount,
                       tableSection2ItemsCount,
                       "items count inside section 2 and table section 2 items count should be always equal")
    }
    
    func testFirstSectionProperties() {
        setFileImportSupportedTypes(to: .pdf_and_images)
        supportedFormatsViewController = SupportedFormatsViewController()

        let indexPath = IndexPath(row: 0, section: 0)
        let section = sections[indexPath.section]
        let sectionImage = section.itemsImage
        let sectionImageBackgroundColor = section.itemsImageBackgroundColor
        let sectionItemsCount = section.items.count
        let sectionTitle = section.title
        
        let cell = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, cellForRowAt: indexPath)
            as? SupportedFormatsTableViewCell
        let headerTitle = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, titleForHeaderInSection: indexPath.section)
        let tableViewSectionItemsCount = supportedFormatsViewController
            .tableView
            .numberOfRows(inSection: indexPath.section)
        
        XCTAssertNotNil(cell, "cell in this table view should always be of type SupportedFormatsTableViewCell")
        XCTAssertEqual(sectionImage, cell?.imageView?.image,
                       "cell image should be equal to section image since it is the same for each item in the section")
        XCTAssertEqual(sectionImageBackgroundColor, cell?.imageBackgroundView.backgroundColor,
                       "cell image background color should be equal to section image background " +
                       "colorsince it is the same for each item in the section")
        XCTAssertEqual(sectionImage, cell?.imageView?.image,
                       "cell image should be equal to section image since it is the same for each item in the section")
        XCTAssertEqual(sectionTitle, headerTitle, "header title should be equal to section title")
        XCTAssertEqual(sectionItemsCount, tableViewSectionItemsCount,
                       "section items count and table section items count should be always equal")
    }
    
    func testFirstSectionItemsCountFileImportDisabled() {
        setFileImportSupportedTypes(to: .none)
        supportedFormatsViewController = SupportedFormatsViewController()
        
        _ = supportedFormatsViewController.view
        
        let section1items = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
                                                                     numberOfRowsInSection: 0)
        
        XCTAssertEqual(section1items, 1, "items count in section 1 should be 1 when file import is disabled")
    }
    
    func testFirstSectionItemsCountFileImportDisabledForImages() {
        setFileImportSupportedTypes(to: .pdf)
        supportedFormatsViewController = SupportedFormatsViewController()
        
        _ = supportedFormatsViewController.view
        
        let section1items = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
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
        
        let cell = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, cellForRowAt: indexPath)
            as? SupportedFormatsTableViewCell
        let headerTitle = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, titleForHeaderInSection: indexPath.section)
        let tableViewSectionItemsCount = supportedFormatsViewController
            .tableView
            .numberOfRows(inSection: indexPath.section)
        
        XCTAssertNotNil(cell, "cell in this table view should always be of type SupportedFormatsTableViewCell")
        XCTAssertEqual(sectionImage, cell?.imageView?.image,
                       "cell image should be equal to section image since it is the same for each item in the section")
        XCTAssertEqual(sectionImageBackgroundColor, cell?.imageBackgroundView.backgroundColor,
                       "cell image background color should be equal to section image background " +
                       "colorsince it is the same for each item in the section")
        XCTAssertEqual(sectionImage, cell?.imageView?.image,
                       "cell image should be equal to section image since it is the same for each item in the section")
        XCTAssertEqual(sectionTitle, headerTitle,
                       "header title should be equal to section title")
        XCTAssertEqual(sectionItemsCount, tableViewSectionItemsCount,
                       "section items count and table section items count should be always equal")
    }
    
    func testFirstSupportedFormatCellText() {
        setFileImportSupportedTypes(to: .pdf_and_images)
        supportedFormatsViewController = SupportedFormatsViewController()

        let indexPath = IndexPath(row: 0, section: 0)
        let textForItem0tSection0 = sections[indexPath.section].items[indexPath.row]
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
                                                                              cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0tSection0,
                       "text for item 0 at section 0 should be equal to the one declared on initialization")
    }
    
    func testSecondSupportedFormatCellText() {
        setFileImportSupportedTypes(to: .pdf_and_images)
        supportedFormatsViewController = SupportedFormatsViewController()

        let indexPath = IndexPath(row: 1, section: 0)
        let textForItem0tSection0 = sections[indexPath.section].items[indexPath.row]
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
                                                                              cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0tSection0,
                       "text for item 1 at section 0 should be equal to the one declared on initialization")
    }
    
    func testThirdSupportedFormatCellText() {
        setFileImportSupportedTypes(to: .pdf_and_images)
        supportedFormatsViewController = SupportedFormatsViewController()

        let indexPath = IndexPath(row: 2, section: 0)
        let textForItem0tSection0 = sections[indexPath.section].items[indexPath.row]
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
                                                                              cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0tSection0,
                       "text for item 2 at section 0 should be equal to the one declared on initialization")
    }
    
    func testFirstUnSupportedFormatCellText() {
        let indexPath = IndexPath(row: 0, section: 1)
        let textForItem0tSection0 = sections[indexPath.section].items[indexPath.row]
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
                                                                              cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0tSection0,
                       "text for item 0 at section 1 should be equal to the one declared on initialization")
    }
    
    func testSecondUnSupportedFormatCellText() {
        let indexPath = IndexPath(row: 1, section: 1)
        let textForItem0tSection0 = sections[indexPath.section].items[indexPath.row]
        let textForCellAtIndexPath = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
                                                                              cellForRowAt: indexPath).textLabel?.text
        
        XCTAssertEqual(textForCellAtIndexPath, textForItem0tSection0,
                       "text for item 1 at section 1 should be equal to the one declared on initialization")
    }
    
    func testSectionHeaderHeight() {
        let sectionHeaderHeight = supportedFormatsViewController.sectionHeight
        
        let tableSectionHeaderHeight = supportedFormatsViewController.tableView.sectionHeaderHeight
        
        XCTAssertEqual(sectionHeaderHeight, tableSectionHeaderHeight,
                       "table view section header height should be equal to the one declare on initialization")
    }
    
    func testRowHeight() {
        let rowHeight = supportedFormatsViewController.rowHeight
        
        let tableRowHeight = supportedFormatsViewController.tableView.rowHeight
        
        XCTAssertEqual(rowHeight, tableRowHeight,
                       "table view row height should be equal to the one declare on initialization")
    }
    
    func testSectionTitle() {
        let section1Title = sections[0].title
        let tableSection1Title = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView,
                                                                          titleForHeaderInSection: 0)
        
        XCTAssertEqual(section1Title, tableSection1Title,
                       "table view section 1 title should be equal to the one declare on initialization")
    }
    
    func testRowSelectionDisabled() {
        let selectionState = supportedFormatsViewController.tableView.allowsSelection
        
        XCTAssertFalse(selectionState, "table view cell selection should not be allowed")
    }
    
    func testSectionImageItemBackgroundColor() {
        let indexPath = IndexPath(row: 0, section: 0)

        let sectionImageItemBackgroundColor = supportedFormatsViewController
            .sections[indexPath.section].itemsImageBackgroundColor
        
        let cell = supportedFormatsViewController.tableView(supportedFormatsViewController.tableView, cellForRowAt: indexPath)
            as? SupportedFormatsTableViewCell
        let cellImageBackgroundColor = cell!.imageBackgroundView.backgroundColor
        
        XCTAssertEqual(sectionImageItemBackgroundColor, cellImageBackgroundColor,
                       "cell image background color should be the same as the one declared on initialization")
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
