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
    func cameraPreview(_ viewController: CameraPreviewViewController,
                       didDetectInvalid qrCodeDocument: GiniQRCodeDocument)
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
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = self.giniConfiguration.cameraSetupLoadingIndicatorColor
        spinner.hidesWhenStopped = true
        return spinner
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

    lazy var previewView: CameraPreviewView = {
        let previewView = CameraPreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        (previewView.layer as? AVCaptureVideoPreviewLayer)?.videoGravity = .resizeAspectFill
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
        
        previewView.drawGuides(withColor: giniConfiguration.cameraPreviewCornerGuidesColor)
        
        view.insertSubview(previewView, at: 0)
        Constraints.pin(view: previewView, toSuperView: view)
        addLoadingIndicator()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera.start()
        startLoadingIndicator()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera.stop()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
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
                self.delegate?.cameraPreview(self, didDetect: qrDocument)
            }
            camera.didDetectInvalidQR = { [weak self] qrDocument in
                guard let self = self else { return }
                self.delegate?.cameraPreview(self, didDetectInvalid: qrDocument)
            }
        }
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
        defaultImageView = UIImageView(image: defaultImage)
        guard let defaultImageView = defaultImageView else { return }
        
        defaultImageView.contentMode = .scaleAspectFit
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
