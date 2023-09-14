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
 View controller showing how to capture an image of a document using the Screen API of the Gini Capture SDK for iOS
 and how to process it using the Gini SDK for iOS.
 */
final class SelectAPIViewController: UIViewController {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var metaInformationLabel: UILabel!
    @IBOutlet private weak var ibanTextField: TextField!
    @IBOutlet private weak var alternativeTitle: UILabel!
    @IBOutlet private weak var descriptionTitle: UILabel!
    @IBOutlet private weak var welcomeTitlte: UILabel!
    @IBOutlet private weak var photoPaymentButton: GiniButton!
    
    @IBOutlet private weak var giniLogoTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var welcomeTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewMarginConstraints: [NSLayoutConstraint]!
    
    weak var delegate: SelectAPIViewControllerDelegate?
    private var focusedFormField: UITextField?
    
    var clientId: String?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        giniLogoTopConstraint.constant = Constants.giniLogoTopConstant
        
        configureWelcomeTitle()
        configureScreenDescriptionTitle()
        
        stackViewTopConstraint.constant = Constants.stackViewTopConstant
        stackViewMarginConstraints.forEach {
            $0.constant = Constants.stackViewMarginConstant
        }
        configureIbanTextField()
        configurePhotoPaymentButton()
        configureAlternativeTitle()
        configureMetaTitle()

        initializeHideKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObservers()
    }
    
    // MARK: - Configure UI
    
    private func configureWelcomeTitle() {
        welcomeTitleTopConstraint.constant = Constants.welcomeTitleTopConstant
        welcomeTitlte.text = SelectAPIStrings.welcomeTitle.localized
    }
    
    private func configureIbanTextField() {
        if let cameraIcon = UIImage(named: "cameraInput") {
            ibanTextField.delegate = self
            ibanTextField.layer.cornerRadius = 8
            ibanTextField.backgroundColor = GiniColor(light: giniCaptureColor("Light04"),
                                                      dark: giniCaptureColor("Dark04")).uiColor()
            ibanTextField.attributedPlaceholder = NSAttributedString(
                string: SelectAPIStrings.ibanTextFieldPlaceholder.localized,
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
            
            let iconTapGesture = UITapGestureRecognizer(target: self, action: #selector(ibanCameraIconTapped))
            ibanTextField.rightView?.addGestureRecognizer(iconTapGesture)
            
            UITextField.appearance().tintColor = ColorPalette.giniBlue
        }
    }
    
    private func configureAlternativeTitle() {
        alternativeTitle.text = SelectAPIStrings.alternativeText.localized
    }
    
    private func configurePhotoPaymentButton() {
        photoPaymentButton.backgroundColor = GiniColor(light: giniCaptureColor("Light04"),
                                                       dark: giniCaptureColor("Dark04")).uiColor()
        photoPaymentButton.setTitle(SelectAPIStrings.photoPaymentButtonTitle.localized, for: .normal)
    }
    
    private func configureScreenDescriptionTitle() {
        descriptionTitle.text = SelectAPIStrings.screenDescription.localized
    }
  
    private func configureMetaTitle() {
        metaInformationLabel.isUserInteractionEnabled = true
        let metaTitle = "Gini Bank SDK: (\(GiniBankSDKVersion)) / Gini Capture SDK: (\(GiniCaptureSDKVersion)) / Client id: \(self.clientId ?? "")"
        metaInformationLabel.text = metaTitle
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.launchSettings))
        metaInformationLabel.addGestureRecognizer(tapGesture)
    }
    
    private func startSDK(entryPoint: GiniConfiguration.GiniEntryPoint) {
        // we should remove keyboard observers to not interfere with others from the SDK
        removeObservers()
        // we should hide the keyboard if the SDK is presented
        dismissKeyboard()
        delegate?.selectAPI(viewController: self, didSelectEntryPoint: entryPoint)
    }
    
    // MARK: - User interactions

    @objc func launchSettings(_ sender: UITapGestureRecognizer) {
        delegate?.selectAPI(viewController: self, didTapSettings: ())
    }
    
    @IBAction func photoPaymentButtonTapped(_ sender: Any) {
        startSDK(entryPoint: .button)
    }
    
    @objc func ibanCameraIconTapped(_ sender: Any) {
        startSDK(entryPoint: .field)
    }
    
    // MARK: - Notifications
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - Keyboard handling
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) else { return }
        
        if let focusedTextField = focusedFormField, view.frame.origin.y == 0 {
            
            let textFieldFrameInParent = view.convert(focusedTextField.frame, from: focusedTextField.superview)
            let remainingHeight = view.frame.height - textFieldFrameInParent.height - textFieldFrameInParent.origin.y
            if keyboardFrame.height > remainingHeight {
                view.frame.origin.y -= keyboardFrame.height - remainingHeight
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
            view.layoutIfNeeded()
        }
    }
    
    private func initializeHideKeyboard() {
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
        focusedFormField = nil
    }
    
    // MARK: - Utils
    
    private func giniCaptureColor(_ name: String) -> UIColor {
        return UIColor(named: name, in: GiniCaptureSDK.giniCaptureBundle(), compatibleWith: nil) ?? ColorPalette.defaultBackground
    }
}

extension SelectAPIViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        focusedFormField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        focusedFormField = nil
    }
    
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

private extension SelectAPIViewController {
    enum Constants {
        static let welcomeTitleTopConstant: CGFloat = Device.small ? 24 : UIDevice.current.isIpad ? 96 : 48
        static let giniLogoTopConstant: CGFloat = Device.small ? 48 : UIDevice.current.isIpad ? 264 : 132
        static let stackViewTopConstant: CGFloat = Device.small ? 24 : UIDevice.current.isIpad ? 144 : 72
        static let stackViewMarginConstant: CGFloat = UIDevice.current.isIpad ? 64 : 16
    }
}
