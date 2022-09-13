//
//  Camera2ViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import UIKit

class Camera2ViewController: UIViewController, CameraScreen {
    
    /**
     The object that acts as the delegate of the camera view controller.
    */

    var opaqueView: UIView?
    var fileImportToolTipView: ToolTipView?
    var qrCodeToolTipView: ToolTipView?
    let giniConfiguration: GiniConfiguration

    fileprivate var detectedQRCodeDocument: GiniQRCodeDocument?
    fileprivate var currentQRCodePopup: QRCodeDetectedPopupView?
    var shouldShowQRCodeNext = false
    private var isFlashOn: Bool = false
    lazy var cameraPreviewViewController: CameraPreviewViewController = {
       let cameraPreviewViewController = CameraPreviewViewController()
       cameraPreviewViewController.delegate = self
       return cameraPreviewViewController
    }()
    public weak var delegate: CameraViewControllerDelegate?
    public weak var trackingDelegate: CameraScreenTrackingDelegate?
    
    @IBOutlet weak var cameraTitleLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var fileUploadButton: BottomLabelButton!
    @IBOutlet weak var flashButton: BottomLabelButton!
    @IBOutlet weak var thumbnailView: ThumbnailView!
    /**
     Designated initializer for the `CameraViewController` which allows
     to set the `GiniConfiguration for the camera screen`.
     All the interactions with this screen are handled by `CameraViewControllerDelegate`.
     
     - parameter giniConfiguration: `GiniConfiguration` instance.
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
    */
    public init(
        giniConfiguration: GiniConfiguration
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
        showTooltip()
        setupView()
        setupCamera()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle(to: giniConfiguration.statusBarStyle)
        if let tooltip = fileImportToolTipView, tooltip.isHidden == false {
        } else {
           toggleCaptureButtonActivation(state: true)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.cameraDidAppear(self)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.fileImportToolTipView?.arrangeViews()
        self.qrCodeToolTipView?.arrangeViews()
        self.opaqueView?.frame = cameraPreviewViewController.view.frame
    }
    
    func setupView() {
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.from(giniColor: giniConfiguration.cameraContainerViewBackgroundColor)
        addChild(cameraPreviewViewController)
        view.addSubview(cameraPreviewViewController.view)
        cameraPreviewViewController.didMove(toParent: self)
        view.sendSubviewToBack(cameraPreviewViewController.view)
        configureConstraints()
        cameraTitleLabel.text = NSLocalizedStringPreferredFormat(
            "ginicapture.camera.infoLabel",
            comment: "Info label")
        configureButtons()
    }
    
    func configureButtons() {
        thumbnailView.isHidden = true
        fileUploadButton.configureButton(image: UIImageNamedPreferred(named: "folder") ?? UIImage() , name: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.fileImportButtonLabel",
            comment: "Import photo"), giniconfiguration: giniConfiguration)
        flashButton.configureButton(image: UIImageNamedPreferred(named: "flashOff") ?? UIImage(), name: NSLocalizedStringPreferredFormat(
            "ginicapture.camera.flashButtonLabel",
            comment: "Flash button"), giniconfiguration: giniConfiguration)
        flashButton.iconView.image = UIImageNamedPreferred(named: "flashOn")
        flashButton.actionButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        fileUploadButton.actionButton.addTarget(self, action: #selector(uploadPressed), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(capturePressed(_:)), for: .touchUpInside)
        thumbnailView.thumbnailButton.addTarget(self, action: #selector(thumbnailPressed), for: .touchUpInside)
        
    }
    
    @objc func uploadPressed() {
        cameraButtons(didTapOn: .fileImport)
    }
    
    @objc func thumbnailPressed() {
        cameraButtons(didTapOn: .imagesStack)
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
    
    @objc func toggleFlash() {
        isFlashOn = !isFlashOn
        setupFlashButton(state: isFlashOn)
    }
    
    private func setupFlashButton(state:Bool) {
        if isFlashOn {
            flashButton.iconView.image = UIImageNamedPreferred(named: "flashOn")
        } else {
            flashButton.iconView.image = UIImageNamedPreferred(named: "flashOff")
        }
    }
    
    @objc func capturePressed(_ sender: AnyObject) {
        toggleCaptureButtonActivation(state: false)
        cameraButtons(didTapOn: .capture)
    }
    
    func toggleCaptureButtonActivation(state:Bool) {
        captureButton.isUserInteractionEnabled = state
        captureButton.isEnabled = state
    }
    
    fileprivate func didPick(_ document: GiniCaptureDocument) {
        if let delegate = delegate {
            delegate.camera(self, didCapture: document)
        } else {
            assertionFailure("The CameraViewControllerDelegate has not been assigned")
        }
    }
    
    fileprivate func showTooltip() {
        if giniConfiguration.fileImportSupportedTypes != .none {
            fileUploadButton.isHidden = false
            // If FileImportToolTip was shown and QRCodeToolTip not yet
            if !OnboardingContainerViewController.willBeShown {
                if ToolTipView.shouldShowFileImportToolTip {
                    showFileImportTip()
                } else {
                    showQrCodeTip()
                }
            }
        } else {
            fileUploadButton.isHidden = true
        }
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.fileImportToolTipView?.arrangeViews()
            self.qrCodeToolTipView?.arrangeViews()

        })
    }
    
    public func setupCamera() {
        cameraPreviewViewController.setupCamera()
    }
}

// MARK: - Toggle UI elements

extension Camera2ViewController {
    
