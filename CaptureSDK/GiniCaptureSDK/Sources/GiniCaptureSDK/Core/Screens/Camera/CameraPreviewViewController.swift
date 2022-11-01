//
//  CameraPreviewViewController.swift
//  GiniCapture
//
//  Created by Enrique del Pozo Gómez on 8/10/18.
//

import UIKit
import AVFoundation

protocol CameraPreviewViewControllerDelegate: AnyObject {
    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetect qrCodeDocument: GiniQRCodeDocument)
    func cameraDidSetUp(_ viewController: CameraPreviewViewController,
                        camera: CameraProtocol)
    func notAuthorized()
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

    private var detectedQRCodeDocument: GiniQRCodeDocument?
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = self.giniConfiguration.cameraSetupLoadingIndicatorColor
        spinner.hidesWhenStopped = true
        return spinner
    }()

    lazy var cameraFrameView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamedPreferred(named: "cameraFocus")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate typealias FocusIndicator = UIImageView
    fileprivate var camera: CameraProtocol
    fileprivate var defaultImageView: UIImageView?
    fileprivate var focusIndicatorImageView: UIImageView?
    fileprivate let interfaceOrientationsMapping: [UIInterfaceOrientation: AVCaptureVideoOrientation] = [
        .portrait: .portrait,
        .landscapeRight: .landscapeRight,
        .landscapeLeft: .landscapeLeft,
        .portraitUpsideDown: .portraitUpsideDown
    ]
    
    fileprivate var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }
    
    fileprivate var cameraFocusLarge: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusLarge")
    }
    
    fileprivate var defaultImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraDefaultDocumentImage")
    }

    var isAuthorized = false

    private lazy var qrCodeOverLay: UIView = {
        let view = QRCodeOverlay()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()

    lazy var previewView: CameraPreviewView = {
        let previewView = CameraPreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        (previewView.layer as? AVCaptureVideoPreviewLayer)?.videoGravity = .resize
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
        previewView.addGestureRecognizer(tapGesture)
        return previewView
    }()

    private let iPadCameraPaneWidth: CGFloat = 124
    private lazy var iPadLandscapeConstraints: [NSLayoutConstraint] = [
        cameraFrameView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
        cameraFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        cameraFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -iPadCameraPaneWidth/2),
        cameraFrameView.heightAnchor.constraint(equalTo: cameraFrameView.widthAnchor,
                                                     multiplier: 1.414)
    ]

    private lazy var iPadPortraitConstraints: [NSLayoutConstraint] = [
        cameraFrameView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 16),
        cameraFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        cameraFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
        cameraFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -iPadCameraPaneWidth-16),
        cameraFrameView.heightAnchor.constraint(equalTo: cameraFrameView.widthAnchor,
                                                     multiplier: 1.414)
    ]

    private func iPadConstraint() -> [NSLayoutConstraint] {
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            return iPadLandscapeConstraints
        case .faceDown, .faceUp, .portrait, .portraitUpsideDown:
            return iPadPortraitConstraints
        case .unknown:
            return iPadLandscapeConstraints
        @unknown default:
            return iPadLandscapeConstraints
        }
    }
    
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
        previewView.drawGuides(withColor: giniConfiguration.cameraPreviewCornerGuidesColor)
        
        view.insertSubview(previewView, at: 0)

        view.addSubview(cameraFrameView)

        view.addSubview(qrCodeOverLay)

        addLoadingIndicator()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera.start()
        startLoadingIndicator()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        (qrCodeOverLay as? QRCodeOverlay)?.layoutViews(centeringBy: cameraFrameView)
    }

    private func setupConstraints() {
        cameraFrameView.translatesAutoresizingMaskIntoConstraints = false

        if UIDevice.current.isIpad {
            NSLayoutConstraint.activate(iPadConstraint())
        } else {
            // The height of the bottom controls
            let bottomControlHeight = view.frame.height * 0.23 +
                                      (giniConfiguration.bottomNavigationBarEnabled ? 114 : 0)

            NSLayoutConstraint.activate([
                cameraFrameView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
                cameraFrameView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                                         constant: 16),
                cameraFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                cameraFrameView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor,
                                                        constant: -bottomControlHeight),
                cameraFrameView.widthAnchor.constraint(equalTo: cameraFrameView.heightAnchor,
                                                       multiplier: 1 / 1.414)
                ])
        }

        NSLayoutConstraint.activate([
            qrCodeOverLay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrCodeOverLay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qrCodeOverLay.topAnchor.constraint(equalTo: view.topAnchor),
            qrCodeOverLay.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera.stop()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if UIDevice.current.isIpad {
            // deactivate all constraints before rotation
            NSLayoutConstraint.deactivate(iPadPortraitConstraints)
            NSLayoutConstraint.deactivate(iPadLandscapeConstraints)

            // activate constraints after rotation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                NSLayoutConstraint.activate(self.iPadConstraint())
            })
        }

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.updatePreviewViewOrientation()
        })
    }
    
    public override func viewWillLayoutSubviews() {
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
    
    func showCameraOverlay() {
        previewView.guidesLayer?.isHidden = false
        previewView.frameLayer?.isHidden = false
    }
    
    func hideCameraOverlay() {
        previewView.guidesLayer?.isHidden = true
        previewView.frameLayer?.isHidden = true
    }
    
    func setupCamera() {
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
                        self.addDefaultImage()
                        #endif
                    } else {
                        self.isAuthorized = false
                    }
                }
            } else {
                self.isAuthorized = true
                self.delegate?.cameraDidSetUp(self, camera: self.camera)
            }
            
            self.stopLoadingIndicator()
        }

        if giniConfiguration.qrCodeScanningEnabled {
            camera.didDetectQR = { [weak self] qrDocument in
                guard let self = self else { return }

                if self.detectedQRCodeDocument != qrDocument {
                    self.detectedQRCodeDocument = qrDocument

                    self.showQRCodeFeedback(for: qrDocument)
                }
            }
        }
    }

    private func showQRCodeFeedback(for document: GiniQRCodeDocument) {
        if !document.isReviewable {
            UIView.animate(withDuration: 0.3) {
                self.qrCodeOverLay.isHidden = false
                self.cameraFrameView.image = self.cameraFrameView.image?.tintedImageWithColor(.GiniCapture.success2)
            }

            (qrCodeOverLay as? QRCodeOverlay)?.configureQrCodeOverlay(withCorrectQrCode: true)
        } else {
            UIView.animate(withDuration: 0.3) {
                self.qrCodeOverLay.isHidden = false
                self.cameraFrameView.image = self.cameraFrameView.image?.tintedImageWithColor(.GiniCapture.warning3)
            }

            (qrCodeOverLay as? QRCodeOverlay)?.configureQrCodeOverlay(withCorrectQrCode: false)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.resetQRCodeScanning()

            if let QRDocument = self.detectedQRCodeDocument {
                if QRDocument.isReviewable {
                    self.delegate?.cameraPreview(self, didDetect: QRDocument)
                }
            }
        })
    }

    func resetQRCodeScanning() {
        detectedQRCodeDocument = nil
        cameraFrameView.image = cameraFrameView.image?.tintedImageWithColor(.white)
        qrCodeOverLay.isHidden = true
    }
    
    func addLoadingIndicator(){
        view.addSubview(spinner)
    }
    
    func startLoadingIndicator(){
        spinner.startAnimating()
    }
    
    func stopLoadingIndicator(){
        spinner.stopAnimating()
    }

    func updatePreviewViewOrientation() {
        let orientation: AVCaptureVideoOrientation
        if UIDevice.current.isIpad {
            orientation = interfaceOrientationsMapping[UIApplication.shared.statusBarOrientation] ?? .portrait
        } else {
            orientation = .portrait
        }
        if let cameraLayer = previewView.layer as? AVCaptureVideoPreviewLayer {
            cameraLayer.connection?.videoOrientation = orientation
        }
    }
}

