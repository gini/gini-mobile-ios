//
//  SkontoAppliedAmountView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class SkontoAppliedAmountView: UIView {
    private lazy var amountView: SkontoAmountView = {
        let view = SkontoAmountView(title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.amount.title",
                                                                                    comment: "Final amount"),
                                    price: viewModel.priceWithSkonto,
                                    currency: viewModel.currency)
        view.delegate = self
        return view
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    public init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .giniColorScheme().bg.inputUnfocused.uiColor()
        addSubview(amountView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            amountView.topAnchor.constraint(equalTo: topAnchor),
            amountView.bottomAnchor.constraint(equalTo: bottomAnchor),
            amountView.leadingAnchor.constraint(equalTo: leadingAnchor),
            amountView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func bindViewModel() {
        configure(isSkontoApplied: viewModel.isSkontoApplied)
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure(isSkontoApplied: self.viewModel.isSkontoApplied)
        }
    }

    private func configure(isSkontoApplied: Bool) {
        self.amountView.configure(isEditable: isSkontoApplied, price: viewModel.priceWithSkonto)
    }
}

extension SkontoAppliedAmountView: SkontoAmountViewDelegate {
    func textFieldDidEndEditing(editedText: String) {
        self.viewModel.set(price: Double(editedText) ?? 0.0)
    }
}