    /**
     Show the capture button. Should be called when onboarding is dismissed.
     */
    public func showCaptureButton() {
        captureButton.alpha = 1
    }
    
    /**
     Hide the capture button. Should be called when onboarding is presented.
     */
    public func hideCaptureButton() {
        captureButton.alpha = 0
    }
    
    /**
     Show the camera overlay. Should be called when onboarding is dismissed.
     */
    public func showCameraOverlay() {
        cameraPreviewViewController.showCameraOverlay()
    }
    
    /**
     Hide the camera overlay. Should be called when onboarding is presented.
     */
    public func hideCameraOverlay() {
        cameraPreviewViewController.hideCameraOverlay()
    }
    
    /**
     Disable captureButton and flashToggleButton.
     */
    fileprivate func configureCameraButtonsForFileImportTip() {
        captureButton.isEnabled = false
        flashButton.isEnabled = false
    }
    
    /**
     Show the fileImportTip. Should be called when onboarding is dismissed.
     */
    public func showFileImportTip() {
        self.configureCameraButtonsForFileImportTip()
        createFileImportTip(giniConfiguration: giniConfiguration)
        self.fileImportToolTipView?.show {
            self.opaqueView?.alpha = 1
        }
        ToolTipView.shouldShowFileImportToolTip = false
    }
    
    /**
     Hide the fileImportTip. Should be called when onboarding is presented.
     */
    public func hideFileImportTip() {
        self.fileImportToolTipView?.alpha = 0
    }
    
    /**
     Disable all camera buttons except capture button.
     */
    fileprivate func configureCameraButtonsForQRCodeTip() {
        captureButton.isEnabled = true
        flashButton.isEnabled = true
        flashButton.isSelected = giniConfiguration.flashOnByDefault
        fileUploadButton.actionButton.isEnabled = false
        fileUploadButton.actionLabel.isEnabled = false
        fileUploadButton.actionButton.isUserInteractionEnabled = false
    }
    
    /**
     Show the QR code Tip. Should be called when fileImportTip is dismissed.
     */
    public func showQrCodeTip() {
        if ToolTipView.shouldShowQRCodeToolTip && giniConfiguration.qrCodeScanningEnabled {
            self.configureCameraButtonsForQRCodeTip()
            createQRCodeTip(giniConfiguration: giniConfiguration)
            self.qrCodeToolTipView?.show {
                self.opaqueView?.alpha = 1
            }
            ToolTipView.shouldShowQRCodeToolTip = false
            self.shouldShowQRCodeNext = false
        }
    }
    
