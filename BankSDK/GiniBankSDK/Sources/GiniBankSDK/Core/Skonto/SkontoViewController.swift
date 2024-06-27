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

    private let viewModel = SkontoViewModel(isSkontoApplied: true,
                                            skontoValue: 3.0,
                                            date: Date(),
                                            priceWithoutSkonto: 99.99,
                                            currency: "EUR")
    private let configuration = GiniBankConfiguration.shared

    private var navigationBarBottomAdapter: SkontoNavigationBarBottomAdapter?
    private var bottomNavigationBar: UIView?

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
        view.addSubview(headerView)
        view.addSubview(infoView)
        view.addSubview(appliedAmountView)
        view.addSubview(dateView)
        view.addSubview(notAppliedView)
        view.addSubview(proceedView)

        setupBottomNavigationBar()
        setupTapGesture()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalPadding),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            infoView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Constants.verticalPadding),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            appliedAmountView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: Constants.verticalPadding),
            appliedAmountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            appliedAmountView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            dateView.topAnchor.constraint(equalTo: appliedAmountView.bottomAnchor, constant: Constants.dateViewTopPadding),
            dateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            dateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            notAppliedView.topAnchor.constraint(equalTo: dateView.bottomAnchor, constant: Constants.verticalPadding),
            notAppliedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            notAppliedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

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
        static let horizontalPadding: CGFloat = 16
        static let dateViewTopPadding: CGFloat = 8
    }
}
