//
//  CameraViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//  Copyright © 2022 Gini GmbH. All rights reserved.
//

import AVFoundation
import UIKit

// swiftlint:disable type_body_length
final class CameraViewController: UIViewController {
    /**
     The object that acts as the delegate of the camera view controller.
     */
    let giniConfiguration: GiniConfiguration
    var detectedQRCodeDocument: GiniQRCodeDocument?
    var cameraNeedsInitializing: Bool { !cameraPreviewViewController.hasInitialized }
    var shouldShowHelp: Bool { isPresentedOnScreen && !validQRCodeProcessing }
    var topNavBarAnchor: NSLayoutYAxisAnchor? { bottomNavigationBar?.topAnchor }

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

    private lazy var ibanDetectionOverLay: IBANDetectionOverlay = {
        let view = IBANDetectionOverlay()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var resetQRCodeTask: DispatchWorkItem?
    private var hideQRCodeTask: DispatchWorkItem?
    private var validQRCodeProcessing: Bool = false
    private var isPresentedOnScreen = false

    private var isValidIBANDetected: Bool = false
    // Analytics
    private var invalidQRCodeOverlayFirstAppearance: Bool = true
    private var ibanOverlayFirstAppearance: Bool = true

    weak var delegate: CameraViewControllerDelegate?

    private lazy var qrCodeScanningOnlyEnabled: Bool = {
        return giniConfiguration.qrCodeScanningEnabled && giniConfiguration.onlyQRCodeScanningEnabled
    }()

    @IBOutlet var cameraPaneHorizontalBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraPaneHorizontal: CameraPane!
    @IBOutlet weak var cameraPane: CameraPane!
    private let cameraButtonsViewModel: CameraButtonsViewModel
    private var navigationBarBottomAdapter: CameraBottomNavigationBarAdapter?
    private var bottomNavigationBar: UIView?
    private let cameraLensSwitcherView: CameraLensSwitcherView

    @IBOutlet weak var iPadBottomPaneConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonsConstraints: NSLayoutConstraint!
    @IBOutlet weak var bottomPaneConstraint: NSLayoutConstraint!
    /**
     Designated initializer for the `CameraViewController` which allows
     to set the `GiniConfiguration for the camera screen`.
     All the interactions with this screen are handled by `CameraViewControllerDelegate`.
     
     - parameter giniConfiguration: `GiniConfiguration` instance.
     
     - returns: A view controller instance allowing the user to take a picture or pick a document.
     */
    public init(giniConfiguration: GiniConfiguration,
                viewModel: CameraButtonsViewModel) {
        self.giniConfiguration = giniConfiguration
        self.cameraButtonsViewModel = viewModel

        let availableLenses = CameraViewController.checkAvailableLenses()
        self.cameraLensSwitcherView = CameraLensSwitcherView(availableLenses: availableLenses)
        self.cameraLensSwitcherView.isHidden = true

        if UIDevice.current.isIphone {
            super.init(nibName: "CameraPhone", bundle: giniCaptureBundle())
        } else {
            super.init(nibName: "CameraiPad", bundle: giniCaptureBundle())
        }

        self.cameraLensSwitcherView.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(configureCameraPanesBasedOnOrientation),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return giniConfiguration.statusBarStyle
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraPane.toggleCaptureButtonActivation(state: true)
        cameraPaneHorizontal?.toggleCaptureButtonActivation(state: true)
        cameraPaneHorizontal?.setupTitlesHidden(isHidden: giniConfiguration.bottomNavigationBarEnabled)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPresentedOnScreen = true
        validQRCodeProcessing = false
        delegate?.cameraDidAppear(self)

        // this event should be sent every time when the user sees this screen, including
        // when coming back from Help
        GiniAnalyticsManager.trackScreenShown(screenName: .camera)
    }

    fileprivate func configureTitle() {
        if UIDevice.current.isIphone {
            if giniConfiguration.onlyQRCodeScanningEnabled {
                title = NSLocalizedStringPreferredFormat("ginicapture.camera.infoLabel.only.qr",
                                                         comment: "Info label")
            } else {
                self.title = NSLocalizedStringPreferredFormat("ginicapture.navigationbar.camera.title",
                                                              comment: "Info label")
            }
        } else {
            var title: String?

            if !giniConfiguration.qrCodeScanningEnabled {
                title = NSLocalizedStringPreferredFormat("ginicapture.camera.infoLabel.only.invoice",
                                                         comment: "Info label")
            } else {
                if giniConfiguration.onlyQRCodeScanningEnabled {
                    title = NSLocalizedStringPreferredFormat("ginicapture.camera.infoLabel.only.qr",
                                                             comment: "Info label")
                } else {
                    title = NSLocalizedStringPreferredFormat("ginicapture.camera.infoLabel.invoice.and.qr",
                                                             comment: "Info label")
                }
            }
            self.title = title
        }
    }

    @objc private func configureCameraPanesBasedOnOrientation() {
        if !UIDevice.current.isIpad, currentInterfaceOrientation.isLandscape {
            if !cameraPane.isHidden {
                cameraPane.setupAuthorization(isHidden: true)
                cameraPaneHorizontal.setupAuthorization(isHidden: false)
            }
        } else {
            if !UIDevice.current.isIpad, !cameraPaneHorizontal.isHidden {
                cameraPane.setupAuthorization(isHidden: false)
                cameraPaneHorizontal.setupAuthorization(isHidden: true)
            }
        }
    }

    private func setupView() {
        edgesForExtendedLayout = []
        view.backgroundColor = UIColor.GiniCapture.dark1
        cameraPreviewViewController.previewView.alpha = 0

        add(asChildViewController: cameraPreviewViewController, sendToBackIfNeeded: true)

        view.addSubview(qrCodeOverLay)
        view.addSubview(ibanDetectionOverLay)

        cameraLensSwitcherView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraLensSwitcherView)

        configureConstraints()
        configureTitle()

        if qrCodeScanningOnlyEnabled {
            cameraPane.alpha = 0
            cameraPaneHorizontal?.alpha = 0
            if giniConfiguration.bottomNavigationBarEnabled {
                configureCustomTopNavigationBar(containsImage: false)
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        } else {
            configureCameraPaneButtons()
            configureBottomNavigationBar()
        }
    }

    private static func checkAvailableLenses() -> [CameraLensesAvailable] {
        var discoverySession: AVCaptureDevice.DiscoverySession
        if #available(iOS 13.0, *) {
            discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera,
                                                                              .builtInWideAngleCamera,
                                                                              .builtInTelephotoCamera],
                                                                mediaType: .video, position: .back)
        } else {
            discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,
                                                                              .builtInTelephotoCamera],
                                                                mediaType: .video, position: .back)
        }

        var availableLenses: [CameraLensesAvailable] = []

        let rawDeviceTypes = discoverySession.devices.map { $0.deviceType.rawValue }

        if rawDeviceTypes.contains("AVCaptureDeviceTypeBuiltInUltraWideCamera") {
            availableLenses.append(.ultraWide)
        }

        if rawDeviceTypes.contains("AVCaptureDeviceTypeBuiltInWideAngleCamera") {
            availableLenses.append(.wide)
        }

        if rawDeviceTypes.contains("AVCaptureDeviceTypeBuiltInTelephotoCamera") {
            availableLenses.append(.tele)
        }

        return availableLenses
    }

    private func configureCustomTopNavigationBar(containsImage: Bool) {
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        if !containsImage {
            let cancelBarButton = GiniBarButton(ofType: .cancel)
            cancelBarButton.addAction(cameraButtonsViewModel, #selector(cameraButtonsViewModel.cancelPressed))
            navigationItem.rightBarButtonItem = cancelBarButton.barButton
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
            view.removeConstraints([cameraPreviewBottomContraint, iPadBottomPaneConstraint])
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navigationBar)
            NSLayoutConstraint.activate([
                navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationBar.heightAnchor.constraint(equalToConstant: navigationBar.frame.height),
                cameraPane.bottomAnchor.constraint(equalTo: navigationBar.topAnchor),
                cameraPreviewViewController.view.bottomAnchor.constraint(equalTo: navigationBar.topAnchor)
            ])
        } else {
            view.removeConstraints([bottomPaneConstraint, bottomButtonsConstraints])
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navigationBar)
            cameraPaneHorizontalBottomConstraint.constant = 62
            NSLayoutConstraint.activate([
                navigationBar.topAnchor.constraint(equalTo: cameraPane.bottomAnchor),
                navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                cameraPane.leftButtonsStack.bottomAnchor.constraint(equalTo: cameraPane.bottomAnchor)
            ])
        }
        view.bringSubviewToFront(navigationBar)
        view.layoutSubviews()
    }

    private func configureCameraPaneButtons() {
        cameraPane.setupAuthorization(isHidden: !currentInterfaceOrientation.isPortrait)
        cameraPaneHorizontal?.setupAuthorization(isHidden: !(UIDevice.current.isIphone && currentInterfaceOrientation.isLandscape))
        configureLeftButtons()
        cameraButtonsViewModel.captureAction = { [weak self] in
            self?.sendGiniAnalyticsEventCapture()
            self?.cameraPane.toggleCaptureButtonActivation(state: false)
            self?.cameraPaneHorizontal?.toggleCaptureButtonActivation(state: false)
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
                                                                      orientation: UIWindow.orientation,
                                                                      giniConfiguration: self.giniConfiguration) {

                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    self.didPick(image)
                }
                self.cameraPane.toggleCaptureButtonActivation(state: true)
                self.cameraPaneHorizontal?.toggleCaptureButtonActivation(state: true)
            }
        }

        cameraPane.captureButton.addTarget(cameraButtonsViewModel,
                                           action: #selector(cameraButtonsViewModel.capturePressed),
                                           for: .touchUpInside)
        cameraPaneHorizontal?.captureButton.addTarget(cameraButtonsViewModel,
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
                self?.cameraPaneHorizontal?.thumbnailView.updateStackStatus(to: .filled(count: images.count, lastImage: lastImage))
            } else {
                self?.cameraPane.thumbnailView.updateStackStatus(to: ThumbnailView.State.empty)
                self?.cameraPaneHorizontal?.thumbnailView.updateStackStatus(to: ThumbnailView.State.empty)
            }
            if self?.giniConfiguration.bottomNavigationBarEnabled == true {
                self?.updateCustomNavigationBars(containsImage: images.last != nil)
            }
        }
        cameraButtonsViewModel.imagesUpdated?(cameraButtonsViewModel.images)
        cameraPane.thumbnailView.thumbnailButton.addTarget(cameraButtonsViewModel,
                                                           action: #selector(cameraButtonsViewModel.thumbnailPressed),
                                                           for: .touchUpInside)
        cameraPaneHorizontal?.thumbnailView.thumbnailButton.addTarget(cameraButtonsViewModel,
                                                           action: #selector(cameraButtonsViewModel.thumbnailPressed),
                                                           for: .touchUpInside)
    }

    private func sendGiniAnalyticsEventCapture() {
        let eventProperties = [GiniAnalyticsProperty(key: .ibanDetectionLayerVisible,
                                                     value: !ibanDetectionOverLay.isHidden)]

        GiniAnalyticsManager.track(event: .captureTapped,
                                   screenName: .camera,
                                   properties: eventProperties)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isPresentedOnScreen = false

        qrCodeOverLay.viewWillDisappear()
        ibanDetectionOverLay.viewWillDisappear()
    }

    private func configureUploadButton() {
        if giniConfiguration.fileImportSupportedTypes != .none {
            cameraPane.fileUploadButton.isHidden = false
            cameraPaneHorizontal?.fileUploadButton.isHidden = false
            cameraButtonsViewModel.importAction = { [weak self] in
                self?.showImportFileSheet()
            }
            cameraPane.fileUploadButton.actionButton.addTarget(
                cameraButtonsViewModel,
                action: #selector(cameraButtonsViewModel.importPressed),
                for: .touchUpInside)
            cameraPaneHorizontal?.fileUploadButton.actionButton.addTarget(
                cameraButtonsViewModel,
                action: #selector(cameraButtonsViewModel.importPressed),
                for: .touchUpInside)
        } else {
            cameraPane.fileUploadButton.isHidden = true
            cameraPaneHorizontal?.fileUploadButton.isHidden = true
        }
    }

    private func configureFlashButton() {
        cameraPane.toggleFlashButtonActivation(
            state: cameraPreviewViewController.isFlashSupported)
        cameraPaneHorizontal?.toggleFlashButtonActivation(
            state: cameraPreviewViewController.isFlashSupported)
        cameraButtonsViewModel.isFlashOn = cameraPreviewViewController.isFlashOn
        cameraPane.setupFlashButton(state: cameraButtonsViewModel.isFlashOn)
        cameraPaneHorizontal?.setupFlashButton(state: cameraButtonsViewModel.isFlashOn)
        cameraButtonsViewModel.flashAction = { [weak self] isFlashOn in
            self?.cameraPreviewViewController.isFlashOn = isFlashOn
            self?.cameraPane.setupFlashButton(state: isFlashOn)
            self?.cameraPaneHorizontal?.setupFlashButton(state: isFlashOn)
        }
        cameraPane.flashButton.actionButton.addTarget(
            cameraButtonsViewModel,
            action: #selector(cameraButtonsViewModel.toggleFlash),
            for: .touchUpInside)
        cameraPaneHorizontal?.flashButton.actionButton.addTarget(
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
            qrCodeOverLay.layoutViews(centeringBy: cameraPreviewViewController.qrCodeFrameView,
                                      on: cameraPreviewViewController)
        } else {
            qrCodeOverLay.layoutViews(centeringBy: cameraPreviewViewController.cameraFrameView,
                                      on: cameraPreviewViewController)
        }

        ibanDetectionOverLay.layoutViews(centeringBy: cameraPreviewViewController.cameraFrameView,
                                         on: cameraPreviewViewController)

        NSLayoutConstraint.activate([
            qrCodeOverLay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrCodeOverLay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qrCodeOverLay.topAnchor.constraint(equalTo: view.topAnchor),
            qrCodeOverLay.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            ibanDetectionOverLay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ibanDetectionOverLay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ibanDetectionOverLay.topAnchor.constraint(equalTo: view.topAnchor),

            cameraPreviewViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            cameraPreviewViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraPreviewViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraPreviewBottomContraint]
        )

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                cameraLensSwitcherView.trailingAnchor.constraint(equalTo: cameraPane.leadingAnchor,
                                                                 constant: -Constants.switcherPadding),
                cameraLensSwitcherView.centerYAnchor.constraint(equalTo: cameraPane.captureButton.centerYAnchor),
                cameraLensSwitcherView.widthAnchor.constraint(greaterThanOrEqualToConstant:
                                                                Constants.tableSwitcherSize.width),
                cameraLensSwitcherView.heightAnchor.constraint(greaterThanOrEqualToConstant:
                                                                Constants.tableSwitcherSize.height)
            ])
        } else {
            NSLayoutConstraint.activate([
                cameraLensSwitcherView.bottomAnchor.constraint(equalTo: cameraPane.topAnchor,
                                                               constant: -Constants.switcherPadding),
                cameraLensSwitcherView.leadingAnchor.constraint(greaterThanOrEqualTo: cameraPane.leadingAnchor),
                cameraLensSwitcherView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                cameraLensSwitcherView.widthAnchor.constraint(greaterThanOrEqualToConstant:
                                                                Constants.phoneSwitcherSize.width),
                cameraLensSwitcherView.heightAnchor.constraint(greaterThanOrEqualToConstant:
                                                                Constants.phoneSwitcherSize.height)
            ])
        }
    }

    fileprivate func didPick(_ document: GiniCaptureDocument) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        delegate?.camera(self, didCapture: document)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil)
    }

    /**
     Replaces the captured images stack content with new images.
     
     - parameter images: New images to be shown in the stack. (Last image will be shown on top)
     */
    func replaceCapturedStackImages(with images: [UIImage]) {
        if giniConfiguration.multipageEnabled {
            cameraButtonsViewModel.images = images
        }
    }

    func addValidationLoadingView() -> UIView {
        let loadingIndicator = UIActivityIndicatorView()
        loadingIndicator.applyLargeStyle()
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

    // MARK: - IBANs Detection
    private func showIBANFeedback(_ IBANs: [String]) {
        isValidIBANDetected = !IBANs.isEmpty
        guard isValidIBANDetected else {
            hideIBANOverlay()
            return
        }

        if !validQRCodeProcessing {
            if !qrCodeOverLay.isHidden {
                resetQRCodeScanning(isValid: false)
            }
            showIBANOverlay(with: IBANs)
        }
    }

    private func showIBANOverlay(with IBANs: [String]) {
        UIView.animate(withDuration: 0.3) {
            self.ibanDetectionOverLay.isHidden = false
            self.cameraPreviewViewController.changeCameraFrameColor(to: .GiniCapture.success2)
        }

        sendGiniAnalyticsEventIBANDetection()
        ibanDetectionOverLay.configureOverlay(hidden: false)
        ibanDetectionOverLay.setupView(with: IBANs)
    }

    private func sendGiniAnalyticsEventIBANDetection () {
        guard ibanOverlayFirstAppearance else { return }
        ibanOverlayFirstAppearance = false
    }

    private func hideIBANOverlay() {
        guard !ibanDetectionOverLay.isHidden else { return }
        UIView.animate(withDuration: 0.3) {
            self.ibanDetectionOverLay.isHidden = true
            if self.qrCodeOverLay.isHidden {
                self.cameraPreviewViewController.changeCameraFrameColor(to: .GiniCapture.light1)
            }
        }
        ibanDetectionOverLay.configureOverlay(hidden: true)
    }

    // MARK: - QR Detection

    private func showQRCodeFeedback(for document: GiniQRCodeDocument, isValid: Bool) {
        guard isPresentedOnScreen else { return }
        guard !validQRCodeProcessing else { return }
        guard detectedQRCodeDocument != document else { return }

        hideQRCodeTask?.cancel()
        resetQRCodeTask?.cancel()
        detectedQRCodeDocument = document

        hideQRCodeTask = DispatchWorkItem(block: {
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
            if !isValidIBANDetected {
                showInvalidQRCodeFeedback()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: hideQRCodeTask!)
    }

    private func showValidQRCodeFeedback() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        validQRCodeProcessing = true
        cameraPane.isUserInteractionEnabled = false
        cameraPaneHorizontal?.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.qrCodeOverLay.isHidden = false
            self.cameraPreviewViewController.changeQRFrameColor(to: .GiniCapture.success2)
        }
        
        // Voiceover announcement
        playVoiceOverMessage(success: true)
        
        // this event is sent once per SDK session since the message can be displayed often in the same session
        GiniAnalyticsManager.track(event: .qr_code_scanned,
                                   screenName: .camera,
                                   properties: [GiniAnalyticsProperty(key: .qrCodeValid, value: true)])
        qrCodeOverLay.configureQrCodeOverlay(withCorrectQrCode: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func showInvalidQRCodeFeedback() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)

        qrCodeOverLay.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.qrCodeOverLay.isHidden = false
            self.cameraPreviewViewController.changeQRFrameColor(to: .GiniCapture.warning3)
        }
        
        // Voiceover announcement
        playVoiceOverMessage(success: false)
        
        sendGiniAnalyticsEventForInvalidQRCode()
        qrCodeOverLay.configureQrCodeOverlay(withCorrectQrCode: false)
    }
    
    private func playVoiceOverMessage(success: Bool) {
        // Determine the appropriate message based on success
        let message = success
        ? NSLocalizedStringPreferredFormat("ginicapture.QRscanning.correct", comment: "QR Detected")
        : NSLocalizedStringPreferredFormat("ginicapture.QRscanning.incorrect.title", comment: "Unknown QR")
        
        // Post the announcement for VoiceOver
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func sendGiniAnalyticsEventForInvalidQRCode() {
        guard invalidQRCodeOverlayFirstAppearance else { return }
        // this event is sent once per SDK session since the message can be displayed often in the same session
        GiniAnalyticsManager.track(event: .qr_code_scanned,
                                   screenName: .camera,
                                   properties: [GiniAnalyticsProperty(key: .qrCodeValid, value: false)])
        invalidQRCodeOverlayFirstAppearance = false
    }

    private func resetQRCodeScanning(isValid: Bool) {
        resetQRCodeTask = DispatchWorkItem(block: {
            self.detectedQRCodeDocument = nil
        })

        if isValid {
            cameraPreviewViewController.cameraFrameView.isHidden = true
            qrCodeOverLay.showAnimation()
        } else {
            UIView.animate(withDuration: 0.3) {
                self.cameraPreviewViewController.changeQRFrameColor(to: .GiniCapture.light1)
                self.qrCodeOverLay.isHidden = true
                self.cameraPane.isUserInteractionEnabled = true
                self.cameraPaneHorizontal?.isUserInteractionEnabled = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: resetQRCodeTask!)
        }
    }
}

