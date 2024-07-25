//
//  OnboardingDigitalInvoiceViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

protocol DigitalInvoiceOnboardingViewControllerDelegate: AnyObject {
    func dismissViewController()
}

final class DigitalInvoiceOnboardingViewController: UIViewController {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var topImageView: OnboardingImageView!
    @IBOutlet private weak var firstLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var doneButton: MultilineTitleButton!
    @IBOutlet private weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var scrollViewBottomAnchor: NSLayoutConstraint!

    weak var delegate: DigitalInvoiceOnboardingViewControllerDelegate?
    private lazy var scrollViewWidthAnchor = scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)

    private var widthMultiplier: CGFloat = 0.6

    private var topPadding: CGFloat {
        return view.frame.width > view.frame.height ? 40 : 104
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

    private var doneButtonTapped: Bool = false

    override public func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        GiniAnalyticsManager.trackScreenShown(screenName: .onboardingReturnAssistant)
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

        // this screen can be dismissed by tapping on the getStarted button or
        // can be dismissed by dragging the screen from top to bottom.

        if doneButtonTapped {
            GiniAnalyticsManager.track(event: .getStartedTapped, screenName: .onboardingReturnAssistant)
        } else {
            GiniAnalyticsManager.track(event: .dismissed, screenName: .onboardingReturnAssistant)
        }
    }

    private func configureUI() {
        let configuration = GiniBankConfiguration.shared

        view.backgroundColor = GiniColor(light: UIColor.GiniBank.light2, dark: UIColor.GiniBank.dark2).uiColor()
        contentView.backgroundColor = .clear

        setupTopImageView(with: configuration)
        setupFirstLabel(with: configuration)
        setupSecondLabel(with: configuration)
        setupDoneButton(with: configuration)

        configureConstraints()
    }

    private func setupTopImageView(with configuration: GiniBankConfiguration) {
        if let adapter = configuration.digitalInvoiceOnboardingIllustrationAdapter {
            topImageView.illustrationAdapter = adapter
        } else {
            topImageView.illustrationAdapter = ImageOnboardingIllustrationAdapter()
            topImageView.icon = topImage
        }
        topImageView.isAccessibilityElement = true
        topImageView.accessibilityValue = firstLabelText
        topImageView.setupView()
    }

    private func setupFirstLabel(with configuration: GiniBankConfiguration) {
        firstLabel.text = firstLabelText
        firstLabel.font = configuration.textStyleFonts[.title2Bold]
        firstLabel.textColor = GiniColor(light: .GiniBank.dark1, dark: .GiniBank.light1).uiColor()
        firstLabel.adjustsFontForContentSizeCategory = true
    }

    private func setupSecondLabel(with configuration: GiniBankConfiguration) {
        secondLabel.text = secondLabelText
        secondLabel.font = configuration.textStyleFonts[.subheadline]
        secondLabel.textColor = GiniColor(light: .GiniBank.dark6, dark: .GiniBank.dark7).uiColor()
        secondLabel.adjustsFontForContentSizeCategory = true
    }

    private func setupDoneButton(with configuration: GiniBankConfiguration) {
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
                self?.doneButtonTapped = true
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
                    navigationBar.heightAnchor.constraint(equalToConstant: Constants.navigationBarHeight),
                    navigationBar.topAnchor.constraint(equalTo: scrollView.bottomAnchor)
                ])
            }
        }

    }

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
        doneButtonTapped = true
        dismissViewController()
    }

    private func dismissViewController() {
        dismiss(animated: true) {
            self.delegate?.dismissViewController()
        }
    }
}

extension DigitalInvoiceOnboardingViewController {
    private enum Constants {
        static let navigationBarHeight: CGFloat = 114
    }
}
