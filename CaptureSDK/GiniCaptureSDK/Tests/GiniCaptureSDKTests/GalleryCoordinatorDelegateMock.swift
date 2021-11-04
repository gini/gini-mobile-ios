//
//  GalleryCoordinatorDelegateMock.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 3/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
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
