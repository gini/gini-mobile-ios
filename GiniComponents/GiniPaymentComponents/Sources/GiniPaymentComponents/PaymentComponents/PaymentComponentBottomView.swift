//
//  PaymentComponentBottomView.swift
//  GiniMerchantSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit
import GiniUtilites

public final class PaymentComponentBottomView: BottomSheetViewController {

    private var paymentView: UIView

    private let contentView = EmptyView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    public init(paymentView: UIView, bottomSheetConfiguration: BottomSheetConfiguration) {
        self.paymentView = paymentView
        super.init(configuration: bottomSheetConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(paymentView)
        self.setContent(content: contentView)

        NSLayoutConstraint.activate([
            paymentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.padding),
            paymentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.padding),
            paymentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paymentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

extension PaymentComponentBottomView {
    private enum Constants {
        static let padding = 16.0
    }
}
