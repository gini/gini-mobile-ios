//
//  GalleryCoordinatorTests.swift
//  Example_Tests
//
//  Created by Nadya Karaban on 25.08.21.
//  Copyright © 2021 Gini GmbH. All rights reserved.
//

@testable import GiniCaptureSDK
import XCTest

extension UIControl {
    func simulateEvent(_ event: UIControl.Event) {
        for target in allTargets {
            let target = target as NSObjectProtocol
            for actionName in actions(forTarget: target, forControlEvent: event) ?? [] {
                let selector = Selector(actionName)
                target.perform(selector)
            }
        }
    }
}
final class GalleryCoordinatorTests: XCTestCase {
    let galleryManager = GalleryManagerMock()
    let giniConfiguration: GiniConfiguration = GiniConfiguration.shared
    let selectedImageDocuments: [GiniImageDocument] = [
        GiniImageDocument(data: Data(count: 1), imageSource: .external),
        GiniImageDocument(data: Data(count: 2), imageSource: .external),
        GiniImageDocument(data: Data(count: 3), imageSource: .external)]
    lazy var coordinator = GalleryCoordinator(galleryManager: self.galleryManager,
                                              giniConfiguration: GiniConfiguration.shared)

    var dummyImagePicker: ImagePickerViewController {
        return ImagePickerViewController(album: galleryManager.albums[0],
                                         galleryManager: galleryManager,
                                         giniConfiguration: GiniConfiguration.shared)
    }

    var dummyAlbumPicker: AlbumsPickerViewController {
        return AlbumsPickerViewController(galleryManager: galleryManager)
    }

    override func setUp() {
        super.setUp()
        giniConfiguration.multipageEnabled = true
        coordinator = GalleryCoordinator(galleryManager: galleryManager,
                                         giniConfiguration: giniConfiguration)
    }

    func testCloseGallery() {
        let delegate = GalleryCoordinatorDelegateMock()
        coordinator.delegate = delegate
        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { _ in
            self.coordinator.cancelAction()

            XCTAssertTrue(delegate.didCancelGallery,
                          "gallery image picking should be cancel after tapping cancel button")
            XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                          "selected image documents collection should be cleared after cancelling")
        }
    }

    func testOpenImages() {
        let delegate = GalleryCoordinatorDelegateMock()
        coordinator.delegate = delegate

        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { _ in

            self.selectImage(at: IndexPath(row: 1, section: 0), in: self.galleryManager.albums[2]) { _ in
                self.coordinator.openImages()
                let expect = self.expectation(for: NSPredicate(value: true),
                                              evaluatedWith: delegate.didOpenImages,
                                              handler: nil)
                self.wait(for: [expect], timeout: 10)

                XCTAssertTrue(delegate.didOpenImages,
                              "gallery images picked should be processed after tapping open images button")

                XCTAssertEqual(delegate.openedImageDocuments.count, 2,
                               "delegate opened image documents should be 2")
                XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                              "selected image documents collection should be empty after opening them")
            }
        }
    }

    func testNavigateBackToAlbumsTable() {
        coordinator.start()

        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { _ in
            _ = self.coordinator.navigationController(self.coordinator.galleryNavigator,
                                                      animationControllerFor: .pop,
                                                      from: self.dummyImagePicker,
                                                      to: self.dummyAlbumPicker)
            XCTAssertFalse(self.galleryManager.isCaching,
                           "when going back to the album picker, caching should stop")
            XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                          "selected image documents collection should be cleared after going back")
        }
    }

    func testImagePickerDelegateDidSelect() {
        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { imagePicker in
            XCTAssertEqual(imagePicker.navigationItem.rightBarButtonItem,
                           self.coordinator.openImagesButton,
                           "once that an image has been selected, the right bar button should be Open and not Cancel")
            XCTAssertFalse(self.coordinator.selectedImageDocuments.isEmpty,
                           "selected image documents should not be empty after selecting an image")
        }
    }

    func testImagePickerDelegateDidDeselect() {
        let album = galleryManager.albums[1]
        let deselectionIndex = IndexPath(row: 0, section: 0)
        selectImage(at: deselectionIndex, in: album) { imagePicker in
            self.coordinator.imagePicker(imagePicker,
                                         didDeselectAsset: album.assets[deselectionIndex.row],
                                         at: deselectionIndex)
            XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                          "selected documents array should be 0 after removing all selected items.")
            XCTAssertEqual(imagePicker.navigationItem.rightBarButtonItem,
                           self.coordinator.cancelButton,
                           "once that an image has been selected, the right bar button should be Cancel and not Open")
        }
    }

    fileprivate func selectImage(at index: IndexPath,
                                 in album: Album,
                                 handler: @escaping ((ImagePickerViewController) -> Void)) {
        coordinator.albumsPicker(coordinator.albumsController, didSelectAlbum: album)
        let imagePicker = coordinator.currentImagePickerViewController!

        coordinator.imagePicker(imagePicker,
                                didSelectAsset: album.assets[index.row],
                                at: index)

        handler(imagePicker)
    }
}
