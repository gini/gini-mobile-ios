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

    private lazy var appliedContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .giniColorScheme().bg.surface.uiColor()
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var notAppliedContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .giniColorScheme().bg.surface.uiColor()
        view.layer.cornerRadius = 8
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: Constants.containerPadding,
                                               left: 0,
                                               bottom: Constants.containerPadding,
                                               right: 0)
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
    private let configuration = GiniBankConfiguration.shared

    private var navigationBarBottomAdapter: SkontoNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?
    
    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }

    private func setupView() {
        title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.screentitle",
                                                         comment: "Skonto")
        let backButtonTitle = NSLocalizedStringPreferredGiniBankFormat("ginibank.help.menu.returnAssistant.backButton.title",
                                                                       comment: "Back")
        edgesForExtendedLayout = []
        view.backgroundColor = .giniColorScheme().bg.background.uiColor()
        if configuration.bottomNavigationBarEnabled {
            let cancelButton = GiniBarButton(ofType: .back(title: backButtonTitle))
            cancelButton.addAction(self, #selector(backButtonTapped))
            navigationItem.rightBarButtonItem = cancelButton.barButton
            navigationItem.hidesBackButton = true
        } else {
            let helpButton = GiniBarButton(ofType: .help)
            helpButton.addAction(self, #selector(helpButtonTapped))
            navigationItem.rightBarButtonItem = helpButton.barButton

            let cancelButton = GiniBarButton(ofType: .back(title: backButtonTitle))
            cancelButton.addAction(self, #selector(backButtonTapped))
            navigationItem.leftBarButtonItem = cancelButton.barButton
        }

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(appliedContainerView)
        stackView.addArrangedSubview(notAppliedContainerView)
        appliedContainerView.addSubview(headerView)
        appliedContainerView.addSubview(infoView)
        appliedContainerView.addSubview(appliedAmountView)
        appliedContainerView.addSubview(dateView)
        notAppliedContainerView.addSubview(notAppliedView)
        view.addSubview(proceedView)

        setupBottomNavigationBar()
        setupTapGesture()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: proceedView.topAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
                                               constant: Constants.containerPadding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
                                                constant: -Constants.containerPadding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
                                             constant: -2 * Constants.containerPadding),

            headerView.topAnchor.constraint(equalTo: appliedContainerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: appliedContainerView.leadingAnchor,
                                                constant: Constants.horizontalPadding),
            headerView.trailingAnchor.constraint(equalTo: appliedContainerView.trailingAnchor,
                                                 constant: -Constants.horizontalPadding),

            infoView.topAnchor.constraint(equalTo: headerView.bottomAnchor,
                                          constant: Constants.horizontalPadding),
            infoView.leadingAnchor.constraint(equalTo: appliedContainerView.leadingAnchor,
                                              constant: Constants.horizontalPadding),
            infoView.trailingAnchor.constraint(equalTo: appliedContainerView.trailingAnchor,
                                               constant: -Constants.horizontalPadding),

            appliedAmountView.topAnchor.constraint(equalTo: infoView.bottomAnchor,
                                                   constant: Constants.horizontalPadding),
            appliedAmountView.leadingAnchor.constraint(equalTo: appliedContainerView.leadingAnchor,
                                                       constant: Constants.horizontalPadding),
            appliedAmountView.trailingAnchor.constraint(equalTo: appliedContainerView.trailingAnchor,
                                                        constant: -Constants.horizontalPadding),

            dateView.topAnchor.constraint(equalTo: appliedAmountView.bottomAnchor,
                                          constant: Constants.dateViewTopPadding),
            dateView.leadingAnchor.constraint(equalTo: appliedContainerView.leadingAnchor,
                                              constant: Constants.horizontalPadding),
            dateView.trailingAnchor.constraint(equalTo: appliedContainerView.trailingAnchor,
                                               constant: -Constants.horizontalPadding),
            dateView.bottomAnchor.constraint(equalTo: appliedContainerView.bottomAnchor,
                                             constant: -Constants.horizontalPadding),

            notAppliedContainerView.topAnchor.constraint(equalTo: appliedContainerView.bottomAnchor,
                                                     constant: Constants.containerPadding),
            notAppliedContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                         constant: Constants.containerPadding),
            notAppliedContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                          constant: -Constants.containerPadding),

            notAppliedView.topAnchor.constraint(equalTo: notAppliedContainerView.topAnchor),
            notAppliedView.leadingAnchor.constraint(equalTo: notAppliedContainerView.leadingAnchor,
                                                    constant: Constants.horizontalPadding),
            notAppliedView.trailingAnchor.constraint(equalTo: notAppliedContainerView.trailingAnchor,
                                                     constant: -Constants.horizontalPadding),
            notAppliedView.bottomAnchor.constraint(equalTo: notAppliedContainerView.bottomAnchor,
                                                   constant: -Constants.horizontalPadding),

            proceedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            proceedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            proceedView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupBottomNavigationBar() {
        if configuration.bottomNavigationBarEnabled {
            if let bottomBarAdapter = configuration.skontoNavigationBarBottomAdapter {
                navigationBarBottomAdapter = bottomBarAdapter
            } else {
                // TODO: Implement default navigation bar when design will be available
            }

            navigationBarBottomAdapter?.setProceedButtonClickedActionCallback { [weak self] in
                self?.proceedButtonTapped()
            }

            navigationBarBottomAdapter?.setHelpButtonClickedActionCallback { [weak self] in
                self?.helpButtonTapped()
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
    }

    @objc private func proceedButtonTapped() {
        viewModel.proceedButtonTapped()
    }

    @objc private func helpButtonTapped() {
        viewModel.helpButtonTapped()
    }

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
}

private extension SkontoViewController {
    enum Constants {
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 12
        static let containerPadding: CGFloat = 16
        static let dateViewTopPadding: CGFloat = 8
    }
}
