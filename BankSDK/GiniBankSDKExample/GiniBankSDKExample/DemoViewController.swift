//
//  DemoViewController.swift
//  GiniBankSDKExample
//
//  Created by Nadya Karaban on 18.02.21.
//

import UIKit
import GiniCaptureSDK

protocol DemoViewControllerDelegate: AnyObject {
    func didSelectEntryPoint(_ entryPoint: GiniCaptureSDK.GiniConfiguration.GiniEntryPoint)
    func didSelectSettings()
}

final class DemoViewController: UIViewController {
    
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
    
    weak var delegate: DemoViewControllerDelegate?
    private var focusedFormField: UITextField?
    private var cameraImageView: UIImageView?
    
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

        dismissKeyboardOnTap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeOnKeyboardNotifications()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        cameraImageView?.image = cameraInputImage
    }
    
    // MARK: - Configure UI
    
    private func configureWelcomeTitle() {
        welcomeTitleTopConstraint.constant = Constants.welcomeTitleTopConstant
        welcomeTitlte.text = DemoScreenStrings.welcomeTitle.localized
        welcomeTitlte.accessibilityIdentifier = MainScreenAccessibilityIdentifiers.welcomeTextTitle.rawValue
    }
    
    private func configureIbanTextField() {
        if let cameraIcon = cameraInputImage {
            ibanTextField.delegate = self
            ibanTextField.layer.cornerRadius = 8
            ibanTextField.backgroundColor = itemBackgroundColor
            ibanTextField.attributedPlaceholder = NSAttributedString(
                string: DemoScreenStrings.ibanTextFieldPlaceholder.localized,
                attributes: [NSAttributedString.Key.foregroundColor: textColor]
            )
            
            let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 64))
            view.clipsToBounds = true
            view.layer.cornerRadius = 5
            
            let imageView = UIImageView(image: cameraIcon)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 12.0, y: 19.0, width: 24.0, height: 24.0)
            view.addSubview(imageView)
            cameraImageView = imageView
            mainView.addSubview(view)
            
            ibanTextField.rightViewMode = .always
            ibanTextField.rightView = mainView
            
            let iconTapGesture = UITapGestureRecognizer(target: self, action: #selector(ibanCameraIconTapped))
            ibanTextField.rightView?.addGestureRecognizer(iconTapGesture)
            
            UITextField.appearance().tintColor = ColorPalette.giniBlue
            ibanTextField.accessibilityIdentifier = MainScreenAccessibilityIdentifiers.ibanTextField.rawValue
            cameraIcon.accessibilityIdentifier = MainScreenAccessibilityIdentifiers.cameraIconButton.rawValue
        }
    }
    
    private let textColor = GiniColor(light: .black, dark: .white).uiColor()
    private let iconColor = GiniColor(light: .black, dark: .white).uiColor()
    private var itemBackgroundColor: UIColor {
        return GiniColor(light: giniCaptureColor("Light04"),
                         dark: giniCaptureColor("Dark04")).uiColor()
    }
    
    private var cameraInputImage: UIImage? {
        return UIImage(named: "cameraInput")?.tintedImageWithColor(iconColor)
    }
    
    private func configureAlternativeTitle() {
        alternativeTitle.text = DemoScreenStrings.alternativeText.localized
        alternativeTitle.textColor = textColor
    }
    
    private func configurePhotoPaymentButton() {
        photoPaymentButton.backgroundColor = itemBackgroundColor
        photoPaymentButton.setTitle(DemoScreenStrings.photoPaymentButtonTitle.localized, for: .normal)
        photoPaymentButton.setTitleColor(textColor, for: .normal)
        photoPaymentButton.accessibilityIdentifier = MainScreenAccessibilityIdentifiers.photoPaymentButton.rawValue
    }
    
    private func configureScreenDescriptionTitle() {
        descriptionTitle.text = DemoScreenStrings.screenDescription.localized
        descriptionTitle.textColor = textColor
        descriptionTitle.accessibilityIdentifier = MainScreenAccessibilityIdentifiers.descriptionTextTitle.rawValue
    }
  
    private func configureMetaTitle() {
        metaInformationLabel.isUserInteractionEnabled = true
        let metaTitle = "Gini Bank SDK: () / Gini Capture SDK: (\(GiniCaptureSDKVersion)) / Client id: \(self.clientId ?? "")"
        metaInformationLabel.text = metaTitle
        metaInformationLabel.textColor = textColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.launchSettings))
        metaInformationLabel.addGestureRecognizer(tapGesture)
        metaInformationLabel.accessibilityIdentifier = MainScreenAccessibilityIdentifiers.metaInformationLabel.rawValue
        
    }
    
    private func startSDK(entryPoint: GiniConfiguration.GiniEntryPoint) {
        // we should remove keyboard observers to not interfere with others from the SDK
        unsubscribeFromKeyboardNotifications()
        // we should hide the keyboard if the SDK is presented
        dismissKeyboard()
        delegate?.didSelectEntryPoint(entryPoint)
    }
    
    // MARK: - User interactions

    @objc func launchSettings(_ sender: UITapGestureRecognizer) {
        delegate?.didSelectSettings()
    }
    
    @IBAction func photoPaymentButtonTapped(_ sender: Any) {
        startSDK(entryPoint: .button)
    }
    
    @objc func ibanCameraIconTapped(_ sender: Any) {
        startSDK(entryPoint: .field)
    }
    
    // MARK: - Notifications
    
    private func subscribeOnKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
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
    
    private func dismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
        focusedFormField = nil
    }
}

extension DemoViewController: UITextFieldDelegate {

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

private extension DemoViewController {
    enum Constants {
        static let welcomeTitleTopConstant: CGFloat = Device.small ? 24 : UIDevice.current.isIpad ? 85 : 48
        static let giniLogoTopConstant: CGFloat = Device.small ? 48 : UIDevice.current.isIpad ? 150 : 112
        static let stackViewTopConstant: CGFloat = 72
        static let stackViewMarginConstant: CGFloat = UIDevice.current.isIpad ? 64 : 16
    }
}
