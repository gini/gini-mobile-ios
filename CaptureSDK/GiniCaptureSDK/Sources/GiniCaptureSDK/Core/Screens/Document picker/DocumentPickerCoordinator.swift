//
//  GalleryPickerManager.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 8/28/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import MobileCoreServices
import UIKit

/**
 The CameraViewControllerDelegate protocol defines methods that allow you to handle picked documents from both
 Gallery and Files Explorer.
 */
public protocol DocumentPickerCoordinatorDelegate: AnyObject {
    /**
     Called when a user picks one or several files from either the gallery or the files explorer.

     - parameter coordinator: `DocumentPickerCoordinator` where the documents were imported.
     - parameter documents: One or several documents imported.
     */
    func documentPicker(_ coordinator: DocumentPickerCoordinator,
                        didPick documents: [GiniCaptureDocument])

    /**
     Called when the picked documents could not be opened.

     - parameter coordinator: `DocumentPickerCoordinator` where the documents were imported.
     - parameter urls: URLs of the picked documents.
     */
    func documentPicker(_ coordinator: DocumentPickerCoordinator,
                        failedToPickDocumentsAt urls: [URL])
}

/**
 Document picker types.
 ````
 case gallery
 case explorer
 ````
 */

@objc public enum DocumentPickerType: Int {
    /// Gallery picker
    case gallery

    /// File explorer picker
    case explorer

    /// E-Invoice file picker (XML and PDF support)
    case eInvoice
}

/**
 The DocumentPickerCoordinator class allows you to present both the gallery and file explorer or to setup drag and drop
 in a view. If you want to handle the picked elements, you have to assign a `DocumentPickerCoordinatorDelegate` to
 the `delegate` property.
 When using multipage and having imported/captured images, you have to update the `isPDFSelectionAllowed`
 property before showing the File explorer in order to filter out PDFs.
 */

public final class DocumentPickerCoordinator: NSObject {
    /**
     The object that acts as the delegate of the document picker coordinator.
     */
    public weak var delegate: DocumentPickerCoordinatorDelegate?

    /**
     Used to filter out PDFs when there are already imported images.
     */
    public var isPDFSelectionAllowed: Bool = true

    /**
     Once the user has selected one or several documents from a picker, this has to be dismissed.
     Files explorer dismissal is handled by the OS and drag and drop does not need to be dismissed.
     However, the Gallery picker should be dismissed once the images has been imported.

     It is also used to check if the `currentPickerViewController` is still present so
     an error dialog can be shown fro there
     */
    public private(set) var currentPickerDismissesAutomatically: Bool = false

    /**
     The current picker `UIViewController`. Used to show an error after validating picked documents.
     */
    public private(set) var currentPickerViewController: UIViewController?

    /**
     Indicates if the user granted access to the gallery before. Used to start caching images before showing the Gallery
     picker.
     */
    public var isGalleryPermissionGranted: Bool {
        return galleryCoordinator.isGalleryPermissionGranted
    }

    let galleryCoordinator: GalleryCoordinator
    let giniConfiguration: GiniConfiguration

