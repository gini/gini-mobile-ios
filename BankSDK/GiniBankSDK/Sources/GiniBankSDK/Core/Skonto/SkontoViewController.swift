//
//  SkontoViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoViewController: UIViewController {
    private lazy var headerView: SkontoAppliedHeaderView = {
        let view = SkontoAppliedHeaderView(viewModel: viewModel)
        return view
    }()

    private lazy var infoView: SkontoAppliedInfoView = {
        let view = SkontoAppliedInfoView(viewModel: viewModel)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showAlertIfNeeded))
        view.addGestureRecognizer(tapGesture)
        return view
    }()

    private lazy var appliedAmountView: SkontoAppliedAmountView = {
        let view = SkontoAppliedAmountView(viewModel: viewModel)
        return view
    }()

    private lazy var dateView: SkontoAppliedDateView = {
        let view = SkontoAppliedDateView(viewModel: viewModel)
        return view
    }()

    private lazy var notAppliedView: SkontoNotAppliedView = {
        let view = SkontoNotAppliedView(viewModel: viewModel)
        return view
    }()

    private lazy var proceedView: SkontoProceedView = {
        let view = SkontoProceedView(viewModel: viewModel)
        return view
    }()

    private lazy var appliedGroupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .giniColorScheme().bg.surface.uiColor()
        view.layer.cornerRadius = Constants.groupCornerRadius
        return view
    }()

    private lazy var notAppliedGroupView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .giniColorScheme().bg.surface.uiColor()
        view.layer.cornerRadius = Constants.groupCornerRadius
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
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

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        self.alertFactory = SkontoAlertFactory(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupKeyboardObservers()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAlertIfNeeded()
    }

    deinit {
        removeKeyboardObservers()
    }

    private func setupView() {
        title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.screen.title",
                                                         comment: "Skonto")
        let backButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.backbutton.title",
                                                                       comment: "Back")
        edgesForExtendedLayout = []
        view.backgroundColor = .giniColorScheme().bg.background.uiColor()
        if !configuration.bottomNavigationBarEnabled {
            // MARK: Temporary remove help button
//            let helpButton = GiniBarButton(ofType: .help)
//            helpButton.addAction(self, #selector(helpButtonTapped))
//            navigationItem.rightBarButtonItem = helpButton.barButton

            let backButton = GiniBarButton(ofType: .back(title: backButtonTitle))
            backButton.addAction(self, #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = backButton.barButton
        } else {
            navigationItem.hidesBackButton = true
        }
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(appliedGroupView)
        stackView.addArrangedSubview(notAppliedGroupView)
        appliedGroupView.addSubview(headerView)
        appliedGroupView.addSubview(infoView)
        appliedGroupView.addSubview(appliedAmountView)
        appliedGroupView.addSubview(dateView)
        notAppliedGroupView.addSubview(notAppliedView)
        view.addSubview(proceedView)

        setupBottomNavigationBar()
        setupTapGesture()
        bindViewModel()
    }

    private func setupConstraints() {
        setupScrollViewConstraints()
        setupStackViewConstraints()
        setupAppliedGroupViewConstraints()
        setupNotAppliedGroupViewConstraints()
        setupProceedViewConstraints()
    }

    private func setupScrollViewConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: proceedView.topAnchor)
        ])
    }

    private func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                               constant: Constants.containerPadding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                constant: -Constants.containerPadding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                             constant: -2 * Constants.containerPadding)
        ])
    }

    private func setupAppliedGroupViewConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: appliedGroupView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: appliedGroupView.leadingAnchor,
                                                constant: Constants.horizontalPadding),
            headerView.trailingAnchor.constraint(equalTo: appliedGroupView.trailingAnchor,
                                                 constant: -Constants.horizontalPadding),

            infoView.topAnchor.constraint(equalTo: headerView.bottomAnchor,
                                          constant: Constants.horizontalPadding),
            infoView.leadingAnchor.constraint(equalTo: appliedGroupView.leadingAnchor,
                                              constant: Constants.horizontalPadding),
            infoView.trailingAnchor.constraint(equalTo: appliedGroupView.trailingAnchor,
                                               constant: -Constants.horizontalPadding),

            appliedAmountView.topAnchor.constraint(equalTo: infoView.bottomAnchor,
                                                   constant: Constants.horizontalPadding),
            appliedAmountView.leadingAnchor.constraint(equalTo: appliedGroupView.leadingAnchor,
                                                       constant: Constants.horizontalPadding),
            appliedAmountView.trailingAnchor.constraint(equalTo: appliedGroupView.trailingAnchor,
                                                        constant: -Constants.horizontalPadding),

            dateView.topAnchor.constraint(equalTo: appliedAmountView.bottomAnchor,
                                          constant: Constants.dateViewTopPadding),
            dateView.leadingAnchor.constraint(equalTo: appliedGroupView.leadingAnchor,
                                              constant: Constants.horizontalPadding),
            dateView.trailingAnchor.constraint(equalTo: appliedGroupView.trailingAnchor,
                                               constant: -Constants.horizontalPadding),
            dateView.bottomAnchor.constraint(equalTo: appliedGroupView.bottomAnchor,
                                             constant: -Constants.horizontalPadding)
        ])
    }

    private func setupNotAppliedGroupViewConstraints() {
        NSLayoutConstraint.activate([
            notAppliedGroupView.topAnchor.constraint(equalTo: appliedGroupView.bottomAnchor,
                                                     constant: Constants.containerPadding),
            notAppliedGroupView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                         constant: Constants.containerPadding),
            notAppliedGroupView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                          constant: -Constants.containerPadding),

            notAppliedView.topAnchor.constraint(equalTo: notAppliedGroupView.topAnchor),
            notAppliedView.leadingAnchor.constraint(equalTo: notAppliedGroupView.leadingAnchor,
                                                    constant: Constants.horizontalPadding),
            notAppliedView.trailingAnchor.constraint(equalTo: notAppliedGroupView.trailingAnchor,
                                                     constant: -Constants.horizontalPadding),
            notAppliedView.bottomAnchor.constraint(equalTo: notAppliedGroupView.bottomAnchor,
                                                   constant: -Constants.horizontalPadding)
        ])
    }

    private func setupProceedViewConstraints() {
        NSLayoutConstraint.activate([
            proceedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            proceedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            proceedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
            self?.viewModel.proceedButtonTapped()
        }

        // MARK: Temporary remove help action
//        navigationBarBottomAdapter?.setHelpButtonClickedActionCallback { [weak self] in
//            self?.helpButtonTapped()
//        }

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

        proceedView.isHidden = true
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
        navigationBarBottomAdapter?.updateSkontoPercentageBadge(with: viewModel.localizedDiscountString)
        navigationBarBottomAdapter?.updateSkontoSavingsInfo(with: viewModel.savingsAmountString)
        navigationBarBottomAdapter?.updateSkontoSavingsInfoVisibility(hidden: !isSkontoApplied)
        let localizedStringWithCurrencyCode = viewModel.finalAmountToPay.localizedStringWithCurrencyCode
        navigationBarBottomAdapter?.updateTotalPrice(priceWithCurrencyCode: localizedStringWithCurrencyCode)
    }

    // MARK: Temporary remove help action
//    @objc private func helpButtonTapped() {
//        viewModel.helpButtonTapped()
//    }

    @objc private func backButtonTapped() {
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

        let contentOffset = keyboardFrame.height - proceedView.frame.height + Constants.containerPadding
        UIView.animate(withDuration: animationDuration) {
            self.scrollView.contentInset.bottom = contentOffset
            self.scrollView.scrollIndicatorInsets.bottom = contentOffset
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
    }
}
