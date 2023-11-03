//
//  CameraPreviewViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 8/10/18.
//

import UIKit
import AVFoundation
import Vision

protocol CameraPreviewViewControllerDelegate: AnyObject {
    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetect qrCodeDocument: GiniQRCodeDocument)
    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetectInvalid qrCodeDocument: GiniQRCodeDocument)
    func cameraDidSetUp(_ viewController: CameraPreviewViewController,
                        camera: CameraProtocol)
    func notAuthorized()
    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetectIBANs ibans: [String])
}

final class CameraPreviewViewController: UIViewController {

    weak var delegate: CameraPreviewViewControllerDelegate?
    var isFlashOn: Bool {
        get {
            return camera.isFlashOn
        }
        set {
            camera.isFlashOn = newValue
        }
    }

    var isFlashSupported: Bool {
        return camera.isFlashSupported && giniConfiguration.flashToggleEnabled
    }

    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.applyLargeStyle()
        spinner.color = GiniColor(light: .GiniCapture.light1, dark: .GiniCapture.dark1).uiColor()
        spinner.hidesWhenStopped = true
        return spinner
    }()

    lazy var cameraFrameView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamedPreferred(named: "cameraFocus")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    lazy var qrCodeFrameView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamedPreferred(named: "qrCodeFocus")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = !qrCodeScanningOnlyEnabled
        return imageView
    }()

    private lazy var qrCodeScanningOnlyEnabled: Bool = {
        return giniConfiguration.qrCodeScanningEnabled && giniConfiguration.onlyQRCodeScanningEnabled
    }()

    private var notAuthorizedView: UIView?
    private let giniConfiguration: GiniConfiguration
    private typealias FocusIndicator = UIImageView
    private var camera: CameraProtocol
    private var defaultImageView: UIImageView?
    private var focusIndicatorImageView: UIImageView?
    private let interfaceOrientationsMapping: [UIInterfaceOrientation: AVCaptureVideoOrientation] = [
        .portrait: .portrait,
        .landscapeRight: .landscapeRight,
        .landscapeLeft: .landscapeLeft,
        .portraitUpsideDown: .portraitUpsideDown
    ]

    private var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }

    // A flag to determine the default image when testing on simulator.
    private var isReturnAssistantTesting = true
    private var defaultImage: UIImage? {
        if isReturnAssistantTesting {
            return UIImageNamedPreferred(named: "CameraDefaultReturnAssistantDocument")
        } else {
            return UIImageNamedPreferred(named: "cameraDefaultDocumentImage")
        }
    }
    private var isAuthorized = false

    lazy var previewView: CameraPreviewView = {
        let previewView = CameraPreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
        previewView.addGestureRecognizer(tapGesture)
        return previewView
    }()

    init(giniConfiguration: GiniConfiguration = .shared,
         camera: CameraProtocol = Camera(giniConfiguration: .shared)) {
        self.giniConfiguration = giniConfiguration
        self.camera = camera
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        super.loadView()
        view.translatesAutoresizingMaskIntoConstraints = false
        previewView.session = camera.session
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                               object: camera.videoDeviceInput?.device)
        view.backgroundColor = GiniColor(light: UIColor.GiniCapture.dark1, dark: UIColor.GiniCapture.dark1).uiColor()

        view.insertSubview(previewView, at: 0)
        view.addSubview(qrCodeFrameView)
        view.addSubview(cameraFrameView)

        addLoadingIndicator()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera.start()
        startLoadingIndicator()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if giniConfiguration.entryPoint == .field {
            camera.startOCR()
        }
        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isViewLoaded {
            setupIBANDetectionIfViewsAreLoaded()
        }
    }

    private func setupIBANDetectionIfViewsAreLoaded() {
        // this method is checking if both cameraFrameView and previewView are loaded in the screen
        // in order to be able to set some parameters for the camera to be able to detect
        // IBANs just in cameraFrameView frame

        // textOrientation - to be able to set the correct orrientation for text recognition - this is importat mostly on iPad
        // regionOfInterest - region of the screen in which IBANs can be detected
        // videoPreviewLayer - used to translate detected IBANs bounding boxes to videoPreviewLayer frame coordinate system
        // visionToAVFTransform - transform Vision coordinate into AVF coordinate

        if cameraFrameView.frame != CGRect.zero && previewView.frame != CGRect.zero {
            camera.setupIBANDetection(textOrientation: textOrientation,
                                      regionOfInterest: cameraFrameView.frame,
                                      videoPreviewLayer: previewView.videoPreviewLayer,
                                      visionToAVFTransform: visionToAVFTransform)
        }
    }

    private lazy var cameraFrameViewHeightAnchorPortrait =
                        cameraFrameView.heightAnchor.constraint(equalTo: cameraFrameView.widthAnchor,
                                                                multiplier: Constants.a4AspectRatio)

    private lazy var cameraFrameViewHeightAnchorLandscape =
                        cameraFrameView.heightAnchor.constraint(equalTo: cameraFrameView.widthAnchor,
                                                                multiplier: 1 / Constants.a4AspectRatio)

    private func setupConstraints() {
        cameraFrameView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeFrameView.translatesAutoresizingMaskIntoConstraints = false

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate([
                cameraFrameView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: Constants.padding),
                cameraFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                cameraFrameView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                         constant: Constants.padding),
                cameraFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                                         constant: -Constants.cameraPaneWidth/2),
                cameraFrameViewHeightAnchorPortrait])
        } else {
            // The height of the bottom controls
            let bottomControlHeight = view.frame.height * 0.23 +
            (giniConfiguration.bottomNavigationBarEnabled ? Constants.bottomNavigationBarHeight : 0)

            NSLayoutConstraint.activate([
                cameraFrameView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.padding),
                cameraFrameView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                         constant: Constants.padding),
                cameraFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                cameraFrameView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor,
                                                        constant: -bottomControlHeight-Constants.padding),
                cameraFrameView.widthAnchor.constraint(equalTo: cameraFrameView.heightAnchor,
                                                       multiplier: 1 / Constants.a4AspectRatio)
            ])
        }

        NSLayoutConstraint.activate([
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            qrCodeFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            qrCodeFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrCodeFrameView.widthAnchor.constraint(equalToConstant: Constants.QRCodeScannerSize.width),
            qrCodeFrameView.heightAnchor.constraint(equalToConstant: Constants.QRCodeScannerSize.height)
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera.stop()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updatePreviewViewOrientation()
        })
    }

    private func updateFrameOrientation(with orientation: AVCaptureVideoOrientation) {
        if UIDevice.current.isIpad {
            NSLayoutConstraint.deactivate([cameraFrameViewHeightAnchorPortrait, cameraFrameViewHeightAnchorLandscape])

            let isLandscape = orientation == .landscapeRight || orientation == .landscapeLeft
            cameraFrameViewHeightAnchorPortrait.isActive = !isLandscape
            cameraFrameViewHeightAnchorLandscape.isActive = isLandscape

            if let image = cameraFrameView.image?.cgImage {
                if isLandscape {
                    cameraFrameView.image = UIImage(cgImage: image, scale: 1.0, orientation: .left)
                } else {
                    cameraFrameView.image = UIImage(cgImage: image, scale: 1.0, orientation: .up)
                }

            }
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        spinner.center = previewView.center
    }

    func captureImage(completion: @escaping (Data?, CameraError?) -> Void) {
        guard isAuthorized == true else {
            completion(nil, CameraError.notAuthorizedToUseDevice)
            return
        }
        if giniConfiguration.debugModeOn {
            // Retrieves the image from default image view to make sure the image
            // was set and therefore the correct states were checked before.
            #if targetEnvironment(simulator)
            if let image = self.defaultImageView?.image,
                let imageData = image.jpegData(compressionQuality: 0.2) {
                completion(imageData, nil)
            }
            return
            #endif
        }

        camera.captureStillImage(completion: { data, error in
            if let data = data,
                let image = UIImage(data: data),
                let imageData = image.jpegData(compressionQuality: 1.0) {
                completion(imageData, error)
            } else {
                completion(data, error)
            }
        })
    }

    func changeCaptureDevice(withType device: AVCaptureDevice) {
        camera.switchTo(newVideoDevice: device)
    }

    func setupCamera() {
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            #if !targetEnvironment(simulator)
            self.addNotAuthorizedView()
            self.delegate?.notAuthorized()
            #endif
        }

        camera.setup { error in
            if let error = error {
                switch error {
                case .notAuthorizedToUseDevice:
                    self.isAuthorized = false
                    self.addNotAuthorizedView()
                    self.delegate?.notAuthorized()
                default:
                    if self.giniConfiguration.debugModeOn {
                        #if targetEnvironment(simulator)
                        self.isAuthorized = true
                        self.cameraFrameView.isHidden = false
                        self.addDefaultImage()
                        #endif
                    } else {
                        self.isAuthorized = false
                    }
                }
            } else {
                self.isAuthorized = true
                self.notAuthorizedView?.isHidden = true
                self.delegate?.cameraDidSetUp(self, camera: self.camera)
            }

            self.stopLoadingIndicator()
        }

        if giniConfiguration.qrCodeScanningEnabled {
            camera.didDetectQR = { [weak self] qrDocument in
                guard let self = self else { return }
                self.delegate?.cameraPreview(self, didDetect: qrDocument)
            }
            camera.didDetectInvalidQR = { [weak self] qrDocument in
                guard let self = self else { return }
                self.delegate?.cameraPreview(self, didDetectInvalid: qrDocument)
            }
        }

        camera.didDetectIBANs = { [weak self] ibans in
            guard let self = self else { return }
            self.delegate?.cameraPreview(self, didDetectIBANs: ibans)
        }
    }

    func addLoadingIndicator() {
        view.addSubview(spinner)
    }

    func startLoadingIndicator() {
        spinner.startAnimating()
    }

    func stopLoadingIndicator() {
        spinner.stopAnimating()
    }

    func updatePreviewViewOrientation() {

        let orientation: AVCaptureVideoOrientation
        if UIDevice.current.isIpad {
            orientation = interfaceOrientationsMapping[UIApplication.shared.statusBarOrientation] ?? .portrait
            currentOrientation = UIApplication.shared.statusBarOrientation
        } else {
            orientation = .portrait
            currentOrientation = .portrait
        }

        setupOrientationAndTransform()
        previewView.videoPreviewLayer.connection?.videoOrientation = orientation
        updateFrameOrientation(with: orientation)
    }

    func changeQRFrameColor(to color: UIColor) {
        changeCameraFrameColor(to: color)
        qrCodeFrameView.image = qrCodeFrameView.image?.tintedImageWithColor(color)
    }

    func changeCameraFrameColor(to color: UIColor) {
        cameraFrameView.image = cameraFrameView.image?.tintedImageWithColor(color)
    }

    // MARK: - IBAN detection
    private var textOrientation = CGImagePropertyOrientation.up
    private var currentOrientation: UIInterfaceOrientation = .portrait
    // Vision -> AVF coordinate transform.
    private var visionToAVFTransform = CGAffineTransform.identity

    private func setupOrientationAndTransform() {
        // MARK: - Coordinate transforms
        // Transform from UI orientation to buffer orientation.
        var uiRotationTransform = CGAffineTransform.identity
        // Transform bottom-left coordinates to top-left.
        let bottomToTopTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        // Transform coordinates in ROI to global coordinates (still normalized).
        var roiToGlobalTransform = CGAffineTransform.identity
        // Region of video data output buffer that recognition should be run on.
        // Gets recalculated once the bounds of the preview layer are known.
        let roi = CGRect(x: 0, y: 0, width: 1, height: 1)
        // Recalculate the affine transform between Vision coordinates and AVF coordinates.
        roiToGlobalTransform = CGAffineTransform(translationX: roi.origin.x, y: roi.origin.y)
            .scaledBy(x: roi.width, y: roi.height)

        // Compensate for orientation (buffers always come in the same orientation).
        switch currentOrientation {
        case .landscapeLeft:
            textOrientation = CGImagePropertyOrientation.up
            uiRotationTransform = CGAffineTransform.identity
        case .landscapeRight:
            textOrientation = CGImagePropertyOrientation.down
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 1).rotated(by: CGFloat.pi)
        case .portraitUpsideDown:
            textOrientation = CGImagePropertyOrientation.left
            uiRotationTransform = CGAffineTransform(translationX: 1, y: 0).rotated(by: CGFloat.pi / 2)
        default: // everything else to .portraitUp
            textOrientation = CGImagePropertyOrientation.right
            uiRotationTransform = CGAffineTransform(translationX: 0, y: 1).rotated(by: -CGFloat.pi / 2)
        }

        // Full Vision ROI to AVF transform.
        visionToAVFTransform = roiToGlobalTransform.concatenating(bottomToTopTransform)
            .concatenating(uiRotationTransform)
    }
}

