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
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Constants.containerPadding
        return stackView
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center // default `.fill` would try to force stackview above to stretch horizontally
        stackView.spacing = Constants.containerPadding
        return stackView
    }()

    private var landscapeBottomBarContentView: UIView?

    private lazy var stackViewWidthConstraint = stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                                                                 constant: contentStackViewWidth)
    private lazy var proceedContainerConstraints = [
        proceedContainerView.widthAnchor.constraint(equalTo: view.widthAnchor),
        proceedContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        proceedContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        proceedContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    private lazy var scrollViewBottomToViewConstraint = scrollView.bottomAnchor.constraint(equalTo:
                                                                                            view.bottomAnchor)
    private lazy var scrollViewBottomToProceedViewTop = scrollView.bottomAnchor
        .constraint(equalTo: proceedContainerView.bottomAnchor)

    private var contentStackViewWidth: CGFloat {
        let horizontalSafeAreaInsets = view.safeAreaInsets.left + view.safeAreaInsets.right
        let totalPadding = 2 * Constants.containerPadding + 2 * Constants.scrollViewSideInset
        return -totalPadding - horizontalSafeAreaInsets
    }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // On devices without a notch (i.e., no safe area insets at the top),
        // viewSafeAreaInsetsDidChange() does not called on first appearance.
        // So we manually trigger the layout adjustment here as a fallback.
        if firstAppearance && !UIDevice.current.hasNotch {
            adjustPhoneLayoutForCurrentOrientation()
        }
    }

    // This is reliably called on devices that does have a notch
    // (i.e., have safe area insets)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if firstAppearance {
            adjustPhoneLayoutForCurrentOrientation()
        }
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard UIDevice.current.isIphone else { return }

        coordinator.animate(alongsideTransition: { _ in
            self.adjustPhoneLayoutForCurrentOrientation()
        })
    }

    deinit {
        removeKeyboardObservers()
    }

    private func setupView() {
        title = LocalizedStrings.screenTitle
        edgesForExtendedLayout = []
        view.backgroundColor = .giniColorScheme().background.primary.uiColor()

        setupTopBarButtonsIfNeeded()

        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)
        mainStackView.addArrangedSubview(stackView)
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

    private func setupTopBarButtonsIfNeeded() {
        guard !configuration.bottomNavigationBarEnabled else {
            navigationItem.hidesBackButton = true
            return
        }

        let helpButton = GiniBarButton(ofType: .help)
        helpButton.addAction(self, #selector(helpButtonTapped))
        navigationItem.rightBarButtonItem = helpButton.barButton

        let backButton = GiniBarButton(ofType: .back(title: LocalizedStrings.backButtonTitle))
        backButton.addAction(self, #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton.barButton
    }

    private func adjustPhoneLayoutForCurrentOrientation() {
        stackViewWidthConstraint.constant = contentStackViewWidth
        let isLandscape = view.currentInterfaceOrientation.isLandscape

        // Always deactivate both constraints before layout switch
        deactivateScrollViewConstraints()

        if isLandscape {
            setupPhoneLandscapeLayout()
            scrollView.contentInset = Constants.scrollViewLandscapeIphoneContentInsets
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            setupPhonePortraitLayout()
            scrollView.contentInset = Constants.scrollViewDefaultContentInset
            scrollView.contentInsetAdjustmentBehavior = .automatic
        }
    }

    private func setupPhoneLandscapeLayout() {
        removeExistingBottomComponents()

        if configuration.bottomNavigationBarEnabled {
            if bottomNavigationBar is DefaultSkontoBottomNavigationBar {
                setupBottomNavigationBarInLandscape()
            } else {
                setupCustomBottomNavigationBarInLandscape()
            }
        } else {
            setupProceedContainerInLandscape()
        }
    }

    // MARK: - Landscape specific layout
    private func removeExistingBottomComponents() {
        proceedContainerView.removeFromSuperview()
        bottomNavigationBar?.removeFromSuperview()

        removeLandscapeBottomBarContentView()
    }

    private func removeLandscapeBottomBarContentView() {
        if let lastView = landscapeBottomBarContentView {
            mainStackView.removeArrangedSubview(lastView)
            lastView.removeFromSuperview()
            landscapeBottomBarContentView = nil
        }
    }

    private func setupBottomNavigationBarInLandscape() {
        guard let defaultBar = bottomNavigationBar as? DefaultSkontoBottomNavigationBar else {
            setupBottomNavigationBar()
            return
        }

        let contentView = defaultBar.contentBarView
        let navigationBarView = defaultBar.navigationBarView
        landscapeBottomBarContentView = contentView

        mainStackView.addArrangedSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationBarView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            navigationBarView.heightAnchor.constraint(equalToConstant: Constants.navigationBarViewDefaultHeight)
        ])

        updateScrollViewBottomToViewConstraint(to: navigationBarView.topAnchor)
    }

    private func setupProceedContainerInLandscape() {

        proceedContainerView.removeFromSuperview()
        NSLayoutConstraint.deactivate(proceedContainerConstraints)

        // added proceedContainerView to self.view and expand full width for iPad
        // just like iPhone on portrait
        if UIDevice.current.isIpad {
            attachProceedContainerViewIfNeeded()

            updateScrollViewBottomToViewConstraint(to: proceedContainerView.topAnchor)
        } else {

            mainStackView.addArrangedSubview(proceedContainerView)
            NSLayoutConstraint.activate([
                proceedContainerView.leadingAnchor.constraint(equalTo: mainStackView.safeAreaLayoutGuide.leadingAnchor,
                                                              constant: Constants.landscapeHorizontalPadding),
                proceedContainerView.trailingAnchor.constraint(
                    equalTo: mainStackView.safeAreaLayoutGuide.trailingAnchor,
                    constant: -Constants.landscapeHorizontalPadding
                )
            ])

            updateScrollViewBottomToViewConstraint(to: view.safeAreaLayoutGuide.bottomAnchor)
        }
    }

    private func attachProceedContainerViewIfNeeded() {
        guard proceedContainerView.superview != view else { return }

        view.addSubview(proceedContainerView)
        setupProceedContainerViewConstraints()
    }

    // MARK: - Portrait specific layout
    private func setupPhonePortraitLayout() {
        // Cleanup landscape-specific layout
        if let defaultBar = bottomNavigationBar as? DefaultSkontoBottomNavigationBar {
            defaultBar.navigationBarView.removeFromSuperview()
            defaultBar.contentBarView.removeFromSuperview()

            removeLandscapeBottomBarContentView()
        }

        // Deactivate scrollview constraints
        deactivateScrollViewConstraints()

        // Attach correct bottom element and apply correct constraint
        if let defaultBar = bottomNavigationBar as? DefaultSkontoBottomNavigationBar {
            pinToBottom(defaultBar, to: view)
            updateScrollViewBottomToViewConstraint(to: defaultBar.topAnchor)
        } else if let customBar = bottomNavigationBar {
            pinToBottom(customBar, to: view)
            updateScrollViewBottomToViewConstraint(to: customBar.topAnchor)
        } else {
            if mainStackView.arrangedSubviews.contains(proceedContainerView) {
                mainStackView.removeArrangedSubview(proceedContainerView)
                proceedContainerView.removeFromSuperview()
            }
            attachProceedContainerViewIfNeeded()

            scrollViewBottomToProceedViewTop = scrollView.bottomAnchor
                .constraint(equalTo: proceedContainerView.topAnchor)
            scrollViewBottomToProceedViewTop.isActive = true
        }

        scrollView.contentInset = Constants.scrollViewDefaultContentInset
        scrollView.contentInsetAdjustmentBehavior = .automatic
    }

    // MARK: - Constraints

    private func deactivateScrollViewConstraints() {
        scrollViewBottomToViewConstraint.isActive = false
        scrollViewBottomToProceedViewTop.isActive = false
    }

    private func setupScrollViewConstraints() {
        let multiplier: CGFloat = UIDevice.current.isIpad ? Constants.tabletWidthMultiplier : 1.0

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier)
        ])
    }

    private func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackViewWidthConstraint
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
        proceedContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(proceedContainerConstraints)
    }

    private func pinToBottom(_ childView: UIView, to container: UIView) {
        container.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            childView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }

    private func updateScrollViewBottomToViewConstraint(to anchor: NSLayoutYAxisAnchor) {
        scrollViewBottomToViewConstraint = scrollView.bottomAnchor.constraint(equalTo: anchor)
        scrollViewBottomToViewConstraint.isActive = true
    }

    // MARK: - Bottom Navigation Bar Handling

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
            pinToBottom(navigationBar, to: view)
        }

        proceedContainerView.isHidden = true
    }

    private func setupCustomBottomNavigationBarInLandscape() {
        guard let customBar = bottomNavigationBar else { return }

        pinToBottom(customBar, to: view)
        updateScrollViewBottomToViewConstraint(to: customBar.topAnchor)
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
        setupInputAccessoryView(isSkontoApplied: isSkontoApplied)
    }

    private func setupInputAccessoryView(isSkontoApplied: Bool) {
        if isSkontoApplied {
            setupInputAccessoryView(for: [withDiscountPriceView, expiryDateView])
        } else {
            setupInputAccessoryView(for: [withoutDiscountView])
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
        updateCurrentField(expiryDateView)
        GiniAnalyticsManager.track(event: .dueDateTapped, screenName: .skonto)
    }
}

