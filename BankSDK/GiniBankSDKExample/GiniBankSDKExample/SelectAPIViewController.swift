//
//  ScreenApiViewController.swift
//  Example Swift
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit
import GiniCaptureSDK
import GiniBankSDK

protocol SelectAPIViewControllerDelegate: AnyObject {
    func selectAPI(viewController: SelectAPIViewController, didSelectEntryPoint entryPoint: GiniConfiguration.GiniEntryPoint)
    func selectAPI(viewController: SelectAPIViewController, didTapSettings: ())
}

/**
 Integration options for Gini Capture SDK.
 */
enum GiniPayBankApiType {
    case screen
}

/**
 View controller showing how to capture an image of a document using the Screen API of the Gini Capture SDK for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    
    @IBOutlet weak var metaInformationButton: UIButton!
    @IBOutlet weak var ibanTextField: UITextField!

    
    weak var delegate: SelectAPIViewControllerDelegate?
        
    var clientId: String?
    
    fileprivate func configureIbanTextField() {
        if let cameraIcon = UIImage(named: "cameraIcon"), let iconColor = ColorPalette.giniBlue, let tintedImage = cameraIcon.tintedImageWithColor(iconColor) {
            ibanTextField.layer.cornerRadius = 5
            ibanTextField.layer.borderWidth = 1
            ibanTextField.layer.borderColor = iconColor.cgColor
            let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 45))
            view.clipsToBounds = true
            view.layer.cornerRadius = 5
            
            let imageView = UIImageView(image: tintedImage)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 12.0, y: 10.0, width: 24.0, height: 24.0)
            view.addSubview(imageView)
            
            mainView.addSubview(view)
            
            ibanTextField.rightViewMode = .always
            ibanTextField.rightView = mainView
            
            let iconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.iconTapped))
            ibanTextField.rightView?.addGestureRecognizer(iconTapGesture)
        }
    }
    
    fileprivate func configureMetaTitle() {
        let metaTitle = "Gini Bank SDK: (\(GiniBankSDKVersion)) / Gini Capture SDK: (\(GiniCaptureSDKVersion)) / Client id: \(self.clientId ?? "")"
        metaInformationButton.setTitle(metaTitle, for: .normal)
    }
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureMetaTitle()
        configureIbanTextField()
    }
    
    // MARK: User interaction
    @IBAction func startSDK(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectEntryPoint: .button)
    }
    
    @IBAction func launchSettings(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didTapSettings: ())
    }
    
    @objc func iconTapped(_ sender: Any) {
        delegate?.selectAPI(viewController: self, didSelectEntryPoint: .field)
    }
    
}