// MARK: - Default and not authorized views

extension CameraPreviewViewController {
    private func addNotAuthorizedView() {
        let notAuthorizedView = CameraNotAuthorizedView()
        self.notAuthorizedView = notAuthorizedView
        super.view.addSubview(notAuthorizedView)

        notAuthorizedView.translatesAutoresizingMaskIntoConstraints = false

        let withBottomPadding = giniConfiguration.bottomNavigationBarEnabled && !qrCodeScanningOnlyEnabled
        let bottomPadding: CGFloat = withBottomPadding ? Constants.bottomNavigationBarHeight : 0

        NSLayoutConstraint.activate([
            notAuthorizedView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            notAuthorizedView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomPadding),
            notAuthorizedView.topAnchor.constraint(equalTo: view.topAnchor),
            notAuthorizedView.leadingAnchor.constraint(equalTo: view.leadingAnchor)])
    }

    /// Adds a default image to the canvas when no camera is available (DEBUG mode only)
    private func addDefaultImage() {
        guard let defaultImage = defaultImage else { return }

        defaultImageView = UIImageView(image: defaultImage)
        guard let defaultImageView = defaultImageView else { return }
        defaultImageView.alpha = 0.5
        cameraFrameView.addSubview(defaultImageView)

        defaultImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            defaultImageView.centerXAnchor.constraint(equalTo: cameraFrameView.centerXAnchor),
            defaultImageView.centerYAnchor.constraint(equalTo: cameraFrameView.centerYAnchor),
            defaultImageView.heightAnchor.constraint(equalTo: cameraFrameView.heightAnchor),
            defaultImageView.widthAnchor.constraint(equalTo: cameraFrameView.widthAnchor)
        ])
    }
}

