//
//  DigitalInvoiceSkontoViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class DigitalInvoiceSkontoViewController: UIViewController {
    private lazy var documentPreviewView: SkontoDocumentPreviewView = {
        let view = SkontoDocumentPreviewView(viewModel: viewModel)
        view.delegate = self
        return view
    }()

    private lazy var withDiscountHeaderView: SkontoWithDiscountHeaderView = {
        let view = SkontoWithDiscountHeaderView(viewModel: viewModel)
        return view
    }()

    private lazy var infoBannerView: SkontoInfoBannerView = {
        let view = SkontoInfoBannerView(viewModel: viewModel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showAlertIfNeeded))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private lazy var withDiscountPriceView: SkontoWithDiscountPriceView = {
        let view = SkontoWithDiscountPriceView(viewModel: viewModel)
        view.delegate = self
        return view
    }()

    private lazy var withDiscountContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .giniColorScheme().container.background.uiColor()
        view.layer.cornerRadius = Constants.groupCornerRadius
        return view
    }()

    private lazy var expiryDateView: SkontoExpiryDateView = {
        let view = SkontoExpiryDateView(viewModel: viewModel)
        view.delegate = self
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: Constants.containerPadding,
                                               left: Constants.scrollViewSideInset,
                                               bottom: Constants.containerPadding,
                                               right: Constants.scrollViewSideInset)
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.containerPadding
        return stackView
    }()

    private var safeArea: UILayoutGuide { view.safeAreaLayoutGuide }
    private let viewModel: SkontoViewModel
    private let alertFactory: SkontoAlertFactory
    private let configuration = GiniBankConfiguration.shared

    private var navigationBarBottomAdapter: DigitalInvoiceSkontoNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

    private var firstAppearance = true

    private lazy var scrollViewBottomConstraint = scrollView.bottomAnchor
                                                    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        self.alertFactory = SkontoAlertFactory(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupKeyboardObservers()
        setupInputAccessoryView(for: [withDiscountPriceView, expiryDateView])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppearance {
            showAlertIfNeeded()
            firstAppearance = false
        }
        sendAnalyticsScreenShown()
    }

    deinit {
        removeKeyboardObservers()
    }

    private func setupView() {
        title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.screen.title",
                                                         comment: "Skonto")
        let backButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.digitalinvoice.screentitle",
                                                                       comment: "Back")
        edgesForExtendedLayout = []
        view.backgroundColor = .giniColorScheme().background.primary.uiColor()
        if !configuration.bottomNavigationBarEnabled {
            let helpButton = GiniBarButton(ofType: .help)
            helpButton.addAction(self, #selector(helpButtonTapped))
            navigationItem.rightBarButtonItem = helpButton.barButton

            let backButton = GiniBarButton(ofType: .back(title: backButtonTitle))
            backButton.addAction(self, #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = backButton.barButton
        } else {
            navigationItem.hidesBackButton = true
        }
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(documentPreviewView)
        stackView.addArrangedSubview(withDiscountContainerView)
        withDiscountContainerView.addSubview(withDiscountHeaderView)
        withDiscountContainerView.addSubview(infoBannerView)
        withDiscountContainerView.addSubview(withDiscountPriceView)
        withDiscountContainerView.addSubview(expiryDateView)

        setupBottomNavigationBar()
        setupTapGesture()
        bindViewModel()
    }

    private func setupConstraints() {
        setupScrollViewConstraints()
        setupStackViewConstraints()
        setupWithDiscountGroupViewConstraints()
    }

    private func setupScrollViewConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            scrollViewBottomConstraint
        ])
    }

    private func setupStackViewConstraints() {
        var constraints: [NSLayoutConstraint] = [
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ]

        if UIDevice.current.isIphone {
            constraints += iphoneConstraints()
        } else {
            constraints += ipadConstraints()
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func iphoneConstraints() -> [NSLayoutConstraint] {
        [
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor,
                                               constant: Constants.containerPadding),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor,
                                                constant: -Constants.containerPadding)
        ]
    }

    private func ipadConstraints() -> [NSLayoutConstraint] {
        [
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: safeArea.leadingAnchor,
                                               constant: Constants.containerPadding),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.trailingAnchor,
                                                constant: -Constants.containerPadding),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                             constant: -2 * Constants.containerPadding),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ]
    }

    private func setupWithDiscountGroupViewConstraints() {
        NSLayoutConstraint.activate([
            withDiscountHeaderView.topAnchor.constraint(equalTo: withDiscountContainerView.topAnchor),
            withDiscountHeaderView.leadingAnchor.constraint(equalTo: withDiscountContainerView.leadingAnchor,
                                                            constant: Constants.horizontalPadding),
            withDiscountHeaderView.trailingAnchor.constraint(equalTo: withDiscountContainerView.trailingAnchor,
                                                             constant: -Constants.horizontalPadding),

            infoBannerView.topAnchor.constraint(equalTo: withDiscountHeaderView.bottomAnchor,
                                                constant: Constants.horizontalPadding),
            infoBannerView.leadingAnchor.constraint(equalTo: withDiscountContainerView.leadingAnchor,
                                                    constant: Constants.horizontalPadding),
            infoBannerView.trailingAnchor.constraint(equalTo: withDiscountContainerView.trailingAnchor,
                                                     constant: -Constants.horizontalPadding),

            withDiscountPriceView.topAnchor.constraint(equalTo: infoBannerView.bottomAnchor,
                                                       constant: Constants.horizontalPadding),
            withDiscountPriceView.leadingAnchor.constraint(equalTo: withDiscountContainerView.leadingAnchor,
                                                           constant: Constants.horizontalPadding),
            withDiscountPriceView.trailingAnchor.constraint(equalTo: withDiscountContainerView.trailingAnchor,
                                                            constant: -Constants.horizontalPadding),

            expiryDateView.topAnchor.constraint(equalTo: withDiscountPriceView.bottomAnchor,
                                                constant: Constants.dateViewTopPadding),
            expiryDateView.leadingAnchor.constraint(equalTo: withDiscountContainerView.leadingAnchor,
                                                    constant: Constants.horizontalPadding),
            expiryDateView.trailingAnchor.constraint(equalTo: withDiscountContainerView.trailingAnchor,
                                                     constant: -Constants.horizontalPadding),
            expiryDateView.bottomAnchor.constraint(equalTo: withDiscountContainerView.bottomAnchor,
                                                   constant: -Constants.horizontalPadding)
        ])
    }

    private func setupBottomNavigationBar() {
        guard configuration.bottomNavigationBarEnabled else { return }
        if let bottomBarAdapter = configuration.digitalInvoiceSkontoNavigationBarBottomAdapter {
            navigationBarBottomAdapter = bottomBarAdapter
        } else {
            navigationBarBottomAdapter = DefaultDigitalInvoiceSkontoNavigationBarBottomAdapter()
        }

        navigationBarBottomAdapter?.setHelpButtonClickedActionCallback { [weak self] in
            self?.helpButtonTapped()
        }

        navigationBarBottomAdapter?.setBackButtonClickedActionCallback { [weak self] in
            self?.backButtonTapped()
        }

        if let navigationBar = navigationBarBottomAdapter?.injectedView() {
            bottomNavigationBar = navigationBar
            view.addSubview(navigationBar)

            navigationBar.translatesAutoresizingMaskIntoConstraints = false

            scrollViewBottomConstraint.isActive = false
            NSLayoutConstraint.activate([
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                navigationBar.heightAnchor.constraint(equalToConstant: Constants.navigationBarHeight)
            ])
        }
    }

    private func sendAnalyticsScreenShown() {
        let isSkontoApplied = viewModel.isSkontoApplied
        var eventProperties: [GiniAnalyticsProperty] = [GiniAnalyticsProperty(key: .switchActive,
                                                                              value: isSkontoApplied)]
        if let edgeCaseAnalyticsValue = viewModel.edgeCase?.analyticsValue {
            eventProperties.append(GiniAnalyticsProperty(key: .edgeCaseType,
                                                         value: edgeCaseAnalyticsValue))
        }

        GiniAnalyticsManager.trackScreenShown(screenName: .returnAssistantSkonto, properties: eventProperties)
    }

    private func bindViewModel() {
        viewModel.endEditingAction = {
            self.endEditing()
        }
    }

    @objc private func helpButtonTapped() {
        GiniAnalyticsManager.track(event: .helpTapped, screenName: .returnAssistantSkonto)
        viewModel.helpButtonTapped()
    }

    @objc private func backButtonTapped() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .returnAssistantSkonto)
        viewModel.backButtonTapped()
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func endEditing() {
        view.endEditing(true)
    }

    @objc private func showAlertIfNeeded() {
        guard let alert = alertFactory.createEdgeCaseAlert() else { return }
        present(alert, animated: true, completion: nil)
    }
}

