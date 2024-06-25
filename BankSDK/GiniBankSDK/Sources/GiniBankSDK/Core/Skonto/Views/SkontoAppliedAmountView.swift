//
//  SkontoAppliedAmountView.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniCaptureSDK

class SkontoAppliedAmountView: UIView {
    private lazy var amountView: UIView = {
        let view = SkontoAmountView(title: NSLocalizedStringPreferredGiniBankFormat("ginibank.skonto.info.amount.title",
                                                                                    comment: "Betrag nach Abzug"),
                                    textFieldText: "999,00",
                                    currency: "EUR",
                                    isEditable: viewModel.isSkontoApplied)
        view.delegate = self
        return view
    }()

    private let configuration = GiniBankConfiguration.shared

    private var viewModel: SkontoViewModel

    public init(viewModel: SkontoViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

extension SkontoAppliedAmountView: SkontoAmountViewDelegate {
    func textFieldDidEndEditing(editedText: String) {
        
    }
}
