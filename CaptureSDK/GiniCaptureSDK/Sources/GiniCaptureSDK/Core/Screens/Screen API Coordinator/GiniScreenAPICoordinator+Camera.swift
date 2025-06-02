//
//  GiniScreenAPICoordinator+Camera.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniBankAPILibrary

/**
 The UploadDelegate protocol defines methods that allow you to notify the _Gini Capture SDK_ when a document upload
 has finished (either successfully or with an error) 
 */
@objc public protocol UploadDelegate {
    func uploadDidFail(for document: GiniCaptureDocument, with error: Error)
    func uploadDidComplete(for document: GiniCaptureDocument)
}

extension GiniScreenAPICoordinator: CameraViewControllerDelegate {

   func camera(_ viewController: CameraViewController, didCapture document: GiniCaptureDocument) {
        let loadingView = viewController.addValidationLoadingView()

        validate([document]) { result in
            loadingView.removeFromSuperview()
            switch result {
            case .success(let validatedPages):
                let validatedPage = validatedPages[0]
                self.addToDocuments(new: [validatedPage])
                self.didCaptureAndValidate(document)
                if document.type == .qrcode {
                    // Skip the analysis screen and validate the QR code on the same screen
                    return
                }
                self.showNextScreenAfterPicking(pages: [validatedPage])
            case .failure(let error):
                var errorMessage = String(describing: error)

                if let error = error as? FilePickerError,
                    (error == .maxFilesPickedCountExceeded || error == .mixedDocumentsUnsupported) {
                    errorMessage = error.message
                    viewController.showErrorDialog(for: error) {
                        self.showReview()
                    }
                }
                let errorLog = ErrorLog(description: errorMessage, error: error)
                self.giniConfiguration.errorLogger.handleErrorLog(error: errorLog)
            }
        }
    }

    func camera(_ viewController: CameraViewController, didSelect documentPicker: DocumentPickerType) {
        switch documentPicker {
        case .gallery:
            documentPickerCoordinator.showGalleryPicker(from: viewController)
        case .explorer:
            documentPickerCoordinator.isPDFSelectionAllowed = pages.isEmpty
            documentPickerCoordinator.showDocumentPicker(from: viewController)
        }
    }

    func cameraDidAppear(_ viewController: CameraViewController) {
        // we should reinitialize camera when it's already initialized, otherwise camera behaves weird
        guard viewController.cameraNeedsInitializing || shouldShowOnboarding() else {
            viewController.stopLoadingIndicater()
            return
        }
        let bottomAnchor = viewController.topNavBarAnchor ?? viewController.view.bottomAnchor
        if shouldShowOnboarding() {
            showOnboardingScreen(cameraViewController: viewController, completion: {
                viewController.setupCamera(bottomAnchor: bottomAnchor)
            })
        } else {
            viewController.setupCamera(bottomAnchor: bottomAnchor)
        }
    }

    func cameraDidTapReviewButton(_ viewController: CameraViewController) {
        popBackToReview()
    }

    private func createCameraButtonsViewModel() -> CameraButtonsViewModel {
        let cameraButtonsViewModel = CameraButtonsViewModel(
            trackingDelegate: trackingDelegate
        )
        cameraButtonsViewModel.helpAction = { [weak self] in
            self?.showHelpMenuScreen()
        }
        cameraButtonsViewModel.cancelAction = { [weak self] in
            self?.finishWithCancellation()
        }
        return cameraButtonsViewModel
    }

