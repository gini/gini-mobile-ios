//
//  GiniAmountInputAccessoryView.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Keyboard accessory view for the payment-review fields.

 A `UIToolbar` with previous / next chevrons for field navigation, a flexible space, and
 a `UIBarButtonItem(barButtonSystemItem: .done)`. The system `.done` bar-button item is
 what renders as the Liquid Glass tick on iOS 26 and picks up the correct blue tint
 automatically on all iOS versions, matching the pattern used by `GiniInputAccessoryView`
 in `GiniBankSDK`.

 **Shared across all fields.** One instance is assigned as `inputAccessoryView` on every
 payment-review `UITextField`, mirroring `setupInputAccessoryView(for: [...])` in the Bank
 SDK. This avoids the keyboard reflowing its `_UIKBAutolayoutHeightConstraint  height == 44`
 every time focus moves between fields — reinstalling a *different* accessory instance
 would otherwise cause a visible content jump when navigating with the prev/next chevrons.

 Callbacks are exposed as closures (not a delegate) so the currently-focused field's
 coordinator can update them on `textFieldDidBeginEditing` without fighting over a single
 `delegate` slot.

 Rendered as a real UIKit `inputAccessoryView` — not a SwiftUI `.toolbar(placement: .keyboard)`
 — so it survives rotation without conflicting with `_UIRemoteKeyboardPlaceholderView`
 constraints.

 TODO(HEAL-508 follow-up): consider extracting a shared implementation into `GiniUtilites`
 alongside `GiniBankSDK`'s `GiniInputAccessoryView` so both SDKs consume a single source.
 */
final class GiniAmountInputAccessoryView: UIView {

    var onPrevious: (() -> Void)?
    var onNext: (() -> Void)?
    var onDone: (() -> Void)?

    var isPreviousEnabled: Bool = true {
        didSet { previousButton.isEnabled = isPreviousEnabled }
    }

    var isNextEnabled: Bool = true {
        didSet { nextButton.isEnabled = isNextEnabled }
    }

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        return toolbar
    }()

    private lazy var previousButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: Constants.previousChevron),
                        style: .plain,
                        target: self,
                        action: #selector(previousTapped))
    }()

    private lazy var nextButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: Constants.nextChevron),
                        style: .plain,
                        target: self,
                        action: #selector(nextTapped))
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
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        toolbar.setItems([previousButton, nextButton, flexibleSpace, doneButton],
                         animated: false)
    }

    @objc private func previousTapped() {
        onPrevious?()
    }

    @objc private func nextTapped() {
        onNext?()
    }

    @objc private func doneTapped() {
        onDone?()
    }

    private enum Constants {
        static let toolbarHeight: CGFloat = 44
        static let previousChevron = "chevron.up"
        static let nextChevron = "chevron.down"
    }
}
