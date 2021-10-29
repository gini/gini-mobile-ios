//
//  ImagePickerViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import UIKit
import Photos

protocol ImagePickerViewControllerDelegate: AnyObject {
    func imagePicker(_ viewController: ImagePickerViewController,
                     didSelectAsset asset: Asset,
                     at index: IndexPath)
    func imagePicker(_ viewController: ImagePickerViewController,
                     didDeselectAsset  asset: Asset,
                     at index: IndexPath)
}

final class ImagePickerViewController: UIViewController {
    
    let currentAlbum: Album
    weak var delegate: ImagePickerViewControllerDelegate?
    fileprivate var indexesForAssetsBeingDownloaded: [IndexPath] = []
    fileprivate var indexesForSelectedCells: [IndexPath] = []
    fileprivate let galleryManager: GalleryManagerProtocol
    fileprivate let giniConfiguration: GiniConfiguration
    private var isInitialized: Bool = false
    
    // MARK: - Views
    
    lazy var collectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.minimumLineSpacing = 1
        collectionLayout.minimumInteritemSpacing = 1
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.register(ImagePickerCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
        return collectionView
    }()
    
    // MARK: - Initializers
    
    init(album: Album,
         galleryManager: GalleryManagerProtocol,
         giniConfiguration: GiniConfiguration) {
        self.galleryManager = galleryManager
        self.giniConfiguration = giniConfiguration
        self.currentAlbum = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    override func loadView() {
        super.loadView()
        
        title = currentAlbum.title
        
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.galleryScreenBackgroundColor)
        
        view.addSubview(collectionView)
        
        Constraints.pin(view: collectionView, toSuperView: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToBottomOnStartup()
    }
    
    // MARK: - Others
    
    func addToDownloadingItems(index: IndexPath, needsReloading: Bool = true) {
        indexesForAssetsBeingDownloaded.append(index)
        if needsReloading {
            collectionView.reloadItems(at: [index])
        }
    }
    
    func removeFromDownloadingItems(index: IndexPath, needsReloading: Bool = false) {
        if let assetIndex = indexesForAssetsBeingDownloaded.firstIndex(of: index) {
            indexesForAssetsBeingDownloaded.remove(at: assetIndex)
            if needsReloading {
                collectionView.reloadItems(at: [index])
            }
        }
    }
    
    func selectCell(at indexPath: IndexPath) {
        indexesForSelectedCells.append(indexPath)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func deselectCell(at indexPath: IndexPath) {
        if let deselectCellIndex = indexesForSelectedCells.firstIndex(of: indexPath) {
            indexesForSelectedCells.remove(at: deselectCellIndex)
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func deselectAllCells() {
        var indexesToDeselect: [IndexPath] = []
        indexesToDeselect.append(contentsOf: indexesForSelectedCells)
        
        indexesForSelectedCells.removeAll()
        self.collectionView.reloadItems(at: indexesToDeselect)
    }
 
    fileprivate func scrollToBottomOnStartup() {
        // This tweak is needed to fix an issue with the UICollectionView. UICollectionView doesn't
        // scroll to the bottom on `viewWillAppear`, which is right after `viewDidLayoutSubviews`.
        // Since this method can be called several times during the lifecycle, there should be
        // a one-time scrolling before the view appears for the first time.
        if !isInitialized {
            isInitialized = true
            collectionView.scrollToItem(at: IndexPath(row: currentAlbum.count - 1,
                                                      section: 0),
                                        at: .bottom,
                                        animated: false)
        }
    }
}

// MARK: UICollectionViewDataSource

extension ImagePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.identifier,
                                                      for: indexPath) as? ImagePickerCollectionViewCell
        let asset = currentAlbum.assets[indexPath.row]
        cell?.fill(withAsset: asset,
                   multipleSelectionEnabled: giniConfiguration.multipageEnabled,
                   galleryManager: galleryManager,
                   isDownloading: indexesForAssetsBeingDownloaded.contains(indexPath),
                   isSelected: indexesForSelectedCells.contains(indexPath))
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentAlbum.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: UICollectionViewDelegate

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return ImagePickerCollectionViewCell.size(itemsInARow: 4,
                                                  collectionViewLayout: collectionViewLayout)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = currentAlbum.assets[indexPath.row]

        if indexesForSelectedCells.contains(indexPath) {
            delegate?.imagePicker(self, didDeselectAsset: asset, at: indexPath)
        } else {
            delegate?.imagePicker(self, didSelectAsset: asset, at: indexPath)
        }
    }
}
