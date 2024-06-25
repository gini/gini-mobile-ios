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

    private lazy var amountView: SkontoAppliedAmountView = {
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

    private let viewModel = SkontoViewModel(isSkontoApplied: true)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = GiniColor(light: .GiniBank.light1, dark: .GiniBank.dark3).uiColor()
        view.addSubview(headerView)
        view.addSubview(infoView)
        view.addSubview(amountView)
        view.addSubview(dateView)
        view.addSubview(notAppliedView)
        view.addSubview(proceedView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalPadding),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            infoView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Constants.verticalPadding),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            amountView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: Constants.verticalPadding),
            amountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            amountView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            dateView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: Constants.dateViewTopPadding),
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
}

private extension SkontoViewController {
    enum Constants {
        static let verticalPadding: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
        static let dateViewTopPadding: CGFloat = 8
    }
}
