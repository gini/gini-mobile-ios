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
        let deviceOrientation = UIDevice.current.orientation

        if deviceOrientation == .portrait || deviceOrientation == .portraitUpsideDown {
            setupPortraitConstraints()
        } else if deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight {
            setupLandscapeConstraints()
        }
    }

    // Portrait Layout Constraints
    private func setupPortraitConstraints() {
        NSLayoutConstraint.deactivate(landscapeConstraints)
        portraitConstraints = [
            paymentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.portraitPadding),
            paymentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.portraitPadding)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    // Landscape Layout Constraints
    private func setupLandscapeConstraints() {
        NSLayoutConstraint.deactivate(portraitConstraints)
        landscapeConstraints = [
            paymentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.landscapePadding),
            paymentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.landscapePadding)
        ]
        NSLayoutConstraint.activate(landscapeConstraints)
    }

    // Handle orientation change
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Check the device orientation
        let deviceOrientation = UIDevice.current.orientation

        if deviceOrientation == .portrait {
            setupPortraitConstraints() // or upsideDown based on orientation
        } else if deviceOrientation == .landscapeLeft || deviceOrientation == .landscapeRight {
            setupLandscapeConstraints()
        }

        // Perform layout updates with animation
        coordinator.animate(alongsideTransition: { context in
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
