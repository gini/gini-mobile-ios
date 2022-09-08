//
//  Camera2ViewController.swift
//  
//
//  Created by Krzysztof Kryniecki on 06/09/2022.
//

import UIKit

class Camera2ViewController: UIViewController {
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
   
   lazy var cameraPreviewViewController: CameraPreviewViewController = {
       let cameraPreviewViewController = CameraPreviewViewController()
       
       cameraPreviewViewController.delegate = self
       return cameraPreviewViewController
   }()
    public weak var delegate: CameraViewControllerDelegate?
    public weak var trackingDelegate: CameraScreenTrackingDelegate?
    
    @IBOutlet weak var captureButton: UIButton!
    
    @IBOutlet weak var fileUploadButton: BottomLabelButton!
    
    @IBOutlet weak var flashButton: BottomLabelButton!

    public init(giniConfiguration: GiniConfiguration) {
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
        setupView()
        setupCamera()
    }
    
    func setupView() {
        
        addChild(cameraPreviewViewController)
        view.addSubview(cameraPreviewViewController.view)
        cameraPreviewViewController.didMove(toParent: self)
        view.sendSubviewToBack(cameraPreviewViewController.view)
        fileUploadButton.configureButton(image: UIImageNamedPreferred(named: "folder") ?? UIImage() , name: "Durchsuchen", giniconfiguration: giniConfiguration)
        flashButton.configureButton(image: UIImageNamedPreferred(named: "flashOff") ?? UIImage(), name: "Durchsuchen", giniconfiguration: giniConfiguration)
        configureConstraints()
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
    public func setupCamera() {
        cameraPreviewViewController.setupCamera()
    }
}

// MARK: - CameraPreviewViewControllerDelegate

extension Camera2ViewController: CameraPreviewViewControllerDelegate {
    
    func cameraDidSetUp(_ viewController: CameraPreviewViewController, camera: CameraProtocol) {
        if let tooltip = fileImportToolTipView, tooltip.isHidden == false {
        } else {
            //cameraButtonsViewController.toggleCaptureButtonActivation(state: true)
        }
        //cameraButtonsViewController.isFlashSupported = camera.isFlashSupported
        //cameraButtonsViewController.view.setNeedsLayout()
        //cameraButtonsViewController.view.layoutIfNeeded()
    }
    
    func cameraPreview(_ viewController: CameraPreviewViewController, didDetect qrCodeDocument: GiniQRCodeDocument) {
        if let tooltip = qrCodeToolTipView, !tooltip.isHidden {
            qrCodeToolTipView?.dismiss()
        }
        if detectedQRCodeDocument != qrCodeDocument {
            detectedQRCodeDocument = qrCodeDocument
            /*
            showPopup(forQRDetected: qrCodeDocument) { [weak self] in
                guard let self = self else { return }
                self.didPick(qrCodeDocument)
            }
             */
        }
    }
}