extension DigitalInvoiceSkontoViewController: SkontoDocumentPreviewViewDelegate {
    func documentPreviewTapped(in view: SkontoDocumentPreviewView) {
        GiniAnalyticsManager.track(event: .invoicePreviewTapped,
                                   screenName: .returnAssistantSkonto)
        viewModel.documentPreviewTapped()
    }
}

extension DigitalInvoiceSkontoViewController: SkontoExpiryDateViewDelegate {
    func expiryDateTextFieldTapped() {
        GiniAnalyticsManager.track(event: .dueDateTapped,
                                   screenName: .returnAssistantSkonto)
        updateCurrentField(expiryDateView)
    }
}

extension DigitalInvoiceSkontoViewController: SkontoWithDiscountPriceViewDelegate {
    func withDiscountPriceTextFieldTapped() {
        GiniAnalyticsManager.track(event: .finalAmountTapped,
                                   screenName: .returnAssistantSkonto)
        updateCurrentField(withDiscountPriceView)
    }
}

extension DigitalInvoiceSkontoViewController {
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let keyboardOffset = calculateKeyboardOffset(for: withDiscountContainerView, keyboardHeight: keyboardHeight)

        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.scrollView.contentInset.bottom = keyboardHeight
            self?.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            self?.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardOffset), animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.scrollView.contentInset.bottom = Constants.containerPadding
            self?.scrollView.verticalScrollIndicatorInsets.bottom = Constants.scrollIndicatorInset
        }
    }

    private func calculateKeyboardOffset(for targetView: UIView, keyboardHeight: CGFloat) -> CGFloat {
        let targetFrameInScrollView = scrollView.convert(targetView.frame, from: targetView.superview)
        let scrollViewBottomMarginDifference = (scrollView.superview?.bounds.height ?? 0) - scrollView.frame.maxY
        let keyboardTotalHeight = keyboardHeight + Constants.containerPadding
        let keyboardOffsetOverProceedView = keyboardTotalHeight - scrollViewBottomMarginDifference
        return max(0, targetFrameInScrollView.maxY - scrollView.bounds.height + keyboardOffsetOverProceedView)
    }
}

// MARK: - GiniInputAccessoryView delegate methods

extension DigitalInvoiceSkontoViewController: GiniInputAccessoryViewDelegate {
    func inputAccessoryView(_ view: GiniInputAccessoryView, didSelectPrevious field: UIView) {
        field.becomeFirstResponder()
    }

    func inputAccessoryView(_ view: GiniInputAccessoryView, didSelectNext field: UIView) {
        field.becomeFirstResponder()
    }

    func inputAccessoryViewDidCancel(_ view: GiniInputAccessoryView) {
        endEditing()
    }
}

private extension DigitalInvoiceSkontoViewController {
    enum Constants {
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 12
        static let containerPadding: CGFloat = 16
        static let dateViewTopPadding: CGFloat = 8
        static let scrollViewSideInset: CGFloat = 0
        static let groupCornerRadius: CGFloat = 8
        static let scrollIndicatorInset: CGFloat = 0
        static let tabletWidthMultiplier: CGFloat = 0.7
        static let navigationBarHeight: CGFloat = 114
    }
}
