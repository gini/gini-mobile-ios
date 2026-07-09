//
//  GiniAmountInputAccessoryView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Keyboard accessory view for the payment-review amount field.

 A `UIToolbar` with a flexible space and a `UIBarButtonItem(barButtonSystemItem: .done)`.
 The system `.done` bar-button item renders as the Liquid Glass tick on iOS 26 and picks
 up the correct blue tint automatically on all iOS versions.

 Only the amount field attaches this accessory — the other three fields (recipient, IBAN,
 payment purpose) have a normal keyboard with a return key that already dismisses focus,
 so they don't need an accessory bar at all.

 Rendered as a real UIKit `inputAccessoryView` — not a SwiftUI `.toolbar(placement: .keyboard)`
 — so it survives rotation without conflicting with `_UIRemoteKeyboardPlaceholderView`
 constraints.

 TODO(HEAL-508 follow-up): consider extracting a shared implementation into `GiniUtilites`
 alongside `GiniBankSDK`'s `GiniInputAccessoryView` so both SDKs consume a single source.
 */
final class GiniAmountInputAccessoryView: UIView {

    var onDone: (() -> Void)?

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        return toolbar
    }()

    private lazy var doneButton: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .done,
                        target: self,
                        action: #selector(doneTapped))
    }()

    private lazy var flexibleSpace: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                        target: nil,
                        action: nil)
    }()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.toolbarHeight))
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override var tintColor: UIColor? {
        didSet { toolbar.tintColor = tintColor }
    }

    private func setupView() {
        addSubview(toolbar)
        // Center the 44 pt UIToolbar vertically inside a slightly taller accessory
        // container so the Done checkmark doesn't hug the top / bottom edges.
        NSLayoutConstraint.activate([
            toolbar.centerYAnchor.constraint(equalTo: centerYAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: Constants.innerToolbarHeight),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor,
                                             constant: Constants.horizontalInset),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor,
                                              constant: -Constants.horizontalInset)
        ])
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
    }

    @objc private func doneTapped() {
        onDone?()
    }

    private enum Constants {
        static let toolbarHeight: CGFloat = 56
        static let innerToolbarHeight: CGFloat = 44
        static let horizontalInset: CGFloat = 4
    }
}
