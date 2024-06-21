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
        setupConstraints()
    }

    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        amountView.translatesAutoresizingMaskIntoConstraints = false
        dateView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            infoView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            amountView.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 12),
            amountView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            amountView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateView.topAnchor.constraint(equalTo: amountView.bottomAnchor, constant: 8),
            dateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