    func createCameraViewController() -> CameraViewController {
        let cameraButtonsViewModel = createCameraButtonsViewModel()

        let cameraViewController = CameraViewController(
            giniConfiguration: giniConfiguration,
            viewModel: cameraButtonsViewModel
        )
        cameraViewController.delegate = self
        documentPickerCoordinator.setupDragAndDrop(in: cameraViewController.view)
        cameraButtonsViewModel.backButtonAction = { [weak cameraViewController, weak self] in
            if let strongSelf = self, strongSelf.pages.count > 0 {
                if let cameraViewController = cameraViewController {
                    self?.cameraDidTapReviewButton(cameraViewController)
                }
            } else {
                GiniAnalyticsManager.track(event: .closeTapped, screenName: .camera)
                self?.finishWithCancellation()
            }
        }

        if !giniConfiguration.bottomNavigationBarEnabled {
            if pages.count > 0 {
                let buttonTitle = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.analysis.backToReview",
                                                                   comment: "Review")
                let backButton = GiniBarButton(ofType: .back(title: buttonTitle))
                backButton.addAction(self, #selector(popBackToReview))
                cameraViewController.navigationItem.leftBarButtonItem = backButton.barButton
            } else {
                let cancelButton = GiniBarButton(ofType: .cancel)
                cancelButton.addAction(self, #selector(back))
                cameraViewController.navigationItem.leftBarButtonItem = cancelButton.barButton
            }

            let helpButton = GiniBarButton(ofType: .help)
            helpButton.addAction(self, #selector(showHelpMenuScreen))
            cameraViewController.navigationItem.rightBarButtonItem = helpButton.barButton
        }

        if giniConfiguration.fileImportSupportedTypes != .none {
            documentPickerCoordinator.delegate = self
            if documentPickerCoordinator.isGalleryPermissionGranted {
                documentPickerCoordinator.startCaching()
            }
        }
        self.cameraScreen = cameraViewController
        return cameraViewController
    }

    fileprivate func didCaptureAndValidate(_ document: GiniCaptureDocument) {
        visionDelegate?.didCapture(document: document, networkDelegate: self)
    }

    private func shouldShowOnboarding() -> Bool {
        if giniConfiguration.onboardingShowAtFirstLaunch &&
            !GiniCaptureUserDefaultsStorage.onboardingShowed {
            GiniCaptureUserDefaultsStorage.onboardingShowed = true
            return true
        } else if giniConfiguration.onboardingShowAtLaunch && !hasOnboardingShownOnLaunch(){
            return true
        }

        return false
    }

    private func showOnboardingScreen(
        cameraViewController: CameraViewController,
        completion: @escaping () -> Void) {
        cameraViewController.hideCaptureButton()

        let vc = OnboardingViewController()
        cameraViewController.showCaptureButton()

        completion()
        let navigationController = UINavigationController(rootViewController: vc)
        if giniConfiguration.customNavigationController == nil {
            navigationController.applyStyle(withConfiguration: giniConfiguration)
        }
        navigationController.modalPresentationStyle = .overCurrentContext

        // Since the onboarding appears on startup, it could be the case where there are two consecutive 'coverVertical'
        // modal transitions. When the Screen API is embedded in a UINavigationController, it still has that
        // transition but it's not used.
        if let rootContainerViewController = rootViewController.parent,
            rootContainerViewController.modalTransitionStyle == .coverVertical,
            !(rootContainerViewController.parent is UINavigationController) {
            navigationController.modalTransitionStyle = .crossDissolve
        }

        screenAPINavigationController.present(navigationController, animated: true, completion: nil)
    }

    func showNextScreenAfterPicking(pages: [GiniCapturePage]) {
        let visionDocuments = pages.map { $0.document }

        // Creating an array of GiniImageDocuments and filtering it for 'isFromOtherApp'
        if visionDocuments.compactMap({ $0 as? GiniImageDocument }).filter({ $0.isFromOtherApp }).isNotEmpty {
            showAnalysisScreen()
        } else {
            if let documentsType = visionDocuments.type {
                switch documentsType {
                case .image:
                    showReview()
                case .qrcode, .pdf:
                    showAnalysisScreen()
                }
            }
        }
    }
}

// MARK: - DocumentPickerCoordinatorDelegate

extension GiniScreenAPICoordinator: DocumentPickerCoordinatorDelegate {

    public func documentPicker(
        _ coordinator: DocumentPickerCoordinator,
        didPick documents: [GiniCaptureDocument]) {

        self.validate(documents) { result in
            switch result {
            case .success(let validatedDocuments):
                coordinator.dismissCurrentPicker {
                    self.addToDocuments(new: validatedDocuments)
                    errorOccurred = false
                    validatedDocuments.forEach { validatedDocument in
                        if validatedDocument.error == nil {
                            self.didCaptureAndValidate(validatedDocument.document)
                        }
                    }
                    self.showNextScreenAfterPicking(pages: validatedDocuments)
                }
            case .failure(let error):
                var positiveAction: (() -> Void)?

                if let error = error as? FilePickerError {
                    switch error {
                    case .maxFilesPickedCountExceeded, .mixedDocumentsUnsupported, .multiplePdfsUnsupported:
                        if self.pages.isNotEmpty {
                            positiveAction = {
                                coordinator.dismissCurrentPicker {
                                    self.showReview()
                                }
                            }
                        }
                    case .photoLibraryAccessDenied, .failedToOpenDocument:
                        break
                    }
                }
                if coordinator.currentPickerDismissesAutomatically {
                    self.cameraScreen?.showErrorDialog(for: error,
                                                       positiveAction: positiveAction)
                } else {
                    coordinator.currentPickerViewController?.showErrorDialog(for: error,
                                                                             positiveAction: positiveAction)
                }
            }
        }
    }

        public func documentPicker(_ coordinator: DocumentPickerCoordinator, failedToPickDocumentsAt urls: [URL]) {
            let error = FilePickerError.failedToOpenDocument
            if coordinator.currentPickerDismissesAutomatically {
                self.cameraScreen?.showErrorDialog(for: error,
                                                   positiveAction: nil)
            } else {
                coordinator.currentPickerViewController?.showErrorDialog(for: error,
                                                                         positiveAction: nil)
            }
        }

    fileprivate func addDropInteraction(forView view: UIView, with delegate: UIDropInteractionDelegate) {
        let dropInteraction = UIDropInteraction(delegate: delegate)
        view.addInteraction(dropInteraction)
    }
}

// MARK: - Validation

extension GiniScreenAPICoordinator {

    fileprivate func validate(_ documents: [GiniCaptureDocument],
                              completion: @escaping (Result<[GiniCapturePage], Error>) -> Void) {
        var documentsToValidate = documents + pages.map { $0.document }

        for document in documentsToValidate where document.type == .qrcode {
            // Scanning a QR code takes priority, even if the user has already taken some pictures.
            // All the pages that have already been scanned should be discarded and keep the document generated after scanning the QR code.
            // The flow of the QR code scanning process should be followed
            documentsToValidate = [document]
            break
        }

        guard !documentsToValidate.containsDifferentTypes else {
            completion(.failure(FilePickerError.mixedDocumentsUnsupported))
            return
        }

        guard documentsToValidate.filter({ $0.type == .pdf }).count <= 1 else {
            completion(.failure(FilePickerError.multiplePdfsUnsupported))
            return
        }

        guard documentsToValidate.count <= GiniCaptureDocumentValidator.maxPagesCount else {
            completion(.failure(FilePickerError.maxFilesPickedCountExceeded))
            return
        }

        self.validate(importedDocuments: documents) { validatedDocuments in
            let elementsWithError = validatedDocuments.filter { $0.error != nil }
            if let firstElement = elementsWithError.first,
                let error = firstElement.error {
                completion(.failure(error))
            } else {
                completion(.success(validatedDocuments))
            }
        }
    }

    private func validate(importedDocuments documents: [GiniCaptureDocument],
                          completion: @escaping ([GiniCapturePage]) -> Void) {
        DispatchQueue.global().async {
            var pages: [GiniCapturePage] = []
            documents.forEach { document in
                var documentError: Error?
                do {
                    try GiniCaptureDocumentValidator.validate(document,
                                                              withConfig: self.giniConfiguration)
                } catch let error {
                    documentError = error
                }
                pages.append(GiniCapturePage(document: document, error: documentError))
            }

            DispatchQueue.main.async {
                completion(pages)
            }
        }
    }
}

// MARK: - UploadDelegate

extension GiniScreenAPICoordinator: UploadDelegate {
    public func uploadDidComplete(for document: GiniCaptureDocument) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.update(document, withError: nil, isUploaded: true)
        }
    }

    public func uploadDidFail(for document: GiniCaptureDocument, with error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.update(document, withError: error, isUploaded: false)

            let errorLog = ErrorLog(
                description: String(describing: error),
                error: error)
            self.giniConfiguration.errorLogger.handleErrorLog(error: errorLog)
            guard let giniError = error as? GiniError, giniError != .requestCancelled else { return }
            self.displayError(errorType: ErrorType(error: giniError), animated: true)
        }
    }
}
