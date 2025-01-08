//
//  GalleryCoordinatorDelegateTests.swift
//  Example_Tests
//
//  Created by Nadya Karaban on 25.08.21.
//  Copyright © 2021 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniCaptureSDK

final class GalleryCoordinatorDelegateMock: GalleryCoordinatorDelegate {
    var didCancelGallery = false
    var didOpenImages = false
    var openedImageDocuments: [GiniImageDocument] = []

    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void) {
        didCancelGallery = true
    }

    func gallery(_ coordinator: GalleryCoordinator, didSelectImageDocuments imageDocuments: [GiniImageDocument]) {
        didOpenImages = true
        openedImageDocuments = imageDocuments
        coordinator.dismissGallery()
    }
}