extension SkontoViewController: SkontoWithDiscountPriceViewDelegate {
    func withDiscountPriceTextFieldTapped() {
        updateCurrentField(withDiscountPriceView)
        GiniAnalyticsManager.track(event: .finalAmountTapped, screenName: .skonto)
    }
}

extension SkontoViewController {
    private func setupKeyboardObservers() {
        manageKeyboardObservers(subscribe: true)
    }

    private func removeKeyboardObservers() {
        manageKeyboardObservers(subscribe: false)
    }

    private func manageKeyboardObservers(subscribe: Bool) {
        let center = NotificationCenter.default
        let willShow = UIResponder.keyboardWillShowNotification
        let willHide = UIResponder.keyboardWillHideNotification

        if subscribe {
            center.addObserver(self, selector: #selector(keyboardWillShow), name: willShow, object: nil)
            center.addObserver(self, selector: #selector(keyboardWillHide), name: willHide, object: nil)
        } else {
            center.removeObserver(self, name: willShow, object: nil)
            center.removeObserver(self, name: willHide, object: nil)
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let targetView = viewModel.isSkontoApplied ? withDiscountContainerView : withoutDiscountContainerView
        let keyboardHeight = keyboardFrame.height

        let keyboardOffset = calculateKeyboardOffset(for: targetView, keyboardHeight: keyboardFrame.height)

        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            self.scrollView.setContentOffset(CGPoint(x: 0, y: keyboardOffset), animated: true)
        }
    }

    private func calculateKeyboardOffset(for targetView: UIView, keyboardHeight: CGFloat) -> CGFloat {
        let targetFrameInScrollView = scrollView.convert(targetView.frame, from: targetView.superview)
        let scrollViewBottomMarginDifference = (scrollView.superview?.bounds.height ?? 0) - scrollView.frame.maxY
        let keyboardTotalHeight = keyboardHeight + Constants.containerPadding
        let keyboardOffsetOverProceedView = keyboardTotalHeight - scrollViewBottomMarginDifference
        return max(0, targetFrameInScrollView.maxY - scrollView.bounds.height + keyboardOffsetOverProceedView)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentInset.bottom = Constants.containerPadding
            self.scrollView.verticalScrollIndicatorInsets.bottom = Constants.scrollIndicatorInset
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
        // This multiplier was chosen to accommodate 200% text scaling on iPads,
        // ensuring proper layout and readability for Dynamic Type support.
        static let tabletWidthMultiplier: CGFloat = 0.71
        static let navigationBarViewDefaultHeight: CGFloat = 62
        static let landscapeHorizontalPadding: CGFloat = 16

        static var scrollViewLandscapeIphoneContentInsets: UIEdgeInsets {
            UIEdgeInsets(top: containerPadding, left: 0, bottom: 0, right: 0)
        }

        static var scrollViewDefaultContentInset: UIEdgeInsets {
            UIEdgeInsets(top: containerPadding, left: 0, bottom: containerPadding, right: 0)
        }
    }

    enum LocalizedStrings {
        static let screenTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.screen.title",
                                                                          comment: "Skonto discount")
        static let backButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.backbutton.title",
                                                                              comment: "Back")
    }
}

extension SkontoViewController: GiniInputAccessoryViewDelegate {

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