    /**
     Hide the QR code Tip. Should be called when onboarding is presented.
     */
    public func hideQrCodeTip() {
        self.qrCodeToolTipView?.alpha = 0
    }
    
}

// MARK: - Image capture

extension Camera2ViewController {
    
    /**
     Used to animate the captured image, first shrinking it and then translating it to the captured images stack view.
     
     - parameter imageDocument: `GiniImageDocument` to be animated.
     - parameter completion: Completion block.
     
     */
    public func animateToControlsView(imageDocument: GiniImageDocument, completion: (() -> Void)? = nil) {
        guard let documentImage = imageDocument.previewImage else { return }
        let previewImageView = previewCapturedImageView(with: documentImage)
        view.addSubview(previewImageView)
        
        UIView.animate(withDuration: AnimationDuration.medium, animations: {
            previewImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { _ in
            UIView.animateKeyframes(withDuration: AnimationDuration.medium, delay: 0.6, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                    let thumbnailSize = self.thumbnailView.thumbnailImageView.bounds.size
                    let scaleRatioY = thumbnailSize.height / self.cameraPreviewViewController.view.frame.height
                    let scaleRatioX = thumbnailSize.width / self.cameraPreviewViewController.view.frame.width
                    
                    previewImageView.transform = CGAffineTransform(scaleX: scaleRatioX, y: scaleRatioY)
                    
                    previewImageView.frame.origin = self.thumbnailView.thumbnailImageView.convert(self.thumbnailView.thumbnailImageView.frame, to: self.view).origin
                     
                })
                if !self.thumbnailView.isHidden {
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 1, animations: {
                        previewImageView.alpha = 0
                    })
                }
            }, completion: { _ in
                previewImageView.removeFromSuperview()
                self.thumbnailView.addImageToStack(image: documentImage)
                completion?()
            })
        })
        if let tooltip = fileImportToolTipView, tooltip.isHidden == false {
        } else {
            toggleCaptureButtonActivation(state: true)
        }
    }
    
    /**
     Replaces the captured images stack content with new images.
     
     - parameter images: New images to be shown in the stack. (Last image will be shown on top)
     */
    public func replaceCapturedStackImages(with images: [UIImage]) {
        thumbnailView.replaceStackImages(with: images)
    }

    fileprivate func showPopup(forQRDetected qrDocument: GiniQRCodeDocument, didTapDone: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let newQRCodePopup = QRCodeDetectedPopupView(parent: self.view,
                                                         refView: self.cameraPreviewViewController.view,
                                                         document: qrDocument,
                                                         giniConfiguration: self.giniConfiguration)
            
            let didDismiss: () -> Void = { [weak self] in
                self?.detectedQRCodeDocument = nil
                self?.currentQRCodePopup = nil
            }
            
            if qrDocument.qrCodeFormat == nil {
                self.configurePopupViewForUnsupportedQR(newQRCodePopup, dismissCompletion: didDismiss)
            } else {
                newQRCodePopup.didTapDone = { [weak self] in
                    didTapDone()
                    self?.currentQRCodePopup?.hide(after: 0.0, completion: didDismiss)
                }
            }
            
            if self.currentQRCodePopup != nil {
                self.currentQRCodePopup?.hide { [weak self] in
                    self?.currentQRCodePopup = newQRCodePopup
                    self?.currentQRCodePopup?.show(didDismiss: didDismiss)
                }
            } else {
                self.currentQRCodePopup = newQRCodePopup
                self.currentQRCodePopup?.show(didDismiss: didDismiss)
            }
        }
    }
    
    fileprivate func configurePopupViewForUnsupportedQR(
        _ newQRCodePopup: QRCodeDetectedPopupView,
        dismissCompletion: @escaping () -> Void) {
        newQRCodePopup.backgroundColor = UIColor.from(giniColor:giniConfiguration.unsupportedQrCodePopupBackgroundColor)
        newQRCodePopup.qrText.textColor = UIColor.from(giniColor: giniConfiguration.unsupportedQrCodePopupTextColor)
        newQRCodePopup.qrText.text = .localized(resource: CameraStrings.unsupportedQrCodeDetectedPopupMessage)
        newQRCodePopup.proceedButton.setTitle("✕", for: .normal)
        newQRCodePopup.proceedButton.setTitleColor(giniConfiguration.unsupportedQrCodePopupButtonColor, for: .normal)
        newQRCodePopup.proceedButton.setTitleColor(giniConfiguration.unsupportedQrCodePopupButtonColor.withAlphaComponent(0.5), for: .highlighted)
        newQRCodePopup.didTapDone = { [weak self] in
            self?.currentQRCodePopup?.hide(after: 0.0, completion: dismissCompletion)
        }
    }
    
    private func cameraDidCapture(imageData: Data?, error: CameraError?) {
        guard let imageData = imageData,
            error == nil else {
            let errorMessage = error?.message ?? "Image data was nil"
            let errorLog = ErrorLog(description: "There was an error while capturing a picture: \(String(describing: errorMessage))",
                                    error: error)
            giniConfiguration.errorLogger.handleErrorLog(error: errorLog)
            assertionFailure("There was an error while capturing a picture")
            return
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let imageDocument = GiniImageDocument(data: imageData,
                                              imageSource: .camera,
                                              deviceOrientation: UIApplication.shared.statusBarOrientation)
        didPick(imageDocument)
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
        if let tooltip = fileImportToolTipView, tooltip.isHidden == false {
        } else {
            toggleCaptureButtonActivation(state: true)
        }
        flashButton.isHidden = !camera.isFlashSupported
    }
    
    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetect qrCodeDocument: GiniQRCodeDocument) {
        if let tooltip = qrCodeToolTipView, !tooltip.isHidden {
            qrCodeToolTipView?.dismiss()
        }
        if detectedQRCodeDocument != qrCodeDocument {
            detectedQRCodeDocument = qrCodeDocument
            showPopup(forQRDetected: qrCodeDocument) { [weak self] in
                guard let self = self else { return }
                self.didPick(qrCodeDocument)
            }
        }
    }
}

