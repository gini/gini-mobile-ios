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
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var topImageView: OnboardingImageView!
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var doneButton: MultilineTitleButton!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomAnchor: NSLayoutConstraint!

    private var navigationBarBottomAdapter: DigitalInvoiceOnboardingNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

    private var topImage: UIImage {
        return prefferedImage(named: "digital_invoice_onboarding_icon") ?? UIImage()
    }
    
    private var firstLabelText: String {
        return  NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text1", comment: "title for the first label on the digital invoice onboarding screen")
    }
    
    private var secondLabelText: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text2", comment: "title for the second label on the digital invoice onboarding screen")
    }
    
    private var doneButtonTitle: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.getStartedButton", comment: "title for the done button on the digital invoice onboarding screen")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let configuration = GiniBankConfiguration.shared
        configuration.digitalInvoiceOnboardingIllustrationAdapter?.pageDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        let configuration = GiniBankConfiguration.shared
        configuration.digitalInvoiceOnboardingIllustrationAdapter?.pageDidDisappear()
    }

    private func configureUI() {
        let configuration = GiniBankConfiguration.shared
        title = .ginibankLocalized(resource: DigitalInvoiceStrings.screenTitle)
        view.backgroundColor = GiniColor(light: UIColor.GiniBank.light2, dark: UIColor.GiniBank.dark2).uiColor()
        contentView.backgroundColor = .clear

        if let adapter = configuration.digitalInvoiceOnboardingIllustrationAdapter {
            topImageView.illustrationAdapter = adapter
        } else {
            topImageView.illustrationAdapter = ImageOnboardingIllustrationAdapter()
            topImageView.icon = topImage
        }

        topImageView.setupView()
        
        firstLabel.text = firstLabelText
        firstLabel.font = configuration.textStyleFonts[.title2Bold]
        firstLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        firstLabel.adjustsFontForContentSizeCategory = true
        firstLabel.accessibilityValue = firstLabelText
        
        secondLabel.text = secondLabelText
        secondLabel.font = configuration.textStyleFonts[.headline]
        secondLabel.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark7).uiColor()
        secondLabel.adjustsFontForContentSizeCategory = true
        secondLabel.accessibilityValue = secondLabelText

        doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        doneButton.setTitle(doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        doneButton.titleLabel?.adjustsFontForContentSizeCategory = true
        doneButton.accessibilityValue = doneButtonTitle
        doneButton.configure(with: configuration.primaryButtonConfiguration)

        if configuration.bottomNavigationBarEnabled {
            doneButton.isHidden = true

            NSLayoutConstraint.deactivate([scrollViewBottomAnchor])

            if let bottomBarAdapter = configuration.digitalInvoiceOnboardingNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBarAdapter
            } else {
                navigationBarBottomAdapter = DefaultDigitalInvoiceOnboardingNavigationBarBottomAdapter()
            }

            navigationBarBottomAdapter?.setGetStartedButtonClickedActionCallback { [weak self] in
                self?.dismissViewController()
            }

            if let navigationBar = navigationBarBottomAdapter?.injectedView() {
                bottomNavigationBar = navigationBar
                view.addSubview(navigationBar)

                navigationBar.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    navigationBar.heightAnchor.constraint(equalToConstant: 114),
                    navigationBar.topAnchor.constraint(equalTo: scrollView.bottomAnchor)
                ])
            }
        }

        configureConstraints()
    }

    private func configureConstraints() {
        if UIDevice.current.isIpad {
            scrollViewTopConstraint.constant = view.frame.width > view.frame.height ? 16 : 96

            let multiplier: CGFloat = view.frame.width > view.frame.height ? 0.4 : 0.6

            scrollView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)]
            )
        }
    }
    
    @objc func doneAction(_ sender: UIButton!) {
        dismissViewController()
    }
    
    @objc func hideAction(_ sender: UIButton!) {
        UserDefaults.standard.set(true, forKey: "ginibank.defaults.digitalInvoiceOnboardingShowed")
        dismissViewController()
    }
    
    private func dismissViewController() {
        dismiss(animated: true) {
            self.delegate?.didDismissViewController()
        }
    }
}
