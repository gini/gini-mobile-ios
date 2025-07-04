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
    private var navigationBarBottomAdapter: ImagePickerBottomNavigationBarAdapter?

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

    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private var bottomNavigationBarHeightConstraint: NSLayoutConstraint?

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        configureBottomNavigationBar()
        setupConstraints()

        scrollToBottom()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if UIDevice.current.isIphone {
            let isLandscape = Device.orientation.isLandscape
            bottomNavigationBarHeightConstraint?.constant = isLandscape ? CameraBottomNavigationBar.Constants.heightLandscape : CameraBottomNavigationBar.Constants.heightPortrait
        }
    }

    private func setupView() {
        title = currentAlbum.title

        view.backgroundColor = GiniColor(light: .GiniCapture.light2, dark: .GiniCapture.dark2).uiColor()
        view.addSubview(contentView)
        contentView.addSubview(collectionView)
    }

    private func setupConstraints() {
        let contentViewBottomConstraint = contentView.bottomAnchor.constraint(
                                            greaterThanOrEqualTo: view.bottomAnchor)
        contentViewBottomConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentViewBottomConstraint
        ])
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
        collectionView.reloadItems(at: indexesToDeselect)
    }

    fileprivate func scrollToBottom() {
        collectionView.performBatchUpdates({
            self.collectionView.reloadData()
        }, completion: { _ in
            self.collectionView.scrollToItem(at: IndexPath(row: self.currentAlbum.count - 1,
                                                           section: 0),
                                             at: .bottom,
                                             animated: false)
        })
    }

    private func configureBottomNavigationBar() {
        if giniConfiguration.bottomNavigationBarEnabled {
            if let bottomBar = giniConfiguration.imagePickerNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBar
            } else {
                navigationBarBottomAdapter = DefaultImagePickerBottomNavigationBarAdapter()
            }

            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }

            if let navigationBar =
                navigationBarBottomAdapter?.injectedView() {
                navigationBar.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(navigationBar)

                layoutBottomNavigationBar(navigationBar)
            }
        }
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBar)
        bottomNavigationBarHeightConstraint = navigationBar.heightAnchor.constraint(equalToConstant: CameraBottomNavigationBar.Constants.heightPortrait)
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNavigationBarHeightConstraint!
        ])
        view.bringSubviewToFront(navigationBar)
        view.layoutSubviews()
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
        let keyWindow = UIApplication.shared.giniCurrentKeyWindow

        let leftSafeArea = keyWindow?.safeAreaInsets.left ?? 0
        let rightSafeArea = keyWindow?.safeAreaInsets.right ?? 0

        let itemsInARow: Int = Device.orientation.isLandscape ? Constants.imagesInRowLandscape : Constants.imagesInRowPortrait

        return ImagePickerCollectionViewCell.size(itemsInARow: itemsInARow,
                                                  collectionViewLayout: collectionViewLayout,
                                                  leftSafeArea: leftSafeArea,
                                                  rightSafeArea: rightSafeArea)
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

private extension ImagePickerViewController {
    enum Constants {
        static let imagesInRowPortrait: Int = 4
        static let imagesInRowLandscape: Int = 5
    }
}