// MARK: - CameraPreviewViewControllerDelegate

extension CameraViewController: CameraPreviewViewControllerDelegate {
    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetectIBANs ibans: [String]) {
        showIBANFeedback(ibans)
    }

    func cameraDidSetUp(_ viewController: CameraPreviewViewController,
                        camera: CameraProtocol) {
        if !qrCodeScanningOnlyEnabled {
            cameraPreviewViewController.cameraFrameView.isHidden = false
            cameraPane.toggleCaptureButtonActivation(state: true)
            cameraPaneHorizontal?.toggleCaptureButtonActivation(state: true)
        }

        cameraLensSwitcherView.isHidden = true

        cameraPreviewViewController.updatePreviewViewOrientation()
        UIView.animate(withDuration: 1.0) {
            self.cameraPane.setupAuthorization(isHidden: !(UIDevice.current.isIpad || self.currentInterfaceOrientation.isPortrait))
            self.cameraPaneHorizontal?.setupAuthorization(isHidden: !(UIDevice.current.isIphone && self.currentInterfaceOrientation.isLandscape))
            self.cameraPreviewViewController.previewView.alpha = 1
        }
    }

    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetectInvalid qrCodeDocument: GiniQRCodeDocument) {
        showQRCodeFeedback(for: qrCodeDocument, isValid: false)
    }

    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetect qrCodeDocument: GiniQRCodeDocument) {
        showQRCodeFeedback(for: qrCodeDocument, isValid: true)
    }

    func notAuthorized() {
        cameraPane.setupAuthorization(isHidden: true)
        cameraPaneHorizontal?.setupAuthorization(isHidden: true)
        cameraPreviewViewController.cameraFrameView.isHidden = true
        cameraLensSwitcherView.isHidden = true
    }
}

// MARK: - CameraLensSwitcherViewDelegate

extension CameraViewController: CameraLensSwitcherViewDelegate {
    func cameraLensSwitcherDidSwitchTo(lens: CameraLensesAvailable, on: CameraLensSwitcherView) {
        var device: AVCaptureDevice?

        switch lens {
        case .ultraWide:
            if #available(iOS 13.0, *) {
                device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)
            }
        case .wide:
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        case .tele:
            device = AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back)
        }

        guard let device = device else { return }
        cameraPreviewViewController.changeCaptureDevice(withType: device)
    }
}

private extension CameraViewController {
    enum Constants {
        static let switcherPadding: CGFloat = 8
        static let phoneSwitcherSize: CGSize = CGSize(width: 124, height: 40)
        static let tableSwitcherSize: CGSize = CGSize(width: 40, height: 124)
    }
}
// swiftlint:enable type_body_length
