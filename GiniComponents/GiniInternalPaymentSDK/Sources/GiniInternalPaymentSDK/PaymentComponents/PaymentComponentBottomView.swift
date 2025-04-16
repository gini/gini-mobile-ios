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

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Detect the initial orientation and set up the appropriate constraints
        setupInitialLayout()
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
            paymentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paymentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // Detect and setup initial layout based on the current orientation
    private func setupInitialLayout() {
        if UIDevice.isPortrait() {
            setupPortraitConstraints()
        } else {
            setupLandscapeConstraints()
        }
    }

    // Portrait Layout Constraints
    private func setupPortraitConstraints() {
        deactivateAllConstraints()
        portraitConstraints = [
            paymentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.portraitPadding),
            paymentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.portraitPadding)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    // Landscape Layout Constraints
    private func setupLandscapeConstraints() {
        deactivateAllConstraints()
        landscapeConstraints = [
            paymentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.landscapePadding),
            paymentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.landscapePadding)
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }
    
    private func deactivateAllConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints + landscapeConstraints)
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { context in
            if UIDevice.isPortrait() {
                self.setupPortraitConstraints()
            } else {
                self.setupLandscapeConstraints()
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension PaymentComponentBottomView {
    private enum Constants {
        static let portraitPadding = 16.0
        static let landscapePadding = 126.0
    }
}
