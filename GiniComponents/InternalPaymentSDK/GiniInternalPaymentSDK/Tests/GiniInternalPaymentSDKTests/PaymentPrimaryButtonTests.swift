//
//  PaymentPrimaryButtonTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniInternalPaymentSDK

@Suite("PaymentPrimaryButton")
@MainActor
struct PaymentPrimaryButtonTests {

    // MARK: - Helpers

    /** Recursively collects all `UILabel`s in the given view's subview tree. */
    private func allLabels(in view: UIView) -> [UILabel] {
        var result: [UILabel] = []
        if let label = view as? UILabel { result.append(label) }
        view.subviews.forEach { result += allLabels(in: $0) }
        return result
    }

    // MARK: - Tap callback

    @Test("didTapButton fires when touchUpInside is sent")
    func didTapButtonFiresOnTouchUpInside() {
        let sut = PaymentPrimaryButton()
        var tapped = false
        sut.didTapButton = { tapped = true }

        // `sendActions(for:)` dispatches through `UIApplication` which is unreliable
        // in headless tests. Call the registered @objc action directly via the
        // Obj-C runtime to test the callback wiring without UIKit event machinery.
        _ = sut.perform(NSSelectorFromString("tapOnPayInvoiceView"))

        #expect(tapped, "didTapButton closure must be called when touchUpInside is sent")
    }

    @Test("didTapButton is nil by default and sendActions does not crash")
    func defaultNilDidTapButtonDoesNotCrash() {
        let sut = PaymentPrimaryButton()
        #expect(sut.didTapButton == nil)
        sut.sendActions(for: .touchUpInside) // must not crash
    }

    // MARK: - configure

    @Test("configure does not crash with a test ButtonConfiguration")
    func configureDoesNotCrash() {
        let sut = PaymentPrimaryButton()
        sut.configure(with: .test) // must not throw or crash
    }

    // MARK: - customConfigure

    @Test("customConfigure sets the title label text")
    func customConfigureSetsTitleText() {
        let sut = PaymentPrimaryButton()
        sut.customConfigure(text: "Pay with Sparkasse",
                            textColor: .white,
                            backgroundColor: .systemBlue)

        let labels = allLabels(in: sut)
        #expect(labels.contains { $0.text == "Pay with Sparkasse" },
                "A UILabel with the configured text must exist in the button's subview tree")
    }

    @Test("customConfigure with right image data does not crash")
    func customConfigureWithRightImageDataDoesNotCrash() {
        let sut = PaymentPrimaryButton()
        sut.customConfigure(text: "Continue",
                            textColor: .black,
                            backgroundColor: .white,
                            rightImageData: Data())
    }

    @Test("customConfigure with left image data does not crash")
    func customConfigureWithLeftImageDataDoesNotCrash() {
        let sut = PaymentPrimaryButton()
        sut.customConfigure(text: "Continue",
                            textColor: .black,
                            backgroundColor: .white,
                            leftImageData: Data())
    }

    // MARK: - layoutSubviews / preferredMaxLayoutWidth

    @Test("layoutSubviews sets positive preferredMaxLayoutWidth on title label after frame is resolved")
    func layoutSubviewsSetsPreferredMaxLayoutWidth() {
        let sut = PaymentPrimaryButton()
        sut.configure(with: .test)
        sut.customConfigure(text: "Pay with Sparkasse",
                            textColor: .white,
                            backgroundColor: .systemBlue)

        // Add to a UIWindow with a concrete frame so Auto Layout resolves widths
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 60))
        window.addSubview(sut)
        sut.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sut.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
            sut.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
            sut.topAnchor.constraint(equalTo: window.topAnchor),
            sut.heightAnchor.constraint(equalToConstant: 56)
        ])
        window.layoutIfNeeded()

        let titleLabel = allLabels(in: sut).first { $0.text == "Pay with Sparkasse" }
        #expect(titleLabel != nil, "Title label must be present after customConfigure")
        #expect((titleLabel?.preferredMaxLayoutWidth ?? 0) > 0,
                "layoutSubviews must update preferredMaxLayoutWidth to a positive value once the label frame is resolved")
    }
}
