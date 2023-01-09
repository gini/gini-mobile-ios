//
//  Camera2ViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

// swiftlint:disable type_body_length
public final class Camera2ViewController: UIViewController, CameraScreen {

    /**
     The object that acts as the delegate of the camera view controller.
    */
    let giniConfiguration: GiniConfiguration
    var detectedQRCodeDocument: GiniQRCodeDocument?
    private var shouldShowQRCodeNext = false
    lazy var cameraPreviewViewController: CameraPreviewViewController = {
       let cameraPreviewViewController = CameraPreviewViewController()
       cameraPreviewViewController.delegate = self
       return cameraPreviewViewController
    }()

    private lazy var qrCodeOverLay: QRCodeOverlay = {
        let view = QRCodeOverlay()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()

    private var resetTask: DispatchWorkItem?
    private var hideTask: DispatchWorkItem?
    private var validQRCodeProcessing: Bool = false
    public weak var delegate: CameraViewControllerDelegate?

    private lazy var qrCodeScanningOnlyEnabled: Bool = {
        return giniConfiguration.qrCodeScanningEnabled && giniConfiguration.onlyQRCodeScanningEnabled
    }()

    @IBOutlet weak var cameraPane: CameraPane!
    private let cameraButtonsViewModel: CameraButtonsViewModel
    private var navigationBarBottomAdapter: CameraBottomNavigationBarAdapter?
    private var bottomNavigationBar: UIView?

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
        setupView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(to: giniConfiguration.statusBarStyle)
        cameraPane.toggleCaptureButtonActivation(state: true)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validQRCodeProcessing = false
        delegate?.cameraDidAppear(self)
    }

