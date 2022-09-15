//
//  Camera2ViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

final class Camera2ViewController: UIViewController, CameraScreen {

    /**
     The object that acts as the delegate of the camera view controller.
    */
    var opaqueView: UIView?
    let giniConfiguration: GiniConfiguration
    var detectedQRCodeDocument: GiniQRCodeDocument?
    var currentQRCodePopup: QRCodeDetectedPopupView?
    var shouldShowQRCodeNext = false
    lazy var cameraPreviewViewController: CameraPreviewViewController = {
       let cameraPreviewViewController = CameraPreviewViewController()
       cameraPreviewViewController.delegate = self
       return cameraPreviewViewController
    }()
    public weak var delegate: CameraViewControllerDelegate?

    @IBOutlet weak var cameraPane: CameraPane!
    private var cameraButtonsViewModel = CameraButtonsViewModel()

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
        if UIDevice.current.isIphone {
            super.init(nibName: "CameraPhone", bundle: giniCaptureBundle())
        } else {
            super.init(nibName: "CameraiPad", bundle: giniCaptureBundle())
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showUploadButton()
        setupView()
        setupCamera()
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

    func setupView() {
        edgesForExtendedLayout = []
        view.backgroundColor = giniConfiguration.cameraContainerViewBackgroundColor.uiColor()
        addChild(cameraPreviewViewController)
        view.addSubview(cameraPreviewViewController.view)
        cameraPreviewViewController.didMove(toParent: self)
        view.sendSubviewToBack(cameraPreviewViewController.view)
        configureConstraints()
        if UIDevice.current.isIphone {
            cameraPane.cameraTitleLabel.text = NSLocalizedStringPreferredFormat(
                "ginicapture.camera.infoLabel",
                comment: "Info label")
        }
        cameraPane.configureView(giniConfiguration: giniConfiguration)
        configureButtons()
    }

    func configureButtons() {
        configureLeftButtons()
        cameraButtonsViewModel.captureAction = { [weak self] in
            self?.cameraPane.toggleCaptureButtonActivation(state: false)
            self?.cameraPreviewViewController.captureImage { [weak self] data, error in
                guard let self = self else { return }
                if let image = self.cameraButtonsViewModel.didCapture(
                    imageData: data,
                    error: error,
                    orientation: UIApplication.shared.statusBarOrientation,
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
                self?.delegate?.cameraDidTapMultipageReviewButton(strongSelf)
            }
        }
        cameraPane.thumbnailView.thumbnailButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.thumbnailPressed),
            for: .touchUpInside)
    }

    func showUploadButton() {
        if giniConfiguration.fileImportSupportedTypes != .none {
            cameraPane.fileUploadButton.isHidden = false
        } else {
            cameraPane.fileUploadButton.isHidden = true
        }
    }

    private func configureLeftButtons() {
        cameraButtonsViewModel.flashAction = { [weak self] isFlashOn in
            self?.cameraPreviewViewController.isFlashOn = isFlashOn
            self?.setupFlashButton(state: isFlashOn)
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

    func configureConstraints() {
        NSLayoutConstraint.activate([
            cameraPreviewViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            cameraPreviewViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraPreviewViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraPreviewViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ]
        )
    }

    private func setupFlashButton(state: Bool) {
        if state {
            cameraPane.flashButton.iconView.image = UIImageNamedPreferred(named: "flashOn")
        } else {
            cameraPane.flashButton.iconView.image = UIImageNamedPreferred(named: "flashOff")
        }
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
        cameraPane.thumbnailView.replaceStackImages(with: images)
    }

    func addValidationLoadingView() -> UIView {
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
}

// MARK: - Image capture

extension Camera2ViewController {

    /**
     Used to animate the captured image, first shrinking it and then translating it to the captured images stack view.
     
     - parameter imageDocument: `GiniImageDocument` to be animated.
     - parameter completion: Completion block.
     
     */
    public func animateToControlsView(imageDocument: GiniImageDocument, completion: (() -> Void)?) {
        guard let documentImage = imageDocument.previewImage else { return }
        let previewImageView = previewCapturedImageView(with: documentImage)
        view.addSubview(previewImageView)
        UIView.animate(withDuration: AnimationDuration.medium, animations: {
            previewImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { _ in
            UIView.animateKeyframes(withDuration: AnimationDuration.medium, delay: 0.6, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                    let thumbnailSize = self.cameraPane.thumbnailView.thumbnailImageView.bounds.size
                    let scaleRatioY = thumbnailSize.height / self.cameraPreviewViewController.view.frame.height
                    let scaleRatioX = thumbnailSize.width / self.cameraPreviewViewController.view.frame.width
                    previewImageView.transform = CGAffineTransform(scaleX: scaleRatioX, y: scaleRatioY)
                    let convertedFrame = self.cameraPane.thumbnailView.thumbnailImageView.convert(
                            self.cameraPane.thumbnailView.thumbnailImageView.frame,
                            to: self.view)
                    previewImageView.frame.origin = convertedFrame.origin
                })
                if self.cameraPane.thumbnailView.isHidden == false {
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 1, animations: {
                        previewImageView.alpha = 0
                    })
                }
            }, completion: { _ in
                previewImageView.removeFromSuperview()
                self.cameraPane.thumbnailView.addImageToStack(image: documentImage)
                completion?()
            })
        })
        cameraPane.toggleCaptureButtonActivation(state: true)
    }

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

}

// MARK: - CameraPreviewViewControllerDelegate

extension Camera2ViewController: CameraPreviewViewControllerDelegate {

    func cameraDidSetUp(_ viewController: CameraPreviewViewController,
                        camera: CameraProtocol) {
        cameraPane.toggleCaptureButtonActivation(state: true)
        cameraPane.flashButton.isHidden = !camera.isFlashSupported
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

}

// MARK: - Document import

extension Camera2ViewController {

    @objc fileprivate func showImportFileSheet() {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var alertViewControllerMessage: String = .localized(resource: CameraStrings.popupTitleImportPDF)
        if giniConfiguration.fileImportSupportedTypes == .pdf_and_images {
            alertViewController.addAction(UIAlertAction(title: .localized(resource: CameraStrings.popupOptionPhotos),
                                                        style: .default) { [unowned self] _ in
                self.delegate?.camera(self, didSelect: .gallery)
            })
            alertViewControllerMessage = .localized(resource: CameraStrings.popupTitleImportPDForPhotos)
        }

        alertViewController.addAction(UIAlertAction(title: .localized(resource: CameraStrings.popupOptionFiles),
                                                    style: .default) { [unowned self] _ in
            self.delegate?.camera(self, didSelect: .explorer)
        })
        alertViewController.addAction(UIAlertAction(title: .localized(resource: CameraStrings.popupCancel),
                                                    style: .cancel, handler: nil))
        alertViewController.message = alertViewControllerMessage
        alertViewController.popoverPresentationController?.sourceView = cameraPane.fileUploadButton
        self.present(alertViewController, animated: true, completion: nil)
    }
}