// MARK: - Focus handling

extension CameraPreviewViewController {
    @objc private func focusAndExposeTap(_ sender: UITapGestureRecognizer) {
        let devicePoint = previewView.videoPreviewLayer
                                    .captureDevicePointConverted(fromLayerPoint: sender.location(in: sender.view))
        camera.focus(withMode: .autoFocus,
                     exposeWithMode: .autoExpose,
                     atDevicePoint: devicePoint,
                     monitorSubjectAreaChange: true)
        let imageView =
            createFocusIndicator(withImage: cameraFocusSmall,
                                 atPoint: previewView.videoPreviewLayer
                                            .layerPointConverted(fromCaptureDevicePoint: devicePoint))
        showFocusIndicator(imageView)
    }

    private func createFocusIndicator(withImage image: UIImage?, atPoint point: CGPoint) -> FocusIndicator? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.center = point
        return imageView
    }

    private func showFocusIndicator(_ imageView: FocusIndicator?) {
        guard let imageView = imageView else { return }
        for subView in self.previewView.subviews {
            if let focusIndicator = subView as? FocusIndicator {
                focusIndicator.removeFromSuperview()
            }
        }
        self.previewView.addSubview(imageView)
        UIView.animate(withDuration: 1.5,
                       animations: {
                        imageView.alpha = 0.0
        },
                       completion: { _ in
                        imageView.removeFromSuperview()
        })
    }

    @objc private func subjectAreaDidChange(_ notification: Notification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        camera.focus(withMode: .continuousAutoFocus,
                     exposeWithMode: .continuousAutoExposure,
                     atDevicePoint: devicePoint,
                     monitorSubjectAreaChange: false)
    }
}

extension CameraPreviewViewController {
    private enum Constants {
        static let padding: CGFloat = 16
        static let a4AspectRatio: CGFloat = 1.414
        static let cameraPaneWidth: CGFloat = 124
        static let bottomNavigationBarHeight: CGFloat = 114
        static let QRCodeScannerSize = CGSize(width: 258, height: 258)
    }
}
