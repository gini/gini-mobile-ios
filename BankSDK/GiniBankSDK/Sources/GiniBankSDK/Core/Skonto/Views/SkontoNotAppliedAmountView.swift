//
//  SkontoNotAppliedAmountView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoNotAppliedAmountView: UIView {
    private lazy var amountView: SkontoAmountView = {
        let view = SkontoAmountView(title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.notapplied.amount.title",
                                                                                    comment: "Full amount"),
                                    price: viewModel.priceWithoutSkonto)
        view.delegate = self
        return view
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    init(viewModel: SkontoViewModel) {
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
        configure()
        viewModel.addStateChangeHandler { [weak self] in
            guard let self else { return }
            self.configure()
        }
    }

    private func configure() {
        let isSkontoApplied = viewModel.isSkontoApplied
        self.amountView.configure(isEditable: !isSkontoApplied, price: viewModel.priceWithoutSkonto)
    }
}

extension SkontoNotAppliedAmountView: SkontoAmountViewDelegate {
    func textFieldDidEndEditing(editedText: String) {
        self.viewModel.set(price: editedText)
    }
}
