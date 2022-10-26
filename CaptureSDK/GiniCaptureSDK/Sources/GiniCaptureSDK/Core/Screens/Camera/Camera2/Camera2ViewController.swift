//
//  Camera2ViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

public final class Camera2ViewController: UIViewController, CameraScreen {

    /**
     The object that acts as the delegate of the camera view controller.
    */
    private var opaqueView: UIView?
    let giniConfiguration: GiniConfiguration
    var detectedQRCodeDocument: GiniQRCodeDocument?
    var currentQRCodePopup: QRCodeDetectedPopupView?
    private var shouldShowQRCodeNext = false
    lazy var cameraPreviewViewController: CameraPreviewViewController = {
       let cameraPreviewViewController = CameraPreviewViewController()
       cameraPreviewViewController.delegate = self
       return cameraPreviewViewController
    }()
    public weak var delegate: CameraViewControllerDelegate?

    @IBOutlet weak var cameraPane: CameraPane!
    private let cameraButtonsViewModel: CameraButtonsViewModel
    private var navigationBarBottomAdapter: CameraBottomNavigationBarAdapter?

    @IBOutlet weak var bottomButtonsConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomPaneConstraint: NSLayoutConstraint!
    /**
     Designated initializer for the `CameraViewController` which allows
     to set the `GiniConfiguration for the camera screen`.
     All the interactions with this screen are handled by `CameraViewControllerDelegate`.
     
     - parameter giniConfiguration: `GiniConfiguration` instance.
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
    */
    public init(
        giniConfiguration: GiniConfiguration,
        viewModel: CameraButtonsViewModel
    ) {
        self.giniConfiguration = giniConfiguration
        self.cameraButtonsViewModel = viewModel
        if UIDevice.current.isIphone {
            super.init(nibName: "CameraPhone", bundle: giniCaptureBundle())
        } else {
            super.init(nibName: "CameraiPad", bundle: giniCaptureBundle())
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        showUploadButton()
        setupView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(to: giniConfiguration.statusBarStyle)
        cameraPane.toggleCaptureButtonActivation(state: true)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.cameraDidAppear(self)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        opaqueView?.frame = cameraPreviewViewController.view.frame
    }

    private func setupView() {
        self.title = NSLocalizedStringPreferredFormat(
            "ginicapture.camera.infoLabel",
            comment: "Info label")
        edgesForExtendedLayout = []
        view.backgroundColor = giniConfiguration.cameraContainerViewBackgroundColor.uiColor()
        addChild(cameraPreviewViewController)
        view.addSubview(cameraPreviewViewController.view)
        cameraPreviewViewController.didMove(toParent: self)
        view.sendSubviewToBack(cameraPreviewViewController.view)
        configureConstraints()
        if UIDevice.current.isIphone {
            self.title = NSLocalizedStringPreferredFormat(
                "ginicapture.navigationbar.camera.title",
                comment: "Info label")
        } else {
            self.title = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.infoLabel",
                comment: "Info label")
        }
        setupInitialState()
        configureButtons()
        configureBottomNavigationBar()
    }

    private func setupInitialState() {
        navigationBarBottomAdapter?.showButtons(navigationButtons: [.help])
    }

    private func setupNotEmptyState() {
        navigationBarBottomAdapter?.showButtons(navigationButtons: [.help, .back])
    }