    fileprivate var acceptedDocumentTypes: [String] {
        switch giniConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return isPDFSelectionAllowed ?
                GiniPDFDocument.acceptedPDFTypes + GiniImageDocument.acceptedImageTypes :
                GiniImageDocument.acceptedImageTypes
        case .pdf:
            return isPDFSelectionAllowed ? GiniPDFDocument.acceptedPDFTypes : []
        case .none:
            return []
        }
    }
    
    fileprivate var acceptedEInvoiceTypes: [String] {
        let acceptedPDFTypes = isPDFSelectionAllowed ? GiniPDFDocument.acceptedPDFTypes : []
        return GiniXMLDocument.acceptedXMLTypes + acceptedPDFTypes
    }

    /**
     Designated initializer for the `DocumentPickerCoordinator`.

     - parameter giniConfiguration: `GiniConfiguration` use to configure the pickers.
     */
    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        galleryCoordinator = GalleryCoordinator(giniConfiguration: giniConfiguration)
    }

    /**
     Starts caching gallery images. Gallery permissions should have been granted before using it.
     */
    public func startCaching() {
        galleryCoordinator.start()
    }

    /**
     Set up the drag and drop feature in a view.

     - parameter view: View that will handle the drop interaction.
     - note: Only available in iOS >= 11
     */
    public func setupDragAndDrop(in view: UIView) {
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
    }

    // MARK: Picker presentation

    /**
     Shows the Gallery picker from a given viewController

     - parameter viewController: View controller which presentes the gallery picker
     */
    public func showGalleryPicker(from viewController: UIViewController) {
        galleryCoordinator.checkGalleryAccessPermission(deniedHandler: { error in
            if let error = error as? FilePickerError, error == FilePickerError.photoLibraryAccessDenied {
                viewController.showErrorDialog(for: error, positiveAction: UIApplication.shared.openAppSettings)
            }
        }, authorizedHandler: {
            DispatchQueue.main.async {
                self.galleryCoordinator.delegate = self
                self.currentPickerDismissesAutomatically = false
                self.currentPickerViewController = self.galleryCoordinator.rootViewController
                self.galleryCoordinator.galleryManager.reloadAlbums()

                viewController.present(self.galleryCoordinator.rootViewController, animated: true, completion: nil)
            }
        })
    }

    /**
     Shows the File explorer picker from a given viewController

     - parameter viewController: View controller which presentes the gallery picker
     */
    func showDocumentPicker(from viewController: UIViewController,
                                   device: UIDevice = UIDevice.current) {
        let documentPicker = GiniDocumentPickerViewController(documentTypes: acceptedDocumentTypes, in: .import)
        documentPicker.delegate = self

        documentPicker.allowsMultipleSelection = giniConfiguration.multipageEnabled
        documentPicker.view.tintColor = .GiniCapture.accent1
        currentPickerDismissesAutomatically = true
        currentPickerViewController = documentPicker

        viewController.present(documentPicker, animated: true)
    }

    /**
     Shows the E-Invoice file picker from a given view controller.

     - Parameters:
        - viewController: The view controller that presents the E-Invoice picker.
     */
    func showEInvoicePicker(from viewController: UIViewController) {
        let eInvoicePicker = GiniDocumentPickerViewController(documentTypes: acceptedEInvoiceTypes,
                                                              in: .import)
        eInvoicePicker.delegate = self
        eInvoicePicker.allowsMultipleSelection = true
        eInvoicePicker.view.tintColor = .GiniCapture.accent1

        currentPickerDismissesAutomatically = true
        currentPickerViewController = eInvoicePicker

        viewController.present(eInvoicePicker, animated: true)
    }

    /**
     Dimisses the `currentPickerViewController`

     - parameter completion: Completion block executed once the picker is dismissed
     */
    public func dismissCurrentPicker(completion: @escaping () -> Void) {
        if currentPickerDismissesAutomatically {
            completion()
        } else {
            galleryCoordinator.dismissGallery(completion: completion)
        }

        currentPickerViewController = nil
    }
}

// MARK: - Fileprivate methods

/// A UIDocumentPickerViewController that sets navigation bar buttons' tint color to a correct one, instead of using the accent color specified by app
private class GiniDocumentPickerViewController: UIDocumentPickerViewController {
    var initialTintColor: UIColor? = navBarInstance.tintColor
    var initialButtonTintColor: UIColor? = barButtonInstance.tintColor

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Self.navBarInstance.tintColor = .GiniCapture.accent1
        Self.barButtonInstance.tintColor = .GiniCapture.accent1
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // make sure to revert the tint color, otherwise it will affect document pickers/browsers from the host app
        Self.navBarInstance.tintColor = initialTintColor ?? UINavigationBar.appearance().tintColor
        Self.barButtonInstance.tintColor = initialButtonTintColor ?? UIBarButtonItem.appearance().tintColor
    }
    static var navBarInstance: UINavigationBar {
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self])
    }

    static var barButtonInstance: UIBarButtonItem {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self])
    }
}

fileprivate extension DocumentPickerCoordinator {
    func createDocument(fromData dataDictionary: (Data?, String?)) -> GiniCaptureDocument? {
        guard let data = dataDictionary.0 else { return nil }
        let documentBuilder = GiniCaptureDocumentBuilder(documentSource: .external)
        documentBuilder.importMethod = .picker

        return documentBuilder.build(with: data, fileName: dataDictionary.1)
    }

    func data(fromUrl url: URL) -> (Data?, String?) {
        do {
            _ = url.startAccessingSecurityScopedResource()
            let data = try Data(contentsOf: url)
            url.stopAccessingSecurityScopedResource()
            return (data, url.lastPathComponent)
        } catch {
            url.stopAccessingSecurityScopedResource()
        }

        return (nil, nil)
    }
}

// MARK: GalleryCoordinatorDelegate

