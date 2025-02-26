//
//  GalleryManagerTests.swift
//  Example_Tests
//
//  Copyright © 2021 Gini GmbH. All rights reserved.
//

import UIKit
@testable import GiniCaptureSDK
import Photos

final class GalleryManagerMock: GalleryManagerProtocol {
    var isGalleryAccessLimited: Bool = false
    var isCaching = false

    private let defaultAssets = [
        Asset(identifier: "Asset 1"),
        Asset(identifier: "Asset 2")
    ]

    lazy var albums: [Album] = createMockAlbums()

    private func createMockAlbums() -> [Album] {
        return [
            Album(assets: [defaultAssets[0]],
                  title: "Album 1",
                  identifier: "Album 1"),
            Album(assets: defaultAssets,
                  title: "Album 2",
                  identifier: "Album 2"),
            Album(assets: defaultAssets,
                  title: "Album 3",
                  identifier: "Album 3")
        ]
    }


    func reloadAlbums() {
        // This method will remain empty; no implementation is needed.
    }

    func startCachingImages(for album: Album) {
        isCaching = true
    }

    func stopCachingImages(for album: Album) {
        isCaching = false
    }

    func fetchImageData(from asset: Asset, completion: @escaping ((Data?) -> Void)) {
        completion(mockData())
    }

    func fetchRemoteImageData(from asset: Asset, completion: @escaping ((Data?) -> Void)) {
        completion(mockData())
    }

    func fetchImage(from asset: Asset, imageQuality: ImageQuality, completion: @escaping ((UIImage) -> Void)) {
        // This method will remain empty; no implementation is needed.
    }

    private func mockData() -> Data? {
        return Data(count: 10)
    }
}

extension Asset {
    init(identifier: String) {
        self.init(value: PHAsset())
        self.identifier = identifier
    }
}
