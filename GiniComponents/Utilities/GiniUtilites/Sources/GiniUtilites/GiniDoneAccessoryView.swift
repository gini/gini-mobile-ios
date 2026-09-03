//
//  GiniDoneAccessoryView.swift
//  GiniUtilites
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Delegate for `GiniDoneAccessoryView` — invoked when the user taps the Done button.
 */
public protocol GiniDoneAccessoryViewDelegate: AnyObject {
    func giniDoneAccessoryViewDidTapDone(_ view: GiniDoneAccessoryView)
}

/**
 A UIKit input accessory view containing a single trailing Done button, meant to be assigned
 to `UITextField.inputAccessoryView` for keyboard types that lack a return-key affordance
 (e.g. `.decimalPad`, `.numberPad`).

 Uses a plain `UIToolbar` so the button is rendered by the system in whichever style the
 current iOS version dictates (regular bar on iOS <26, Liquid Glass on iOS 26+). This
 avoids the SwiftUI `ToolbarItemGroup(placement: .keyboard)` rotation/sheet fragilities
 because the system glues an input accessory view to the keyboard's own window.
 */
public final class GiniDoneAccessoryView: UIView {

    /**
     Notified when the Done button is tapped.
     */
    public weak var delegate: GiniDoneAccessoryViewDelegate?

    private let toolbar: UIToolbar
    private let doneButton: UIBarButtonItem

    /**
     Creates a new accessory view with an optional Done-button tint.
     - Parameter tintColor: Tint applied to the system Done button. Pass `nil` to inherit the
       system tint. The button title itself is the system-provided, iOS-localized "Done". On
       iOS 26 Liquid Glass this renders as a checkmark glyph inside the accessory pill.
     */
    public init(tintColor: UIColor? = nil) {
        // Non-zero initial width avoids the iOS < 26 `_UIToolbarContentView.width == 0` conflict loop.
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,
                                              width: UIScreen.main.bounds.width,
                                              height: Constants.innerToolbarHeight))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        if let tintColor {
            doneButton.tintColor = tintColor
        }

        self.toolbar = toolbar
        self.doneButton = doneButton

        // Initial frame matches the fixed `intrinsicContentSize` — no post-layout resize needed.
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.toolbarHeight))

        doneButton.target = self
        doneButton.action = #selector(handleDoneTap)

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        addSubview(toolbar)
        // Pin the toolbar's BOTTOM (not centerY) to the container's bottom so it sits
        // flush against the keyboard's top edge — no visible gap on any iOS version.
        // The extra ~12 pt goes to the top of the container, giving iOS 26's Liquid
        // Glass pill breathing room above without exposing the keyboard below.
        // On iOS 26 the pill needs a tiny negative inset to hide a Liquid Glass seam;
        // on iOS <26 the solid toolbar must sit flush or a 1 pt gap becomes visible.
        let bottomInset: CGFloat
        if #available(iOS 26, *) {
            bottomInset = Constants.toolbarBottomInset
        } else {
            bottomInset = 0
        }
        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomInset),
            toolbar.heightAnchor.constraint(equalToConstant: Constants.innerToolbarHeight),
            toolbar.leadingAnchor.constraint(equalTo: leadingAnchor,
                                             constant: Constants.horizontalInset),
            toolbar.trailingAnchor.constraint(equalTo: trailingAnchor,
                                              constant: -Constants.horizontalInset)
        ])

        autoresizingMask = .flexibleWidth
    }

    /**
     Returns the outer container height directly — the toolbar's own intrinsic size is forced
     to `innerToolbarHeight` (44) via the height constraint above, and the container is 56 to
     give the Liquid Glass pill vertical breathing room.
     */
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: Constants.toolbarHeight)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Updates the Done button's tint colour.
     - Parameter color: New tint. Pass `nil` to inherit the system tint.
     */
    public func setDoneTintColor(_ color: UIColor?) {
        doneButton.tintColor = color
    }

    @objc private func handleDoneTap() {
        delegate?.giniDoneAccessoryViewDidTapDone(self)
    }

    private enum Constants {
        /**
         Outer container height. Taller than the inner `UIToolbar` so the Done checkmark
         has vertical breathing room, matching iOS 26 Liquid Glass keyboard toolbar padding.
         */
        static let toolbarHeight: CGFloat = 56
        /**
         Height of the `UIToolbar` itself. UIKit's standard toolbar metric.
         */
        static let innerToolbarHeight: CGFloat = 44
        /**
         Trims a few points from each edge so the Done button doesn't sit flush against
         the keyboard's window edge.
         */
        static let horizontalInset: CGFloat = 4
        
        /**
         Slight overlap with the keyboard to avoid a visible seam on iOS 26 Liquid Glass.
         Only applied on iOS 26+ — on older versions the solid toolbar must sit flush
         against the keyboard or the negative inset exposes a 1 pt gap beneath it.
         */
        static let toolbarBottomInset: CGFloat = -1
    }
}