extension DocumentPickerCoordinator: GalleryCoordinatorDelegate {
    func gallery(_ coordinator: GalleryCoordinator,
                 didSelectImageDocuments imageDocuments: [GiniImageDocument]) {
        delegate?.documentPicker(self, didPick: imageDocuments)
    }

    func gallery(_ coordinator: GalleryCoordinator, didCancel: Void) {
        coordinator.dismissGallery()
    }
}

// MARK: UIDocumentPickerDelegate

extension DocumentPickerCoordinator: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let documents: [GiniCaptureDocument] = urls
            .compactMap(data)
            .compactMap(createDocument)

        guard documents.isNotEmpty else {
            delegate?.documentPicker(self, failedToPickDocumentsAt: urls)
            return
        }

        delegate?.documentPicker(self, didPick: documents)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        documentPicker(controller, didPickDocumentsAt: [url])
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: false, completion: nil)
    }
}

// MARK: UIDropInteractionDelegate

extension DocumentPickerCoordinator: UIDropInteractionDelegate {
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        guard isDropSelectionAllowed(forSession: session) else {
            return false
        }

        let isMultipleItemsSelectionAllowed = session.items.count > 1 ? giniConfiguration.multipageEnabled : true
        switch giniConfiguration.fileImportSupportedTypes {
        case .pdf_and_images:
            return (session.canLoadObjects(ofClass: GiniImageDocument.self) ||
                    session.canLoadObjects(ofClass: GiniPDFDocument.self) ||
                    session.canLoadObjects(ofClass: GiniXMLDocument.self)) && isMultipleItemsSelectionAllowed
        case .pdf:
            return (session.canLoadObjects(ofClass: GiniPDFDocument.self) ||
                    session.canLoadObjects(ofClass: GiniXMLDocument.self)) && isMultipleItemsSelectionAllowed
        case .none:
            return false
        }
    }

    public func dropInteraction(_ interaction: UIDropInteraction,
                                sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        let dispatchGroup = DispatchGroup()
        var documents: [GiniCaptureDocument] = []

        loadDocuments(ofClass: GiniPDFDocument.self, from: session, in: dispatchGroup) { pdfItems in
            if let pdfs = pdfItems {
                documents.append(contentsOf: pdfs as [GiniCaptureDocument])
            }
        }

        loadDocuments(ofClass: GiniImageDocument.self, from: session, in: dispatchGroup) { imageItems in
            if let images = imageItems {
                documents.append(contentsOf: images as [GiniCaptureDocument])
            }
        }

        loadDocuments(ofClass: GiniXMLDocument.self, from: session, in: dispatchGroup) { xmlItems in
            if let xmls = xmlItems {
                documents.append(contentsOf: xmls as [GiniCaptureDocument])
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.currentPickerDismissesAutomatically = true
            self.delegate?.documentPicker(self, didPick: documents)
        }
    }

    private func loadDocuments<T: NSItemProviderReading>(ofClass classs: T.Type,
                                                         from session: UIDropSession,
                                                         in group: DispatchGroup,
                                                         completion: @escaping (([T]?) -> Void)) {
        group.enter()
        session.loadObjects(ofClass: classs.self) { items in
            if let items = items as? [T], items.isNotEmpty {
                completion(items)
            } else {
                completion(nil)
            }
            group.leave()
        }
    }

    private func isDropSelectionAllowed(forSession session: UIDropSession) -> Bool {
        let eInvoiceEnabled = GiniCaptureUserDefaultsStorage.eInvoiceEnabled ?? false
        let xmlIdentifier = GiniXMLDocument.acceptedXMLTypes.first
        let pdfIdentifier = GiniPDFDocument.acceptedPDFTypes.first
        let identifiers = eInvoiceEnabled ? [pdfIdentifier, xmlIdentifier] : [pdfIdentifier]

        guard session.hasItemsConforming(toTypeIdentifiers: identifiers.compactMap { $0 }) else {
            return true
        }

        let itemProviders = session.items.map { $0.itemProvider }

        let pdfCount = itemProviders.filter {
            guard let pdfIdentifier = pdfIdentifier else { return false }
            return $0.hasItemConformingToTypeIdentifier(pdfIdentifier)
        }.count

        let xmlCount: Int = eInvoiceEnabled
            ? itemProviders.filter {
                guard let xmlIdentifier = xmlIdentifier else { return false }
                return $0.hasItemConformingToTypeIdentifier(xmlIdentifier)
            }.count
            : 0

        let totalItems = pdfCount + xmlCount
        return totalItems <= 1 && isPDFSelectionAllowed
    }
}
