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
    @IBOutlet weak var alternativeTitle: UILabel!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var welcomeTitlte: UILabel!
    
    weak var delegate: SelectAPIViewControllerDelegate?
        
    var clientId: String?
    
    fileprivate func configureIbanTextField() {
        if let cameraIcon = UIImage(named: "cameraInput"){
            ibanTextField.delegate = self
            let iconColor = UIColor.white
            ibanTextField.layer.cornerRadius = 8
            ibanTextField.backgroundColor = ColorPalette.ibanBackground
            ibanTextField.attributedPlaceholder = NSAttributedString(
                string: "Enter your IBAN code",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
            )
            let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
            view.clipsToBounds = true
            view.layer.cornerRadius = 5
            
            let imageView = UIImageView(image: cameraIcon)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 12.0, y: 19.0, width: 24.0, height: 24.0)
            view.addSubview(imageView)
            
            mainView.addSubview(view)
            
            ibanTextField.rightViewMode = .always
            ibanTextField.rightView = mainView
            
            let iconTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.iconTapped))
            ibanTextField.rightView?.addGestureRecognizer(iconTapGesture)
        }
    }
    
    private func configureWelcomeTile(){
        
    }
    private func configureDescriptionTile(){
        
    }
    private func configureAlternativeTile(){
        
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
        initializeHideKeyboard()
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
    
    // MARK: - Keyboard handling
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }

    
}

extension SelectAPIViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Check if there is any other text-field in the view whose tag is +1 greater than the current text-field on which the return key was pressed. If yes → then move the cursor to that next text-field. If No → Dismiss the keyboard
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