// MARK: - CameraButtonsViewControllerDelegate

extension Camera2ViewController {
    func cameraButtons(didTapOn button: CameraButtonsViewController.Button) {
        switch button {
        case let .flashToggle(isOn):
            cameraPreviewViewController.isFlashOn = isOn
        case .fileImport:
            if let tooltip = fileImportToolTipView, tooltip.isHidden == false {
                showImportFileSheet()
            } else {
                if let fileImportToolTipView = self.fileImportToolTipView, ToolTipView.shouldShowFileImportToolTip {
                    shouldShowQRCodeNext = true
                    fileImportToolTipView.dismiss(withCompletion: nil)
                    self.fileImportToolTipView = nil
                } else {
                    showImportFileSheet()
                }
            }
        case .capture:
            if let qrToolTip = qrCodeToolTipView, !qrToolTip.isHidden {
                qrCodeToolTipView?.dismiss(withCompletion: nil)
                qrCodeToolTipView = nil
            }
            trackingDelegate?.onCameraScreenEvent(event: Event(type: .takePicture))
            cameraPreviewViewController.captureImage { [weak self] data, error in
                guard let self = self else { return }
                self.cameraDidCapture(imageData: data, error: error)
                self.toggleCaptureButtonActivation(state: true)
            }

        case .imagesStack:
            delegate?.cameraDidTapMultipageReviewButton(self)
        }
    }
}

