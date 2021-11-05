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
final class DigitalInvoiceOnboardingViewController: UIViewController {
    var returnAssistantConfiguration = ReturnAssistantConfiguration()
    weak var delegate: DigitalInvoiceOnboardingViewControllerDelegate?
    
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var hideButton: UIButton!
    
    fileprivate var topImage: UIImage {
        return prefferedImage(named: "digital_invoice_onboarding_icon") ?? UIImage()
    }
    
    fileprivate var firstLabelText: String {
        return
            NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text1", comment: "title for the first label on the digital invoice onboarding screen")
    }
    
    fileprivate var secondLabelText: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text2", comment: "title for the second label on the digital invoice onboarding screen")
    }
    
    fileprivate var doneButtonTitle: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.donebutton", comment: "title for the done button on the digital invoice onboarding screen")
    }
    
    fileprivate var hideButtonTitle: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.hidebutton", comment: "title for the hide button on the digital invoice onboarding screen")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    fileprivate func configureUI() {
        title = .ginibankLocalized(resource: DigitalInvoiceStrings.screenTitle)
        view.backgroundColor = UIColor.from(giniColor: returnAssistantConfiguration.digitalInvoiceOnboardingBackgroundColor)
        
        topImageView.image = topImage
        
        firstLabel.text = firstLabelText
        firstLabel.font = returnAssistantConfiguration.digitalInvoiceOnboardingFirstLabelTextFont
        firstLabel.textColor = UIColor.from(giniColor: returnAssistantConfiguration.digitalInvoiceOnboardingTextColor)
        
        secondLabel.text = secondLabelText
        secondLabel.font = returnAssistantConfiguration.digitalInvoiceOnboardingSecondLabelTextFont
        secondLabel.textColor = UIColor.from(giniColor: returnAssistantConfiguration.digitalInvoiceOnboardingTextColor)
        
        doneButton.layer.cornerRadius = 7.0
        doneButton.backgroundColor = UIColor.from(giniColor: returnAssistantConfiguration.digitalInvoiceOnboardingDoneButtonBackgroundColor)
        doneButton.tintColor = UIColor.from(giniColor: returnAssistantConfiguration.digitalInvoiceOnboardingDoneButtonTextColor)
        doneButton.setTitle(doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = returnAssistantConfiguration.digitalInvoiceOnboardingDoneButtonTextFont
        doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        
        hideButton.setTitle(hideButtonTitle, for: .normal)
        hideButton.titleLabel?.font = returnAssistantConfiguration.digitalInvoiceOnboardingHideButtonTextFont
        hideButton.tintColor = UIColor.from(giniColor: returnAssistantConfiguration.digitalInvoiceOnboardingHideButtonTextColor)
        hideButton.addTarget(self, action: #selector(hideAction(_:)), for: .touchUpInside)
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
