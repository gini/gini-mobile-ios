//
//  PaymentReviewKeyboardDoneButtonTintTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import SwiftUI
@testable import GiniInternalPaymentSDK

@Suite("Keyboard Done button tint color")
@MainActor
struct PaymentReviewKeyboardDoneButtonTintTests {

    @Test("PaymentReviewContainerConfiguration carries the tint color to the container view model")
    func containerConfigurationCarriesTintColor() {
        let vm = PaymentReviewContainerViewModel.test()

        #expect(vm.configuration.keyboardDoneButtonTintColor == .systemBlue,
                "configuration.keyboardDoneButtonTintColor must match the value passed at init")
    }

    @Test("PaymentReviewObservableModel exposes the tint color as a SwiftUI Color")
    func observableModelExposesTintColor() {
        let delegate = MockPaymentReviewDelegate()
        let provider = MockBottomSheetsProvider()
        let model = makePaymentReviewModel(delegate: delegate, bottomSheetsProvider: provider)
        let sut = PaymentReviewObservableModel(model: model)

        #expect(sut.keyboardDoneButtonTintColor == Color(uiColor: .systemBlue),
                "keyboardDoneButtonTintColor must expose the container configuration's UIColor as a SwiftUI Color")
    }

    @Test("PaymentReviewPaymentInformationObservableModel exposes the tint color as a SwiftUI Color")
    func paymentInformationObservableModelExposesTintColor() {
        let sut = PaymentReviewPaymentInformationObservableModel(model: .test())

        #expect(sut.keyboardDoneButtonTintColor == Color(uiColor: .systemBlue),
                "keyboardDoneButtonTintColor must expose the container configuration's UIColor as a SwiftUI Color")
    }
}