    private func configureCustomTopNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedStringPreferredFormat(
                "ginicapture.camera.popupCancel",
                comment: "Cancel button"),
            style: .plain,
            target: cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.cancelPressed))
    }

    private func configureBottomNavigationBar() {
        if giniConfiguration.bottomNavigationBarEnabled {
            configureCustomTopNavigationBar()
            if let bottomBar = giniConfiguration.cameraNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBar
            } else {
                navigationBarBottomAdapter = DefaultCameraBottomNavigationBarAdapter()
            }
            navigationBarBottomAdapter?.setHelpButtonClickedActionCallback { [weak self] in
                self?.cameraButtonsViewModel.helpAction?()
            }
            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                self?.cameraButtonsViewModel.backButtonAction?()
            }

            if let navigationBar =
                navigationBarBottomAdapter?.injectedView() {
                view.addSubview(navigationBar)
                layoutBottomNavigationBar(navigationBar)
            }
        }
    }

    private func layoutBottomNavigationBar(_ navigationBar: UIView) {
        if UIDevice.current.isIpad {
            view.removeConstraints([cameraPreviewBottomContraint])
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navigationBar)
            NSLayoutConstraint.activate([
                navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationBar.heightAnchor.constraint(equalToConstant: navigationBar.frame.height),
                cameraPreviewViewController.view.bottomAnchor.constraint(equalTo: navigationBar.topAnchor)
            ])
        } else {
            view.removeConstraints([bottomPaneConstraint, bottomButtonsConstraints])
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navigationBar)
            NSLayoutConstraint.activate([
                navigationBar.topAnchor.constraint(equalTo: cameraPane.bottomAnchor),
                navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationBar.heightAnchor.constraint(equalToConstant: navigationBar.frame.height),
                cameraPane.leftButtonsStack.bottomAnchor.constraint(equalTo: cameraPane.bottomAnchor)
            ])
        }
        view.bringSubviewToFront(navigationBar)
        view.layoutSubviews()
    }

    private func configureButtons() {
        cameraPane.setupAuthorization(isHidden: false)
        configureLeftButtons()
        cameraButtonsViewModel.captureAction = { [weak self] in
            self?.cameraPane.toggleCaptureButtonActivation(state: false)
            self?.cameraPreviewViewController.captureImage { [weak self] data, error in
                guard let self = self else { return }

                var capturedData = data
                if let imageData = data, let image = UIImage(data: imageData)?.fixOrientation() {
                    let croppedImage = self.crop(image: image)
                    capturedData = croppedImage.jpegData(compressionQuality: 1)
                }

                if let image = self.cameraButtonsViewModel.didCapture(imageData: capturedData,
                                                                      error: error,
                                                                      orientation:
                                                                        UIApplication.shared.statusBarOrientation,
                                                                      giniConfiguration: self.giniConfiguration) {

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.didPick(image)
                }
                self.cameraPane.toggleCaptureButtonActivation(state: true)
            }
        }
        cameraButtonsViewModel.backButtonAction = { [weak self] in
            if let strongSelf = self {
                self?.delegate?.cameraDidTapReviewButton(strongSelf)
            }
        }
        cameraPane.captureButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.capturePressed),
            for: .touchUpInside)
        cameraButtonsViewModel.imageStackAction = { [weak self] in
            if let strongSelf = self {
                self?.delegate?.cameraDidTapReviewButton(strongSelf)
            }
        }
        cameraButtonsViewModel.imagesUpdated = { [weak self] images in
            if let lastImage = images.last {
                self?.cameraPane.thumbnailView.updateStackStatus(to: .filled(count: images.count, lastImage: lastImage))
            } else {
                self?.cameraPane.thumbnailView.updateStackStatus(to: ThumbnailView.State.empty)
            }
        }
        cameraButtonsViewModel.imagesUpdated?(cameraButtonsViewModel.images)
        cameraPane.thumbnailView.thumbnailButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.thumbnailPressed),
            for: .touchUpInside)
    }

    private func showUploadButton() {
        if giniConfiguration.fileImportSupportedTypes != .none {
            cameraPane.fileUploadButton.isHidden = false
        } else {
            cameraPane.fileUploadButton.isHidden = true
        }
    }

    private func configureLeftButtons() {
        cameraPane.toggleFlashButtonActivation(
            state: cameraPreviewViewController.isFlashSupported)
        cameraButtonsViewModel.isFlashOn = cameraPreviewViewController.isFlashOn
        cameraPane.setupFlashButton(state: cameraButtonsViewModel.isFlashOn)
        cameraPane.setupFlashButton(state: giniConfiguration.flashToggleEnabled)
        cameraButtonsViewModel.flashAction = { [weak self] isFlashOn in
            self?.cameraPreviewViewController.isFlashOn = isFlashOn
            self?.cameraPane.setupFlashButton(state: isFlashOn)
        }
        cameraPane.flashButton.actionButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.toggleFlash),
            for: .touchUpInside)
        cameraButtonsViewModel.importAction = { [weak self] in
            self?.showImportFileSheet()
        }

        cameraPane.fileUploadButton.actionButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.importPressed),
            for: .touchUpInside)
    }

    private lazy var cameraPreviewBottomContraint: NSLayoutConstraint =
            cameraPreviewViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            cameraPreviewViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            cameraPreviewViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraPreviewViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraPreviewBottomContraint
            ]
        )
    }

    fileprivate func didPick(_ document: GiniCaptureDocument) {
        if let delegate = delegate {
            delegate.camera(self, didCapture: document)
        } else {
            assertionFailure("The CameraViewControllerDelegate has not been assigned")
        }
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil)
    }

    /**
     Replaces the captured images stack content with new images.
     
     - parameter images: New images to be shown in the stack. (Last image will be shown on top)
     */
    public func replaceCapturedStackImages(with images: [UIImage]) {
        if giniConfiguration.multipageEnabled {
            cameraButtonsViewModel.images = images
        }
    }

    public func addValidationLoadingView() -> UIView {
        let loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurredView.alpha = 0
        blurredView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        loadingIndicator.startAnimating()
        blurredView.contentView.addSubview(loadingIndicator)
        self.view.addSubview(blurredView)
        blurredView.frame = self.view.bounds
        loadingIndicator.center = blurredView.center
        UIView.animate(withDuration: AnimationDuration.medium, animations: {
            blurredView.alpha = 1
        })
        return blurredView
    }
    // MARK: - Image capture

    private func previewCapturedImageView(with image: UIImage) -> UIImageView {
        let imageFrame = cameraPreviewViewController.view.frame
        let imageView = UIImageView(frame: imageFrame)
        imageView.center = cameraPreviewViewController.view.center
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: -2, height: 2)
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.3
        imageView.layer.shadowPath = UIBezierPath(rect: imageView.bounds).cgPath
        return imageView
    }

    // swiftlint:disable line_length
    private func crop(image: UIImage) -> UIImage {
        let standardImageAspectRatio: CGFloat = 0.75 // Standard aspect ratio of a 3/4 image
        let screenAspectRatio = self.cameraPreviewViewController.view.frame.height / self.cameraPreviewViewController.view.frame.width
        var scale: CGFloat
        var cameraPreviewRect: CGRect

        if image.size.width > image.size.height {
            // Landscape orientation

            // Calculate the scale based on the part of the image which is fully shown on the screen
            if screenAspectRatio > standardImageAspectRatio {
                // In this case the preview shows the full height of the camera preview
                scale = image.size.height / self.cameraPreviewViewController.view.frame.height
            } else {
                // In this case the preview shows the full width of the camera preview
                scale = image.size.width / self.cameraPreviewViewController.view.frame.width
            }
        } else {
            // Portrait image

            // Calculate the scale based on the part of the image which is fully shown on the screen
            if UIDevice.current.isIpad {
                if screenAspectRatio < standardImageAspectRatio {
                    // In this case the preview shows the full height of the camera preview
                    scale = image.size.height / self.cameraPreviewViewController.view.frame.height
                } else {
                    // In this case the preview shows the full width of the camera preview
                    scale = image.size.width / self.cameraPreviewViewController.view.frame.width
                }
            } else {
                scale = image.size.height / self.cameraPreviewViewController.view.frame.height
            }
        }

        // Calculate the rectangle for the displayed image on the full size captured image
        let widthDisplacement = (image.size.width - (self.cameraPreviewViewController.view.frame.width) * scale) / 2
        let heightDisplacement = (image.size.height - (self.cameraPreviewViewController.view.frame.height) * scale) / 2

        cameraPreviewRect = self.cameraPreviewViewController.view.frame.scaled(for: scale)
        cameraPreviewRect = CGRect(x: widthDisplacement, y: heightDisplacement, width: cameraPreviewRect.width, height: cameraPreviewRect.height)

        // First crop the full image to the image that is shown on the screen
        guard let cgImage = image.cgImage else { return image }
        guard let croppedCGImage = cgImage.cropping(to: cameraPreviewRect) else { return image }
        let displayedImage = UIImage(cgImage: croppedCGImage, scale: 1, orientation: .up)

        // Crop the displayed image to the A4 rect
        let a4FrameRect = self.cameraPreviewViewController.cameraFrameImageView.frame.scaled(for: scale)
        guard let cgDisplayedImage = displayedImage.cgImage else { return image }
        guard let croppedA4CGImage = cgDisplayedImage.cropping(to: a4FrameRect) else { return image }
        let finalImage = UIImage(cgImage: croppedA4CGImage, scale: 1, orientation: .up)
        return finalImage
    }
    // swiftlint:enable line_length
}

// MARK: - CameraPreviewViewControllerDelegate

extension Camera2ViewController: CameraPreviewViewControllerDelegate {

    func cameraDidSetUp(_ viewController: CameraPreviewViewController,
                        camera: CameraProtocol) {
        cameraPreviewViewController.cameraFrameImageView.isHidden = false
        cameraPane.toggleCaptureButtonActivation(state: true)
    }

    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetect qrCodeDocument: GiniQRCodeDocument) {
        if detectedQRCodeDocument != qrCodeDocument {
            detectedQRCodeDocument = qrCodeDocument
            showPopup(forQRDetected: qrCodeDocument) { [weak self] in
                guard let self = self else { return }
                self.didPick(qrCodeDocument)
            }
        }
    }

    func notAuthorized() {
        cameraPane.setupAuthorization(isHidden: true)
        cameraPreviewViewController.cameraFrameImageView.isHidden = true
    }
}
