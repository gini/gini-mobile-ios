//
//  GiniDoneAccessoryView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/// Delegate for `GiniDoneAccessoryView` — invoked when the user taps the Done button.
public protocol GiniDoneAccessoryViewDelegate: AnyObject {
    func giniDoneAccessoryViewDidTapDone(_ view: GiniDoneAccessoryView)
}

/// A UIKit input accessory view containing a single trailing Done button, meant to be assigned
/// to `UITextField.inputAccessoryView` for keyboard types that lack a return-key affordance
/// (e.g. `.decimalPad`, `.numberPad`).
///
/// Uses a plain `UIToolbar` so the button is rendered by the system in whichever style the
/// current iOS version dictates (regular bar on iOS <26, Liquid Glass on iOS 26+). This
/// avoids the SwiftUI `ToolbarItemGroup(placement: .keyboard)` rotation/sheet fragilities
/// because the system glues an input accessory view to the keyboard's own window.
public final class GiniDoneAccessoryView: UIView {

    /// Notified when the Done button is tapped.
    public weak var delegate: GiniDoneAccessoryViewDelegate?

    private let toolbar: UIToolbar
    private let doneButton: UIBarButtonItem

    /// - Parameter tintColor: Tint applied to the system Done button. Pass `nil` to inherit the
    ///   system tint. The button title itself is the system-provided, iOS-localized "Done".
    ///   On iOS 26 Liquid Glass this renders as a checkmark glyph inside the accessory pill.
    public init(tintColor: UIColor? = nil) {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        if let tintColor {
            doneButton.tintColor = tintColor
        }

        self.toolbar = toolbar
        self.doneButton = doneButton

        // Initial frame matches the fixed `intrinsicContentSize` — no post-layout resize needed.
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.height))

        doneButton.target = self
        doneButton.action = #selector(handleDoneTap)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        addSubview(toolbar)
        NSLayoutConstraint.activate([
            toolbar.topAnchor.constraint(equalTo: topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        autoresizingMask = .flexibleWidth
    }

    /// Forward the toolbar's own intrinsic size as ours. A fixed smaller height clips the
    /// Liquid Glass pill on iOS 26 (its rounded shape needs the full ~44pt bar to render
    /// without being cut off on the trailing edge), and hard-coding a larger value risks
    /// stale metrics if UIKit changes them. Falling back to `Constants.height` guards against
    /// the toolbar reporting 0 before it's in the hierarchy.
    public override var intrinsicContentSize: CGSize {
        let toolbarSize = toolbar.intrinsicContentSize
        let height = toolbarSize.height > 0 ? toolbarSize.height : Constants.height
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update the Done button's tint colour.
    public func setDoneTintColor(_ color: UIColor?) {
        doneButton.tintColor = color
    }

    @objc private func handleDoneTap() {
        delegate?.giniDoneAccessoryViewDidTapDone(self)
    }

    private enum Constants {
        /// Fallback height used only if `toolbar.intrinsicContentSize` hasn't resolved yet
        /// (the toolbar reports 0 before it's laid out). Sized to comfortably fit the iOS 26
        /// Liquid Glass pill so nothing clips on first mount before Auto Layout kicks in.
        static let height: CGFloat = 60
    }
}
