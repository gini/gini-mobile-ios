//
//  OnboardingDigitalInvoiceViewController.swift
// GiniBank
//
//  Created by Nadya Karaban on 21.10.20.
//

import UIKit
import GiniCaptureSDK

// swiftlint:disable implicit_getter
final class DigitalInvoiceOnboardingViewController: UIViewController {
    @IBOutlet var contentView: UIView!
    @IBOutlet var topImageView: OnboardingImageView!
    @IBOutlet var firstLabel: UILabel!
    @IBOutlet var secondLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var doneButton: MultilineTitleButton!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomAnchor: NSLayoutConstraint!

    private lazy var scrollViewWidthAnchor = scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)

    private var widthMultiplier: CGFloat = 0.6

    private var topPadding: CGFloat {
        get {
            return view.frame.width > view.frame.height ? 40 : 104
        }
    }

    private var navigationBarBottomAdapter: DigitalInvoiceOnboardingNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

    private var topImage: UIImage {
        return prefferedImage(named: "digital_invoice_onboarding_icon") ?? UIImage()
    }

    private var firstLabelText: String {
        return  NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text1",
                                                         comment: "title for digital invoice onboarding screen")
    }

    private var secondLabelText: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.text2",
                                                        comment: "title for digital invoice onboarding screen")
    }

    private var doneButtonTitle: String {
        return NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.onboarding.getStartedButton",
                                                        comment: "title for digital invoice onboarding screen")
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

    // swiftlint:disable function_body_length
    private func configureUI() {
        let configuration = GiniBankConfiguration.shared

        view.backgroundColor = GiniColor(light: UIColor.GiniBank.light2, dark: UIColor.GiniBank.dark2).uiColor()
        contentView.backgroundColor = .clear

        if let adapter = configuration.digitalInvoiceOnboardingIllustrationAdapter {
            topImageView.illustrationAdapter = adapter
        } else {
            topImageView.illustrationAdapter = ImageOnboardingIllustrationAdapter()
            topImageView.icon = topImage
        }
        topImageView.isAccessibilityElement = true
        topImageView.accessibilityValue = firstLabelText
        topImageView.setupView()

        firstLabel.text = firstLabelText
        firstLabel.font = configuration.textStyleFonts[.title2Bold]
        firstLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        firstLabel.adjustsFontForContentSizeCategory = true

        secondLabel.text = secondLabelText
        secondLabel.font = configuration.textStyleFonts[.title2Bold]
        secondLabel.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark7).uiColor()
        secondLabel.adjustsFontForContentSizeCategory = true

        doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        doneButton.setTitle(doneButtonTitle, for: .normal)
        doneButton.titleLabel?.font = configuration.textStyleFonts[.bodyBold]
        doneButton.titleLabel?.adjustsFontForContentSizeCategory = true
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
    // swiftlint:enable function_body_length

    private func configureConstraints() {
        if UIDevice.current.isIpad {
            scrollView.translatesAutoresizingMaskIntoConstraints = false

            scrollViewTopConstraint.constant = topPadding
            scrollViewWidthAnchor = scrollView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                                      multiplier: widthMultiplier)
            scrollViewWidthAnchor.isActive = true
        }
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.scrollViewTopConstraint.constant = self.topPadding

            self.scrollViewWidthAnchor.isActive = false
            self.scrollViewWidthAnchor = self.scrollView.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                                                                multiplier: self.widthMultiplier)
            self.scrollViewWidthAnchor.isActive = true
        })
    }

    @objc func doneAction(_ sender: UIButton!) {
        dismissViewController()
    }

    @objc func hideAction(_ sender: UIButton!) {
        UserDefaults.standard.set(true, forKey: "ginibank.defaults.digitalInvoiceOnboardingShowed")
        dismissViewController()
    }

    private func dismissViewController() {
        dismiss(animated: true)
    }
}