// MARK: - Default and not authorized views

extension CameraPreviewViewController {
    fileprivate func addNotAuthorizedView() {
        
        // Add not authorized view
        let view = CameraNotAuthorizedView()
        super.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        Constraints.active(item: view, attr: .width, relatedBy: .equal, to: super.view, attr: .width)
        Constraints.active(item: view, attr: .height, relatedBy: .equal, to: super.view, attr: .height)
        Constraints.active(item: view, attr: .centerX, relatedBy: .equal, to: super.view, attr: .centerX)
        Constraints.active(item: view, attr: .centerY, relatedBy: .equal, to: super.view, attr: .centerY)
        
        // Hide camera UI
        hideCameraOverlay()
    }
    
    /// Adds a default image to the canvas when no camera is available (DEBUG mode only)
    fileprivate func addDefaultImage() {
        guard let defaultImage = defaultImage else { return }

        defaultImageView = UIImageView(image: defaultImage)
        guard let defaultImageView = defaultImageView else { return }

        if UIDevice.current.isIpad {
            defaultImageView.contentMode = .scaleAspectFit
        } else {
            defaultImageView.contentMode = .scaleAspectFill
        }

        defaultImageView.alpha = 0.5
        previewView.addSubview(defaultImageView)
        
        defaultImageView.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: defaultImageView, attr: .width, relatedBy: .equal, to: previewView, attr: .width)
        Constraints.active(item: defaultImageView, attr: .height, relatedBy: .equal, to: previewView, attr: .height)
        Constraints.active(item: defaultImageView, attr: .centerX, relatedBy: .equal, to: previewView, attr: .centerX)
        Constraints.active(item: defaultImageView, attr: .centerY, relatedBy: .equal, to: previewView, attr: .centerY)
    }
}

// MARK: - Focus handling

extension CameraPreviewViewController {
    
    @objc fileprivate func focusAndExposeTap(_ sender: UITapGestureRecognizer) {
        guard let previewLayer = previewView.layer as? AVCaptureVideoPreviewLayer else { return }
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: sender.location(in: sender.view))
        camera.focus(withMode: .autoFocus,
                     exposeWithMode: .autoExpose,
                     atDevicePoint: devicePoint,
                     monitorSubjectAreaChange: true)
        let imageView =
            createFocusIndicator(withImage: cameraFocusSmall,
                                 atPoint: previewLayer.layerPointConverted(fromCaptureDevicePoint: devicePoint))
        showFocusIndicator(imageView)
    }
    
    fileprivate func createFocusIndicator(withImage image: UIImage?, atPoint point: CGPoint) -> FocusIndicator? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.center = point
        return imageView
    }
    
    fileprivate func showFocusIndicator(_ imageView: FocusIndicator?) {
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
    
    @objc fileprivate func subjectAreaDidChange(_ notification: Notification) {
        guard let previewLayer = previewView.layer as? AVCaptureVideoPreviewLayer else { return }
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        
        camera.focus(withMode: .continuousAutoFocus,
                     exposeWithMode: .continuousAutoExposure,
                     atDevicePoint: devicePoint,
                     monitorSubjectAreaChange: false)
        
        let imageView =
            createFocusIndicator(withImage: cameraFocusLarge,
                                 atPoint: previewLayer.layerPointConverted(fromCaptureDevicePoint: devicePoint))
        showFocusIndicator(imageView)
    }
    
}
