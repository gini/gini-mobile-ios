//
//  OnboardingDigitalInvoiceViewController.swift
// GiniBank
//
//  Created by Nadya Karaban on 21.10.20.
//

import UIKit
import GiniCaptureSDK

protocol DigitalInvoiceOnboardingViewControllerDelegate: AnyObject {
    func didDismissViewController()
}
class DigitalInvoiceOnboardingViewController: UIViewController {
    var returnAssistantConfiguration = ReturnAssistantConfiguration()
    weak var delegate: DigitalInvoiceOnboardingViewControllerDelegate?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var hideButton: UIButton!
    
    enum InfoType {
        case onboarding
        case info
    }
    
    var infoType: InfoType = .onboarding
    
    fileprivate var topImage: UIImage {
        return prefferedImage(named: "digital_invoice_onboarding_icon") ?? UIImage()
    }
    
    fileprivate var firstLabelText: String {
        switch infoType {
        case .onboarding:
            return
                NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text1", comment: "title for the first label on the digital invoice onboarding screen")
        case .info:
            return
                NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.info.text1", comment: "title for the first label on the digital invoice onboarding screen")
        }
        
    }
    
    fileprivate var secondLabelText: String {
        switch infoType {
        case .onboarding:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text2", comment: "title for the second label on the digital invoice onboarding screen")
        case .info:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.info.text2", comment: "title for the second label on the digital invoice onboarding screen")
        }
    }
    
    fileprivate var doneButtonTitle: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.donebutton", comment: "title for the done button on the digital invoice onboarding screen")
    }
    
    fileprivate var hideButtonTitle: String {
        switch infoType {
        case .onboarding:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.hidebutton", comment: "title for the hide button on the digital invoice onboarding screen")
        case .info:
            return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.info.hidebutton", comment: "title for the hide button on the digital invoice onboarding screen")
        }
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func setupWhiteButton(button: UIButton) {
        button.isHidden = false
        button.layer.cornerRadius = 7.0
        button.backgroundColor = returnAssistantConfiguration.digitalInvoiceOnboardingDoneButtonBackgroundColor.uiColor()
        button.tintColor = returnAssistantConfiguration.digitalInvoiceOnboardingDoneButtonTextColor.uiColor()
        button.titleLabel?.font = returnAssistantConfiguration.digitalInvoiceOnboardingDoneButtonTextFont
    }

    fileprivate func configureUI() {
        title = .ginibankLocalized(resource: DigitalInvoiceStrings.screenTitle)
        contentView.backgroundColor = returnAssistantConfiguration.digitalInvoiceOnboardingBackgroundColor.uiColor()
        
        topImageView.image = topImage
        
        firstLabel.text = firstLabelText
        firstLabel.font = returnAssistantConfiguration.digitalInvoiceOnboardingFirstLabelTextFont
        firstLabel.textColor = returnAssistantConfiguration.digitalInvoiceOnboardingTextColor.uiColor()
        
        secondLabel.text = secondLabelText
        secondLabel.font = returnAssistantConfiguration.digitalInvoiceOnboardingSecondLabelTextFont
        secondLabel.textColor = returnAssistantConfiguration.digitalInvoiceOnboardingTextColor.uiColor()

        hideButton.addTarget(self, action: #selector(hideAction(_:)), for: .touchUpInside)
        
        switch infoType {
        case .onboarding:
            hideButton.titleLabel?.font = returnAssistantConfiguration.digitalInvoiceOnboardingHideButtonTextFont
            hideButton.tintColor = returnAssistantConfiguration.digitalInvoiceOnboardingHideButtonTextColor.uiColor()
            doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
            setupWhiteButton(button: doneButton)
            doneButton.isHidden = false
            doneButton.setTitle(doneButtonTitle, for: .normal)
            hideButton.setTitle(hideButtonTitle, for: .normal)
        case .info:
            doneButton.isHidden = true
            setupWhiteButton(button: hideButton)
            hideButton.setTitle(hideButtonTitle, for: .normal)
        }
    }
    
    @objc func doneAction(_ sender: UIButton!) {
        dismissViewController()
    }
    
    @objc func hideAction(_ sender: UIButton!) {
        UserDefaults.standard.set(true, forKey: "ginibank.defaults.digitalInvoiceOnboardingShowed")
        dismissViewController()
    }
    
    func dismissViewController() {
        dismiss(animated: true) {
            self.delegate?.didDismissViewController()
        }
    }
}
