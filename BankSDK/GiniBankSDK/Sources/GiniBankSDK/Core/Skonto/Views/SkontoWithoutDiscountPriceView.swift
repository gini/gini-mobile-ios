//
//  SkontoWithoutDiscountPriceView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class SkontoWithoutDiscountPriceView: UIView {
    private lazy var amountView: SkontoAmountToPayView = {
        let view = SkontoAmountToPayView(title: title, price: viewModel.amountToPay)
        view.delegate = self
        return view
    }()

    private let title = NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.withoutdiscount.price.title",
                                                                 comment: "Full amount")

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
        setupKeyboardObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
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
        let accessibilityValue = "\(title): \(viewModel.amountToPay.localizedStringWithCurrencyCode ?? "")"
        amountView.configure(isEditable: !isSkontoApplied,
                             price: viewModel.amountToPay,
                             accessibilityValue: accessibilityValue)
        if !isSkontoApplied, let errorMessage = viewModel.getErrorMessageAndClear() {
            amountView.updateValidationMessage(errorMessage)
        } else {
            amountView.hideValidationMessage()
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc private func keyboardWillHide() {
        amountView.hideValidationMessage()
    }
}

extension SkontoWithoutDiscountPriceView: SkontoAmountViewDelegate {
    func textFieldTapped() {
        GiniAnalyticsManager.track(event: .fullAmountTapped, screenName: .skonto)
    }

    func textFieldPriceChanged(editedText: String) {
        viewModel.setAmountToPayPrice(editedText)
    }
}
