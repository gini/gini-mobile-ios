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
    public weak var delegate: CameraViewControllerDelegate?
    public weak var trackingDelegate: CameraScreenTrackingDelegate?
    let giniConfiguration: GiniConfiguration
    
    @IBOutlet weak var captureButton: UIButton!
    
    @IBOutlet weak var fileUploadButton: BottomLabelButton!
    
    @IBOutlet weak var flashButton: BottomLabelButton!

    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: "CameraPhone", bundle: giniCaptureBundle())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    func setupView() {
        
        fileUploadButton.configureButton(image: UIImageNamedPreferred(named: "folder") ?? UIImage() , name: "Durchsuchen", giniconfiguration: giniConfiguration)
        flashButton.configureButton(image: UIImageNamedPreferred(named: "flashOff") ?? UIImage(), name: "Durchsuchen", giniconfiguration: giniConfiguration)
    }
    
}
