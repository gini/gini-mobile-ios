//
//  ImagePickerViewControllerTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK
final class ImagePickerViewControllerTests: XCTestCase {
    
    let galleryManager = GalleryManagerMock()
    lazy var currentAlbum = self.galleryManager.albums[1]
    
    lazy var vc = ImagePickerViewController(album: self.currentAlbum,
                                            galleryManager: GalleryManagerMock(),
                                            giniConfiguration: GiniConfiguration.shared)
    
    override func setUp() {
        super.setUp()
        _ = vc.view
    }
    
    func testViewControllerTitle() {
        let title = currentAlbum.title
        XCTAssertEqual(title, vc.title, "view controller title should match the album title")
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(vc.collectionView.numberOfSections, 1, "there should be only one section")
    }
    
    func testNumberOfItems() {
        XCTAssertEqual(vc.collectionView.numberOfItems(inSection: 0), 2,
                       "there should be only 2 images in the first album")
    }
    
    func testCollectionCellType() {
        XCTAssertNotNil(vc.collectionView(vc.collectionView,
                                          cellForItemAt: IndexPath(row: 0,
                                                                   section: 0)) as? ImagePickerCollectionViewCell,
                        "cell type should match GiniImagePickerCollectionViewCell")
    }

    func testCollectionCellSelection() {
        let delegate = ImagePickerViewControllerDelegateMock()
        vc.delegate = delegate
        let selectedCellIndex = IndexPath(row: 0, section: 0)
        let selectedCellIndex2 = IndexPath(row: 1, section: 0)

        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex)
        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex2)
        
        XCTAssertEqual(delegate.selectedAssets.count, 2,
                       "the selected indexes count should match thet ones delivered to the delegate")
    }
    
    func testCollectionCellDeselection() {
        let delegate = ImagePickerViewControllerDelegateMock()
        vc.delegate = delegate
        let selectedCellIndex = IndexPath(row: 0, section: 0)
        let selectedCellIndex2 = IndexPath(row: 1, section: 0)
        
        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex)
        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex2)
        vc.collectionView(vc.collectionView, didSelectItemAt: selectedCellIndex2)
        
        XCTAssertEqual(delegate.selectedAssets.count, 1,
                       "the selected indexes count should match thet ones delivered to the delegate")
    }
}
