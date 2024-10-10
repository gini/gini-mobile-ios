//
//  GalleryCoordinator.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import GiniBankAPILibrary
import UIKit
import Photos
import PhotosUI

protocol GalleryCoordinatorDelegate: AnyObject {
    func gallery(_ coordinator: GalleryCoordinator,
                 didSelectImageDocuments imageDocuments: [GiniImageDocument])
    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void)
}

final class GalleryCoordinator: NSObject, Coordinator {

    weak var delegate: GalleryCoordinatorDelegate?
    fileprivate let giniConfiguration: GiniConfiguration
    let galleryManager: GalleryManagerProtocol
    fileprivate(set) var selectedImageDocuments: [(assetId: String, imageDocument: GiniImageDocument)] = [] {
        didSet {
            let button = selectedImageDocuments.isEmpty ? cancelButton : openImagesButton
            currentImagePickerViewController?.navigationItem.setRightBarButton(button, animated: true)
        }
    }

    var isGalleryPermissionGranted: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    // MARK: - View controllers

    var rootViewController: UIViewController {
        return containerNavigationController
    }

    lazy fileprivate(set) var containerNavigationController: ContainerNavigationController = {
        let container = ContainerNavigationController(rootViewController: self.galleryNavigator,
                                                      giniConfiguration: self.giniConfiguration)
        return container
    }()

    lazy fileprivate(set) var galleryNavigator: UINavigationController = {
        let navController = UINavigationController(rootViewController: self.albumsController)
        if giniConfiguration.customNavigationController == nil {
            navController.applyStyle(withConfiguration: self.giniConfiguration)
        }
        navController.delegate = self
        return navController
    }()

    lazy fileprivate(set) var albumsController: AlbumsPickerViewController = {
        let albumsPickerVC = AlbumsPickerViewController(galleryManager: self.galleryManager)
        albumsPickerVC.delegate = self
        if giniConfiguration.bottomNavigationBarEnabled {
            albumsPickerVC.navigationItem.rightBarButtonItem = self.cancelButton
        } else {
            albumsPickerVC.navigationItem.leftBarButtonItem = self.cancelButton
        }
        return albumsPickerVC
    }()

    fileprivate(set) var currentImagePickerViewController: ImagePickerViewController?

    // MARK: - Navigation bar buttons

    lazy var cancelButton: UIBarButtonItem = {
        let cancelButton = GiniBarButton(ofType: .cancel)
        cancelButton.addAction(self, #selector(cancelAction))
        return cancelButton.barButton
    }()

    lazy var openImagesButton: UIBarButtonItem = {
        let openButton = GiniBarButton(ofType: .done)
        openButton.addAction(self, #selector(openImages))
        return openButton.barButton
    }()

    // MARK: - Initializer

    init(galleryManager: GalleryManagerProtocol = GalleryManager(), giniConfiguration: GiniConfiguration) {
        self.galleryManager = galleryManager
        self.giniConfiguration = giniConfiguration
    }

    // MARK: - Coordinator lifecycle

    func start() {
        DispatchQueue.global().async {
            if let firstAlbum = self.galleryManager.albums.first {
                DispatchQueue.main.async {
                    self.galleryManager.startCachingImages(for: firstAlbum)
                    if #unavailable(iOS 14.0) {
                        self.currentImagePickerViewController = self.createImagePicker(with: firstAlbum)
                        self.galleryNavigator.pushViewController(self.currentImagePickerViewController!,
                                                                 animated: false)
                    }
                }
            }
        }
    }

    func dismissGallery(completion: (() -> Void)? = nil) {
        rootViewController.dismiss(animated: true) { [weak self] in
            completion?()
            self?.galleryNavigator.popViewController(animated: false)
            self?.currentImagePickerViewController = nil
        }
        resetToInitialState()
    }

    private func resetToInitialState() {
        self.selectedImageDocuments.removeAll()
        self.currentImagePickerViewController?.deselectAllCells()
        self.currentImagePickerViewController?.navigationItem.setRightBarButton(cancelButton, animated: false)
    }

    // MARK: - Bar button actions
    @objc func cancelAction() {
        selectedImageDocuments = []
        delegate?.gallery(self, didCancel: ())
    }

    @objc func openImages() {
        DispatchQueue.main.async {
            let imageDocuments: [GiniImageDocument] = self.selectedImageDocuments.map { $0.imageDocument }
            self.delegate?.gallery(self, didSelectImageDocuments: imageDocuments)
        }
    }

    @objc
    private func backAction() {
        galleryNavigator.popViewController(animated: true)
    }

    // MARK: - Image picker generation.

    fileprivate func createImagePicker(with album: Album) -> ImagePickerViewController {
        let imagePickerViewController = ImagePickerViewController(album: album,
                                                                  galleryManager: galleryManager,
                                                                  giniConfiguration: giniConfiguration)
        imagePickerViewController.delegate = self
        imagePickerViewController.navigationItem.rightBarButtonItem = cancelButton
        imagePickerViewController.navigationItem.setHidesBackButton(true, animated: false)
        if !giniConfiguration.bottomNavigationBarEnabled {
            let buttonTitle = NSLocalizedStringPreferredFormat("ginicapture.images.backToAlbums", comment: "Albums")
            let backButton = GiniBarButton(ofType: .back(title: buttonTitle))
            backButton.addAction(self, #selector(backAction))
            imagePickerViewController.navigationItem.leftBarButtonItem = backButton.barButton
        }

        return imagePickerViewController
    }

    // MARK: Photo library permission

    // swiftlint:disable function_body_length
    func checkGalleryAccessPermission(deniedHandler: @escaping (_ error: GiniCaptureError) -> Void,
                                      authorizedHandler: @escaping () -> Void) {
        if #available(iOS 14.0, *) {
            let accessLevel: PHAccessLevel = .readWrite
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { [weak self] newStatus in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch newStatus {
                    case .limited:
                        // used authorizedHandler because showing limited photo picker didn't require any permissions
                        self.galleryManager.isGalleryAccessLimited = true
                        authorizedHandler()
                    case .notDetermined:
                        PHPhotoLibrary.requestAuthorization { [weak self] status in
                            guard let self = self else { return }
                            DispatchQueue.main.async {
                                if status == PHAuthorizationStatus.authorized {
                                    self.galleryManager.reloadAlbums()
                                    self.start()
                                    authorizedHandler()
                                } else {
                                    deniedHandler(FilePickerError.photoLibraryAccessDenied)
                                }
                            }
                        }
                    case .restricted, .denied:
                        deniedHandler(FilePickerError.photoLibraryAccessDenied)
                    case .authorized:
                        authorizedHandler()
                    @unknown default:
                        break
                    }
                }
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                authorizedHandler()
            #if swift(>=5.3) // Xcode 12 iOS 14 support
            case .limited:
                authorizedHandler()
            #endif
            case .denied, .restricted:
                deniedHandler(FilePickerError.photoLibraryAccessDenied)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        if status == PHAuthorizationStatus.authorized {
                            self.galleryManager.reloadAlbums()
                            self.start()
                            authorizedHandler()
                        } else {
                            deniedHandler(FilePickerError.photoLibraryAccessDenied)
                        }
                    }
                }
            @unknown default:
                break
            }
        }
    }
    // swiftlint:enable function_body_length
}