    fileprivate func configureTitle() {
        if UIDevice.current.isIphone {
            self.title = NSLocalizedStringPreferredFormat(
                "ginicapture.navigationbar.camera.title",
                comment: "Info label")
        } else {
            self.title = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.infoLabel",
                comment: "Info label")
        }
    }

    private func setupView() {
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.GiniCapture.dark1
        cameraPreviewViewController.previewView.alpha = 0
        addChild(cameraPreviewViewController)
        view.addSubview(cameraPreviewViewController.view)
        cameraPreviewViewController.didMove(toParent: self)
        view.sendSubviewToBack(cameraPreviewViewController.view)
        view.addSubview(qrCodeOverLay)
        configureConstraints()
        configureTitle()

        if qrCodeScanningOnlyEnabled {
            cameraPane.alpha = 0
            if giniConfiguration.bottomNavigationBarEnabled {
                configureCustomTopNavigationBar(containsImage: false)
            }
        } else {
            configureCameraPaneButtons()
            configureBottomNavigationBar()
        }
    }

    private func configureCustomTopNavigationBar(containsImage: Bool) {
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        if !containsImage {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: NSLocalizedStringPreferredFormat(
                    "ginicapture.camera.popupCancel",
                    comment: "Cancel button"),
                style: .plain,
                target: cameraButtonsViewModel,
                action: #selector(cameraButtonsViewModel.cancelPressed))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    private func updateCustomNavigationBars(containsImage: Bool) {
        guard let bottomNavigationBar = bottomNavigationBar else {
            return
        }
        configureCustomTopNavigationBar(containsImage: containsImage)
        if containsImage {
            navigationBarBottomAdapter?.showButtons(
                navigationBar: bottomNavigationBar,
                navigationButtons: [.help, .back])
        } else {
            navigationBarBottomAdapter?.showButtons(
                navigationBar: bottomNavigationBar,
                navigationButtons: [.help])
        }
    }

    private func configureBottomNavigationBar() {
        if giniConfiguration.bottomNavigationBarEnabled {
            if let bottomBarAdapter = giniConfiguration.cameraNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBarAdapter
            } else {
                navigationBarBottomAdapter = DefaultCameraBottomNavigationBarAdapter()
            }
            navigationBarBottomAdapter?.setHelpButtonClickedActionCallback { [weak self] in
                self?.cameraButtonsViewModel.helpAction?()
            }
            navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
                self?.cameraButtonsViewModel.backButtonAction?()
            }

            if let bar =
                navigationBarBottomAdapter?.injectedView() {
                bottomNavigationBar = bar
                view.addSubview(bar)
                layoutBottomNavigationBar(bar)
            }
            updateCustomNavigationBars(
                containsImage: cameraButtonsViewModel.images.count > 0)
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

    private func configureCameraPaneButtons() {
        cameraPane.setupAuthorization(isHidden: false)
        configureLeftButtons()
        cameraButtonsViewModel.captureAction = { [weak self] in
            self?.cameraPane.toggleCaptureButtonActivation(state: false)
            self?.cameraPreviewViewController.captureImage { [weak self] data, error in
                guard let self = self else { return }

                var processedImageData = data
                if let imageData = data, let image = UIImage(data: imageData)?.fixOrientation() {
                    let croppedImage = self.crop(image: image)
                    processedImageData = croppedImage.jpegData(compressionQuality: 1)

                    #if targetEnvironment(simulator)
                    processedImageData = imageData
                    #endif
                }

                if let image = self.cameraButtonsViewModel.didCapture(imageData: data,
                                                                      processedImageData: processedImageData,
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
            if self?.giniConfiguration.bottomNavigationBarEnabled == true {
                self?.updateCustomNavigationBars(containsImage: images.last != nil)
            }
        }
        cameraButtonsViewModel.imagesUpdated?(cameraButtonsViewModel.images)
        cameraPane.thumbnailView.thumbnailButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.thumbnailPressed),
            for: .touchUpInside)
    }
    // swiftlint:enable body_length

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        qrCodeOverLay.viewWillDisappear()
    }

    private func configureUploadButton() {
        if giniConfiguration.fileImportSupportedTypes != .none {
            cameraPane.fileUploadButton.isHidden = false
            cameraButtonsViewModel.importAction = { [weak self] in
                self?.showImportFileSheet()
            }
            cameraPane.fileUploadButton.actionButton.addTarget(
                cameraButtonsViewModel,
                action: #selector(cameraButtonsViewModel.importPressed),
                for: .touchUpInside)
        } else {
            cameraPane.fileUploadButton.isHidden = true
        }
    }

    private func configureFlashButton() {
        cameraPane.toggleFlashButtonActivation(
            state: cameraPreviewViewController.isFlashSupported)
        cameraButtonsViewModel.isFlashOn = cameraPreviewViewController.isFlashOn
        cameraPane.setupFlashButton(state: cameraButtonsViewModel.isFlashOn)
        cameraButtonsViewModel.flashAction = { [weak self] isFlashOn in
            self?.cameraPreviewViewController.isFlashOn = isFlashOn
            self?.cameraPane.setupFlashButton(state: isFlashOn)
        }
        cameraPane.flashButton.actionButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.toggleFlash),
            for: .touchUpInside)
    }

    private func configureLeftButtons() {
        configureUploadButton()
        configureFlashButton()
    }

    private lazy var cameraPreviewBottomContraint: NSLayoutConstraint =
            cameraPreviewViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)

    private func configureConstraints() {
        if qrCodeScanningOnlyEnabled {
            qrCodeOverLay.layoutViews(centeringBy: cameraPreviewViewController.qrCodeFrameView)
        } else {
            qrCodeOverLay.layoutViews(centeringBy: cameraPreviewViewController.cameraFrameView)
        }

        NSLayoutConstraint.activate([
            qrCodeOverLay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrCodeOverLay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qrCodeOverLay.topAnchor.constraint(equalTo: view.topAnchor),
            qrCodeOverLay.centerXAnchor.constraint(equalTo: view.centerXAnchor),

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

    private func showQRCodeFeedback(for document: GiniQRCodeDocument, isValid: Bool) {
        guard !validQRCodeProcessing else { return }
        guard detectedQRCodeDocument != document else { return }

        hideTask?.cancel()
        resetTask?.cancel()
        detectedQRCodeDocument = document

        hideTask = DispatchWorkItem(block: {
            self.resetQRCodeScanning(isValid: isValid)

            if let QRDocument = self.detectedQRCodeDocument {
                if isValid {
                    self.didPick(QRDocument)
                }
            }
        })

        if isValid {
            showValidQRCodeFeedback()
        } else {
            showInvalidQRCodeFeedback()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: hideTask!)
    }

    private func showValidQRCodeFeedback() {
        validQRCodeProcessing = true
        cameraPane.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.qrCodeOverLay.isHidden = false
            self.cameraPreviewViewController.changeFrameColor(to: .GiniCapture.success2)
        }

        qrCodeOverLay.configureQrCodeOverlay(withCorrectQrCode: true)
    }

    private func showInvalidQRCodeFeedback() {
        qrCodeOverLay.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.qrCodeOverLay.isHidden = false
            self.cameraPreviewViewController.changeFrameColor(to: .GiniCapture.warning3)
        }

        qrCodeOverLay.configureQrCodeOverlay(withCorrectQrCode: false)
    }

    private func resetQRCodeScanning(isValid: Bool) {
        resetTask = DispatchWorkItem(block: {
            self.detectedQRCodeDocument = nil
        })

        if isValid {
            cameraPreviewViewController.cameraFrameView.isHidden = true
            qrCodeOverLay.showAnimation()
        } else {
            UIView.animate(withDuration: 0.3) {
                self.cameraPreviewViewController.changeFrameColor(to: .GiniCapture.light1)
                self.qrCodeOverLay.isHidden = true
                self.cameraPane.isUserInteractionEnabled = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: resetTask!)
        }
    }
}

