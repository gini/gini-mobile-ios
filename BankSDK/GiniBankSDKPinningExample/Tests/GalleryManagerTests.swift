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

    private let asset1 = Asset(identifier: "Asset 1")
    private let asset2 = Asset(identifier: "Asset 2")

    private let albumTitles = ["Album 1", "Album 2", "Album 3"]

    private func createAlbum(index: Int, assets: [Asset]) -> Album {
        return Album(assets: assets, title: albumTitles[index], identifier: albumTitles[index])
    }

    lazy var albums: [Album] = [
        createAlbum(index: 0, assets: [asset1]),
        createAlbum(index: 1, assets: [asset1, asset2]),
        createAlbum(index: 2, assets: [asset1, asset2])
    ]

    var isCaching = false

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
        completion(Data(count: 10))
    }

    func fetchRemoteImageData(from asset: Asset, completion: @escaping ((Data?) -> Void)) {
        completion(Data(count: 10))
    }

    func fetchImage(from asset: Asset, imageQuality: ImageQuality, completion: @escaping ((UIImage) -> Void)) {
        // This method will remain empty; no implementation is needed.
    }
}

extension Asset {
    init(identifier: String) {
        self.init(value: PHAsset())
        self.identifier = identifier
    }
}