// MARK: UINavigationControllerDelegate

extension GalleryCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let imagePicker = fromVC as? ImagePickerViewController {
            galleryManager.stopCachingImages(for: imagePicker.currentAlbum)
            currentImagePickerViewController = nil
            selectedImageDocuments.removeAll()
        }
        return nil
    }
}

// MARK: - AlbumsPickerViewControllerDelegate

extension GalleryCoordinator: AlbumsPickerViewControllerDelegate {
    func albumsPicker(_ viewController: AlbumsPickerViewController, didSelectAlbum album: Album) {
        currentImagePickerViewController = createImagePicker(with: album)
        galleryNavigator.pushViewController(currentImagePickerViewController!, animated: true)
    }
}

// MARK: - ImagePickerViewControllerDelegate

extension GalleryCoordinator: ImagePickerViewControllerDelegate {
    func imagePicker(_ viewController: ImagePickerViewController,
                     didSelectAsset asset: Asset,
                     at index: IndexPath) {
        viewController.addToDownloadingItems(index: index)
        galleryManager.fetchImageData(from: asset) { [weak self, weak viewController] data in
            guard let self = self else { return }
            if let data = data {
                viewController?.removeFromDownloadingItems(index: index)
                viewController?.selectCell(at: index)
                self.addSelected(asset, withData: data)
            } else {
                self.galleryManager.fetchRemoteImageData(from: asset) { [weak self] data in
                    guard let self = self else { return }
                    if let data = data {
                        viewController?.removeFromDownloadingItems(index: index)
                        viewController?.selectCell(at: index)
                        self.addSelected(asset, withData: data)
                    }
                }
            }
        }
    }

    func imagePicker(_ viewController: ImagePickerViewController,
                     didDeselectAsset asset: Asset,
                     at index: IndexPath) {
        if let documentIndex = selectedImageDocuments.firstIndex(where: { $0.assetId == asset.identifier }) {
            viewController.deselectCell(at: index)
            selectedImageDocuments.remove(at: documentIndex)
        }
    }

    private func addSelected(_ asset: Asset, withData data: Data) {
        var data = data

        // Some pictures have a wrong bytes structure and are not processed as images.
        if !data.isImage {
            if let image = UIImage(data: data),
                let imageData = image.jpegData(compressionQuality: 1.0) {
                data = imageData
            }
        }
        let uploadMeta = Document.UploadMetadata(
            giniCaptureVersion: GiniCaptureSDKVersion,
            deviceOrientation: "",
            source: DocumentSource.external.value,
            importMethod: DocumentImportMethod.picker.rawValue,
            entryPoint: {
                switch GiniConfiguration.shared.entryPoint {
                case .button: "button"
                case .field: "field"
                }
            }(),
            osVersion: UIDevice.current.systemVersion
        )
        let imageDocument = GiniImageDocument(data: data,
                                              imageSource: .external,
                                              imageImportMethod: .picker,
                                              deviceOrientation: nil,
                                              uploadMetadata: uploadMeta)

        selectedImageDocuments.append((assetId: asset.identifier,
                                       imageDocument: imageDocument))

        if !giniConfiguration.multipageEnabled {
            openImages()
        }
    }
}
