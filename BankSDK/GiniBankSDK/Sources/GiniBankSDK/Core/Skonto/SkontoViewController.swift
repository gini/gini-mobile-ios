//
//  SkontoViewController.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

public class SkontoViewController: UIViewController {
    let headerView = SkontoAppliedHeaderView()
    let infoView = SkontoAppliedInfoView()
    let amountView = SkontoAppliedAmountView()
    let dateView = SkontoAppliedDateView()
    let proceedView = SkontoProceedView()

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
        view.addSubview(proceedView)
        setupConstraints()
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

            amountView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: Constants.verticalPadding),
            amountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            amountView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            dateView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: Constants.dateViewTopPadding),
            dateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            dateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),

            proceedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            proceedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            proceedView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
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
