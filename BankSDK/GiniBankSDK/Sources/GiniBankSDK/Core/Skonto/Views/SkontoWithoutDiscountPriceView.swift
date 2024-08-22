//
//  SkontoWithoutDiscountPriceView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

class SkontoWithoutDiscountPriceView: UIView {
    private lazy var priceView: SkontoAmountToPayView = {
        let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withoutdiscount.price.title",
                                                             comment: "Full amount")
        let view = SkontoAmountToPayView(title: title, price: viewModel.amountToPay)
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
        addSubview(priceView)
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            priceView.topAnchor.constraint(equalTo: topAnchor),
            priceView.bottomAnchor.constraint(equalTo: bottomAnchor),
            priceView.leadingAnchor.constraint(equalTo: leadingAnchor),
            priceView.trailingAnchor.constraint(equalTo: trailingAnchor)
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
        priceView.configure(isEditable: !isSkontoApplied,
                            price: viewModel.amountToPay)
    }
}

extension SkontoWithoutDiscountPriceView: SkontoAmountViewDelegate {
    func textFieldPriceChanged(editedText: String) {
        viewModel.setAmountToPayPrice(editedText)
    }
}