// MARK: - Document import

extension Camera2ViewController {
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
    
    @objc fileprivate func showImportFileSheet() {
        if let tooltip = fileImportToolTipView, !tooltip.isHidden {        fileImportToolTipView?.dismiss(withCompletion: nil)
        }
        
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
        alertViewController.popoverPresentationController?.sourceView = fileUploadButton
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func createFileImportTip(giniConfiguration: GiniConfiguration) {
        opaqueView = OpaqueViewFactory.create(with: giniConfiguration.toolTipOpaqueBackgroundStyle)
        opaqueView?.alpha = 0
        self.view.addSubview(opaqueView!)

        fileImportToolTipView = ToolTipView(text: .localized(resource: CameraStrings.fileImportTipLabel),
                                  giniConfiguration: giniConfiguration,
                                  referenceView: fileUploadButton,
                                  superView: self.view,
                                  position: UIDevice.current.isIpad ? .left : .above,
                                  distanceToRefView: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        fileImportToolTipView?.willDismiss = { [weak self] in
            guard let self = self else { return }
            self.opaqueView?.removeFromSuperview()
            self.fileImportToolTipView = nil
            if !ToolTipView.shouldShowFileImportToolTip && ToolTipView.shouldShowQRCodeToolTip && self.shouldShowQRCodeNext {
                self.configureCameraWhenTooltipDismissed()
                self.showQrCodeTip()
            } else {
                self.configureCameraWhenTooltipDismissed()
            }
        }
        fileImportToolTipView?.willDismissOnCloseButtonTap = { [weak self] in
            guard let self = self else { return }
            self.opaqueView?.removeFromSuperview()
            self.fileImportToolTipView = nil
            if !ToolTipView.shouldShowFileImportToolTip && ToolTipView.shouldShowQRCodeToolTip {
                self.configureCameraWhenTooltipDismissed()
                self.showQrCodeTip()
            } else {
                self.configureCameraWhenTooltipDismissed()
            }
        }
    }
    
    fileprivate func configureCameraWhenTooltipDismissed() {
        let isFlashOn = giniConfiguration.flashOnByDefault
        captureButton.isEnabled = true
        captureButton.isUserInteractionEnabled = true
        flashButton.isEnabled = true
        flashButton.isSelected = isFlashOn
        fileUploadButton.isEnabled = true
        fileUploadButton.isUserInteractionEnabled = true
    }
    
    fileprivate func createQRCodeTip(giniConfiguration: GiniConfiguration) {

        qrCodeToolTipView = ToolTipView(text: .localized(resource: CameraStrings.qrCodeTipLabel),
                                  giniConfiguration: giniConfiguration,
                                  referenceView: captureButton,
                                  superView: self.view,
                                  position: UIDevice.current.isIpad ? .left : .above,
                                  distanceToRefView: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        qrCodeToolTipView?.willDismiss = { [weak self] in
            guard let self = self else { return }
            self.configureCameraWhenTooltipDismissed()
        }
        
        qrCodeToolTipView?.willDismissOnCloseButtonTap = { [weak self] in
            guard let self = self else { return }
            self.configureCameraWhenTooltipDismissed()
        }
        
    }
    /**
     Handle tooltip dismiss on tap outside.
     */
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if  let fileImportTooltip = self.fileImportToolTipView, touch?.view != fileImportTooltip && !fileImportTooltip.isHidden  {
            fileImportToolTipView?.dismiss {
                if !ToolTipView.shouldShowFileImportToolTip && ToolTipView.shouldShowQRCodeToolTip {
                    self.showQrCodeTip()
                    self.fileImportToolTipView = nil
                }
            }
        } else if let qrTooltip = self.qrCodeToolTipView, touch?.view !=  qrTooltip && !qrTooltip.isHidden  {
            qrCodeToolTipView?.dismiss()
            qrCodeToolTipView = nil
        }
    }
}
