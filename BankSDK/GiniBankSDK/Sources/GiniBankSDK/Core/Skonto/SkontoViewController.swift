//
//  SkontoViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

final class SkontoViewController: UIViewController {
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

    private lazy var withoutDiscountView: SkontoWithoutDiscountView = {
        let view = SkontoWithoutDiscountView(viewModel: viewModel)
        return view
    }()

    private lazy var withoutDiscountContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .giniColorScheme().container.background.uiColor()
        view.layer.cornerRadius = Constants.groupCornerRadius
        return view
    }()

    private lazy var proceedContainerView: SkontoProceedContainerView = {
        let view = SkontoProceedContainerView(viewModel: viewModel)
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

    private let viewModel: SkontoViewModel
    private let alertFactory: SkontoAlertFactory
    private let configuration = GiniBankConfiguration.shared

    private var navigationBarBottomAdapter: SkontoNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

    private var firstAppearance = true

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
                                                         comment: "Skonto discount")
        let backButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.backbutton.title",
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
        stackView.addArrangedSubview(withoutDiscountContainerView)
        withDiscountContainerView.addSubview(withDiscountHeaderView)
        withDiscountContainerView.addSubview(infoBannerView)
        withDiscountContainerView.addSubview(withDiscountPriceView)
        withDiscountContainerView.addSubview(expiryDateView)
        withoutDiscountContainerView.addSubview(withoutDiscountView)
        view.addSubview(proceedContainerView)

        setupBottomNavigationBar()
        setupTapGesture()
        bindViewModel()
    }

    private func setupConstraints() {
        setupScrollViewConstraints()
        setupStackViewConstraints()
        setupWithDiscountGroupViewConstraints()
        setupNotAppliedGroupViewConstraints()
        setupProceedContainerViewConstraints()
    }

    private func setupScrollViewConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            scrollView.bottomAnchor.constraint(equalTo: proceedContainerView.topAnchor)
        ])
    }

    private func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor,
                                               constant: Constants.containerPadding),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor,
                                                constant: -Constants.containerPadding),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                             constant: -2 * Constants.containerPadding)
        ])
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

    private func setupNotAppliedGroupViewConstraints() {
        NSLayoutConstraint.activate([
            withoutDiscountView.topAnchor.constraint(equalTo: withoutDiscountContainerView.topAnchor),
            withoutDiscountView.leadingAnchor.constraint(equalTo: withoutDiscountContainerView.leadingAnchor,
                                                         constant: Constants.horizontalPadding),
            withoutDiscountView.trailingAnchor.constraint(equalTo: withoutDiscountContainerView.trailingAnchor,
                                                          constant: -Constants.horizontalPadding),
            withoutDiscountView.bottomAnchor.constraint(equalTo: withoutDiscountContainerView.bottomAnchor,
                                                        constant: -Constants.horizontalPadding)
        ])
    }

    private func setupProceedContainerViewConstraints() {
        NSLayoutConstraint.activate([
            proceedContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            proceedContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            proceedContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBottomNavigationBar() {
        guard configuration.bottomNavigationBarEnabled else { return }
        if let bottomBarAdapter = configuration.skontoNavigationBarBottomAdapter {
            navigationBarBottomAdapter = bottomBarAdapter
        } else {
            navigationBarBottomAdapter = DefaultSkontoNavigationBarBottomAdapter()
        }

        navigationBarBottomAdapter?.setProceedButtonClickedActionCallback { [weak self] in
            self?.proceedButtonTapped()
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

            NSLayoutConstraint.activate([
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        proceedContainerView.isHidden = true
    }

    private func bindViewModel() {
        configure()
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure()
        }
        viewModel.endEditingAction = {
            self.endEditing()
        }
    }

    private func configure() {
        let isSkontoApplied = viewModel.isSkontoApplied
        navigationBarBottomAdapter?.updateSkontoPercentageBadgeVisibility(hidden: !isSkontoApplied)
        navigationBarBottomAdapter?.updateSkontoPercentageBadge(with: viewModel.skontoPercentageString)
        navigationBarBottomAdapter?.updateSkontoSavingsInfo(with: viewModel.savingsAmountString)
        navigationBarBottomAdapter?.updateSkontoSavingsInfoVisibility(hidden: !isSkontoApplied)
        let localizedStringWithCurrencyCode = viewModel.finalAmountToPay.localizedStringWithCurrencyCode
        navigationBarBottomAdapter?.updateTotalPrice(priceWithCurrencyCode: localizedStringWithCurrencyCode)
    }

    private func sendAnalyticsScreenShown() {
        let isSkontoApplied = viewModel.isSkontoApplied
        var eventProperties: [GiniAnalyticsProperty] = [GiniAnalyticsProperty(key: .switchActive,
                                                                              value: isSkontoApplied)]
        if let edgeCaseAnalyticsValue = viewModel.edgeCase?.analyticsValue {
            eventProperties.append(GiniAnalyticsProperty(key: .edgeCaseType,
                                                         value: edgeCaseAnalyticsValue))
        }

        GiniAnalyticsManager.trackScreenShown(screenName: .skonto, properties: eventProperties)
    }

    @objc private func helpButtonTapped() {
        GiniAnalyticsManager.track(event: .helpTapped, screenName: .skonto)
        viewModel.helpButtonTapped()
    }

    @objc private func backButtonTapped() {
        GiniAnalyticsManager.track(event: .closeTapped, screenName: .skonto)
        viewModel.backButtonTapped()
    }

    @objc private func proceedButtonTapped() {
        viewModel.proceedButtonTapped()
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

extension SkontoViewController: SkontoDocumentPreviewViewDelegate {
    func documentPreviewTapped(in view: SkontoDocumentPreviewView) {
        GiniAnalyticsManager.track(event: .invoicePreviewTapped, screenName: .skonto)
        viewModel.documentPreviewTapped()
    }
}

extension SkontoViewController: SkontoExpiryDateViewDelegate {
    func expiryDateTextFieldTapped() {
        GiniAnalyticsManager.track(event: .dueDateTapped, screenName: .skonto)
    }
}

extension SkontoViewController: SkontoWithDiscountPriceViewDelegate {
    func withDiscountPriceTextFieldTapped() {
        GiniAnalyticsManager.track(event: .finalAmountTapped, screenName: .skonto)
    }
}

extension SkontoViewController {
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

        let targetView = viewModel.isSkontoApplied ? withDiscountContainerView : withoutDiscountContainerView
        let targetFrameInScrollView = scrollView.convert(targetView.frame, from: targetView.superview)
        let keyboardHeight = keyboardFrame.height
        let scrollViewBottomMarginDifference = (scrollView.superview?.bounds.height ?? 0) - scrollView.frame.maxY
        let keyboardOffsetOverProceedView = keyboardHeight + Constants.containerPadding - scrollViewBottomMarginDifference
        let contentOffsetY = max(0, targetFrameInScrollView.maxY - scrollView.bounds.height + keyboardOffsetOverProceedView)
        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.scrollIndicatorInsets.bottom = keyboardHeight
            self.scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentInset.bottom = Constants.containerPadding
            self.scrollView.scrollIndicatorInsets.bottom = Constants.scrollIndicatorInset
        }
    }
}

private extension SkontoViewController {
    enum Constants {
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 12
        static let containerPadding: CGFloat = 16
        static let dateViewTopPadding: CGFloat = 8
        static let scrollViewSideInset: CGFloat = 0
        static let groupCornerRadius: CGFloat = 8
        static let scrollIndicatorInset: CGFloat = 0
        static let tabletWidthMultiplier: CGFloat = 0.7
    }
}
