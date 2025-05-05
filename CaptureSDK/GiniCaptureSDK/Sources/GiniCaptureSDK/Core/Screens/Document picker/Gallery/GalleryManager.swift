//
//  GalleryManager.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import UIKit
import Photos

protocol GalleryManagerProtocol: AnyObject {
    var albums: [Album] { get }
    func fetchImage(from asset: Asset,
                    imageQuality: ImageQuality,
                    completion: @escaping ((UIImage) -> Void))
    func fetchImageData(from asset: Asset, completion: @escaping ((Data?) -> Void))
    func fetchRemoteImageData(from asset: Asset, completion: @escaping ((Data?) -> Void))
    func reloadAlbums()
    func startCachingImages(for album: Album)
    func stopCachingImages(for album: Album)
    var isGalleryAccessLimited: Bool { get set }
}

enum ImageQuality {
    case original, thumbnail
}

final class GalleryManager: GalleryManagerProtocol {
    var isGalleryAccessLimited = false

    private lazy var cachingImageManager = PHCachingImageManager()
    fileprivate let thumbnailSize = CGSize(width: 250, height: 250)
    lazy var albums: [Album] = self.fetchSortedAlbums()

    func fetchImage(from asset: Asset,
                    imageQuality: ImageQuality,
                    completion: @escaping ((UIImage) -> Void)) {
        let size = imageQuality == .original ? PHImageManagerMaximumSize: thumbnailSize
        cachingImageManager.requestImage(for: asset.value,
                                         targetSize: size,
                                         contentMode: .default,
                                         options: nil) { image, _ in
                                            if let image = image {
                                                completion(image)
                                            }
        }
    }

    func fetchImageData(from asset: Asset, completion: @escaping ((Data?) -> Void)) {
        cachingImageManager.requestImageDataAndOrientation(for: asset.value, options: nil) { data, _, _, _ in
            completion(data)
        }
    }

    func fetchRemoteImageData(from asset: Asset, completion: @escaping ((Data?) -> Void)) {
        var options: PHImageRequestOptions
        options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true

        cachingImageManager.requestImageDataAndOrientation(for: asset.value, options: options) { data, _, _, _ in
            completion(data)
        }
    }
    func reloadAlbums() {
        self.albums = fetchSortedAlbums()
    }

    func startCachingImages(for album: Album) {
        self.cachingImageManager.startCachingImages(for: album.assets.suffix(5).map { $0.value },
                                                    targetSize: PHImageManagerMaximumSize,
                                                    contentMode: .default,
                                                    options: nil)
    }

    func stopCachingImages(for album: Album) {
        self.cachingImageManager.stopCachingImages(for: album.assets.suffix(5).map { $0.value },
                                                   targetSize: PHImageManagerMaximumSize,
                                                   contentMode: .default,
                                                   options: nil)
    }
}

// MARK: Private Methods

extension GalleryManager {
    fileprivate func fetchAssets(in collection: PHAssetCollection) -> [Asset] {
        var assets: [Asset] = []

        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        let results = PHAsset.fetchAssets(in: collection, options: options)
        results.enumerateObjects({ obj, _, _ in
            let asset = Asset(value: obj)
            assets.append(asset)
        })

        return assets
    }

    fileprivate func fetchSortedAlbums() -> [Album] {
        var albums: [Album] = []
        let userAlbumsCollection = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum,
                                                                           subtype: PHAssetCollectionSubtype.any,
                                                                           options: nil) as? PHFetchResult<PHCollection>
        let topUserAlbumsCollection = PHAssetCollection.fetchTopLevelUserCollections(with: nil)

        let collections = [userAlbumsCollection!, topUserAlbumsCollection]
        collections.forEach { albumsCollection in
            albumsCollection.enumerateObjects({ (collection, _, _) in
                if let collection = collection as? PHAssetCollection {
                    let assets: [Asset] = self.fetchAssets(in: collection)
                    if !assets.isEmpty {
                        let album = Album(assets: assets,
                                          title: collection.localizedTitle ?? "",
                                          identifier: collection.localIdentifier)
                        albums.append(album)
                    }
                }
            })
        }

        return albums.sorted(by: {
            return $0.count > $1.count
        })
    }
}
