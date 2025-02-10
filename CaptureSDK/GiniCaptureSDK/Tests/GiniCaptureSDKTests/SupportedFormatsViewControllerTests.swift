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
    
    var supportedFormatsViewController = HelpFormatsViewController(
        giniConfiguration: .shared
    )
    
    let initialGiniConfiguration = GiniConfiguration.shared
    
    lazy var sections: [HelpFormatsCollectionSection] = {
        var sections: [HelpFormatsCollectionSection] =  [
            (NSLocalizedString(
                "ginicapture.help.supportedFormats.section.1.title",
                bundle: giniCaptureBundleResource(),
                comment: ""),
             [
                NSLocalizedString(
                    "ginicapture.help.supportedFormats.section.1.item.1",
                    bundle: giniCaptureBundleResource(),
                    comment: "")],
             UIImageNamedPreferred(named: "supportedFormatsIcon")),
            (NSLocalizedString(
                "ginicapture.help.supportedFormats.section.2.title",
                bundle: giniCaptureBundleResource(),
                comment: ""),
             [
                NSLocalizedString(
                    "ginicapture.help.supportedFormats.section.2.item.1",
                    bundle: giniCaptureBundleResource(),
                    comment: "")],
             UIImageNamedPreferred(named: "nonSupportedFormatsIcon"))
        ]
        return sections
    }()
    
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

        let section2ItemsCount = sections[1].formats.count
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
        
        let section1items = supportedFormatsViewController.dataSource.tableView(
            supportedFormatsViewController.tableView,
            numberOfRowsInSection: 0
        )
        
        XCTAssertEqual(section1items, 2, "items count in section 1 should be 1 when file import is disabled")
    }
    
    func testFirstSectionItemsCountFileImportDisabledForImages() {
        setFileImportSupportedTypes(to: .pdf)
        supportedFormatsViewController = HelpFormatsViewController(giniConfiguration: .shared)
        
        _ = supportedFormatsViewController.view
        
        let section1items = supportedFormatsViewController.dataSource.tableView(supportedFormatsViewController.tableView,
                                                                     numberOfRowsInSection: 0)
        
        XCTAssertEqual(section1items, 3,
                       "items count in section 1 should be 2 when file import is enabled only for pdfs")
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