// MARK: - Image Cropping

extension Camera2ViewController {
    // swiftlint:disable line_length
    private func crop(image: UIImage) -> UIImage {
        let standardImageAspectRatio: CGFloat = 0.75 // Standard aspect ratio of a 3/4 image
        let screenAspectRatio = self.cameraPreviewViewController.view.frame.height / self.cameraPreviewViewController.view.frame.width
        var scale: CGFloat

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

        // The frame of the A4 rect
        let a4FrameRect = self.cameraPreviewViewController.cameraFrameView.frame.scaled(for: scale)

        // The origin of the cropping rect compared to the whole image
        let cropRectX = widthDisplacement + a4FrameRect.origin.x
        let cropRectY = heightDisplacement + a4FrameRect.origin.y

        // The A4 rect position and size on the whole image
        let cropRect = CGRect(x: cropRectX, y: cropRectY, width: a4FrameRect.width, height: a4FrameRect.height)

        // Scaling up the rectangle 15%
        let scaledSize = CGSize(width: cropRect.width * 1.15, height: cropRect.height * 1.15)

        let scaledOriginX = cropRectX - cropRect.width * 0.075
        let scaledOriginY = cropRectY - cropRect.height * 0.075

        var scaledRect = CGRect(x: scaledOriginX, y: scaledOriginY, width: scaledSize.width, height: scaledSize.height)

        if scaledRect.origin.x >= 0 && scaledRect.origin.y >= 0 {
            // The area to be cropped is inside of the area of the image
            return cut(image: image, to: scaledRect)
        } else {
            // The area to be cropped is outside of the area of the image

            // If the area is bigger than the image, reset the origin and subtract the extra width/height that is not present
            if scaledOriginX < 0 {
                scaledRect.size.width += scaledRect.origin.x
                scaledRect.origin.x = 0
            }

            if scaledOriginY < 0 {
                scaledRect.size.height += scaledRect.origin.y
                scaledRect.origin.y = 0
            }

            return cut(image: image, to: scaledRect)
        }
    }
    // swiftlint:enable line_length

    private func cut(image: UIImage, to rect: CGRect) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        guard let croppedImage = cgImage.cropping(to: rect) else { return image }
        let finalImage = UIImage(cgImage: croppedImage, scale: 1, orientation: .up)

        return finalImage
    }
}

// MARK: - CameraPreviewViewControllerDelegate

extension Camera2ViewController: CameraPreviewViewControllerDelegate {

    func cameraDidSetUp(_ viewController: CameraPreviewViewController,
                        camera: CameraProtocol) {
        if !qrCodeScanningOnlyEnabled {
            cameraPreviewViewController.cameraFrameView.isHidden = false
            cameraPane.toggleCaptureButtonActivation(state: true)
        }

        cameraPreviewViewController.updatePreviewViewOrientation()
        UIView.animate(withDuration: 1.0) {
            self.cameraPane.setupAuthorization(isHidden: false)
            self.cameraPreviewViewController.previewView.alpha = 1
        }
    }

    func cameraPreview(
        _ viewController: CameraPreviewViewController,
        didDetectInvalid qrCodeDocument: GiniQRCodeDocument) {
            showQRCodeFeedback(for: qrCodeDocument, isValid: false)
    }

    func cameraPreview(
        _ viewController: CameraPreviewViewController,
        didDetect qrCodeDocument: GiniQRCodeDocument) {
            showQRCodeFeedback(for: qrCodeDocument, isValid: true)
    }

    func notAuthorized() {
        cameraPane.setupAuthorization(isHidden: true)
        cameraPreviewViewController.cameraFrameView.isHidden = true
    }
}
