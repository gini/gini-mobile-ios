//
//  AlbumsPickerViewController.swift
//  Example_Tests
//
//  Created by Nadya Karaban on 25.08.21.
//  Copyright © 2021 Gini GmbH. All rights reserved.
//

@testable import GiniCaptureSDK
import XCTest

class AlbumsPickerViewControllerTests: XCTestCase {
    let galleryManager = GalleryManagerMock()
    lazy var albumsViewController = AlbumsPickerViewController(galleryManager: self.galleryManager)

    override func setUp() {
        super.setUp()
        _ = albumsViewController.view
    }

    func testViewControllerTitle() {
        let title = NSLocalizedStringPreferredFormat("ginicapture.albums.title",
                                                     comment: "title for the albums picker view controller")
        XCTAssertEqual(title, albumsViewController.title, "title should match the one provided in the Localizable file")
    }

    func testNumberOfSections() {
        XCTAssertEqual(albumsViewController.albumsTableView.numberOfSections, 1, "there should be only one section")
    }

    func testNumberOfItems() {
        XCTAssertEqual(albumsViewController.albumsTableView.numberOfRows(inSection: 0), 3, "there should be 3 albums")
    }

    func testCollectionCellType() {
        XCTAssertNotNil(albumsViewController.tableView(albumsViewController.albumsTableView,
                                     cellForRowAt: IndexPath(row: 0, section: 0)) as? AlbumsPickerTableViewCell,
                        "cell type should match UITableViewCell")
    }

    func testTableCellSelection() {
        let delegate = AlbumsPickerViewControllerDelegateMock()
        albumsViewController.delegate = delegate

        let selectedIndex = IndexPath(row: 0, section: 0)
        let selectedAlbum = galleryManager.albums[selectedIndex.row]
        albumsViewController.tableView(albumsViewController.albumsTableView, didSelectRowAt: selectedIndex)
        XCTAssertEqual(selectedAlbum, delegate.selectedAlbum,
                       "selected album should match the one delivered to the delegate")
    }

    func testFirstCellContent() {
        let firstIndex = IndexPath(row: 0, section: 0)
        let firstCell = albumsViewController.tableView(albumsViewController.albumsTableView,
                                                       cellForRowAt: firstIndex) as? AlbumsPickerTableViewCell

        XCTAssertEqual(firstCell?.albumTitleLabel.text, galleryManager.albums[firstIndex.row].title,
                       "album title label text should match the album title for the first cell")
        XCTAssertEqual(firstCell?.albumSubTitleLabel.text, "\(galleryManager.albums[firstIndex.row].count)",
                       "album subtitle label text should match the album assets count for the first cell")
    }

    func testSecondCellContent() {
        let secondIndex = IndexPath(row: 1, section: 0)
        let secondCell = albumsViewController.tableView(albumsViewController.albumsTableView,
                                                        cellForRowAt: secondIndex) as? AlbumsPickerTableViewCell

        XCTAssertEqual(secondCell?.albumTitleLabel.text, galleryManager.albums[secondIndex.row].title,
                       "album title label text should match the album title for the second cell")
        XCTAssertEqual(secondCell?.albumSubTitleLabel.text, "\(galleryManager.albums[secondIndex.row].count)",
                       "album subtitle label text should match the album assets count for the second cell")
    }
}
