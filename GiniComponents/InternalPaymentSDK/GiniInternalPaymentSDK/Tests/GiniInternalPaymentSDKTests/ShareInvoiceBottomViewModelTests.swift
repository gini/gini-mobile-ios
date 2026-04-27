//
//  ShareInvoiceBottomViewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("ShareInvoiceBottomViewModel")
@MainActor
struct ShareInvoiceBottomViewModelTests {

    // MARK: - Helpers

    private func makeSUT(provider: PaymentProvider? = .make(name: "Test Bank"),
                         paymentRequestId: String = "request-123",
                         clientConfiguration: ClientConfiguration? = nil) -> ShareInvoiceBottomViewModel {
        ShareInvoiceBottomViewModel(selectedPaymentProvider: provider,
                                    configuration: .test,
                                    strings: .test,
                                    primaryButtonConfiguration: .test,
                                    poweredByGiniConfiguration: .test,
                                    poweredByGiniStrings: .test,
                                    qrCodeData: Data(),
                                    paymentInfo: nil,
                                    paymentRequestId: paymentRequestId,
                                    clientConfiguration: clientConfiguration)
    }

    // MARK: - [BANK] substitution

    @Test("titleText substitutes [BANK] with the provider name")
    func titleTextSubstitutesBankName() {
        let sut = makeSUT(provider: .make(name: "Sparkasse"))

        #expect(sut.titleText == "Share with Sparkasse",
                "titleText must replace [BANK] with the selected payment provider's name")
    }

    @Test("titleText substitutes [BANK] with empty string when provider is nil")
    func titleTextWithNilProvider() {
        let sut = makeSUT(provider: nil)

        #expect(sut.titleText == "Share with ",
                "titleText must replace [BANK] with an empty string when no provider is given")
    }

    @Test("descriptionLabelText substitutes [BANK] with the provider name")
    func descriptionLabelTextSubstitutesBankName() {
        let sut = makeSUT(provider: .make(name: "ING"))

        #expect(sut.descriptionLabelText == "Open ING to pay",
                "descriptionLabelText must replace [BANK] with the selected payment provider's name")
    }

    @Test("continueButtonText substitutes [BANK] with the provider name")
    func continueButtonTextSubstitutesBankName() {
        let sut = makeSUT(provider: .make(name: "DKB"))

        #expect(sut.continueButtonText == "Continue with DKB",
                "continueButtonText must replace [BANK] with the selected payment provider's name")
    }

    // MARK: - paymentRequestId

    @Test("paymentRequestId is stored correctly")
    func paymentRequestIdIsStored() {
        let sut = makeSUT(paymentRequestId: "abc-456")

        #expect(sut.paymentRequestId == "abc-456",
                "paymentRequestId must equal the value passed to the initializer")
    }

    // MARK: - bankImageIcon

    @Test("bankImageIcon is empty Data when provider is nil")
    func bankImageIconEmptyWhenNilProvider() {
        let sut = makeSUT(provider: nil)

        #expect(sut.bankImageIcon == Data(),
                "bankImageIcon must be empty Data when no provider is supplied")
    }

    // MARK: - shouldShowBrandedView

    @Test("shouldShowBrandedView is true only for fullVisible",
          arguments: zip(
            [IngredientBrandTypeEnum.fullVisible, .paymentComponent, .invisible],
            [true, false, false]
          ))
    func shouldShowBrandedView(brandType: IngredientBrandTypeEnum, expected: Bool) {
        let sut = makeSUT(clientConfiguration: .test(ingredientBrandType: brandType))

        #expect(sut.shouldShowBrandedView == expected,
                "shouldShowBrandedView must be \(expected) for brandType \(brandType)")
    }

    @Test("shouldShowBrandedView is false when clientConfiguration is nil")
    func shouldShowBrandedViewNilConfig() {
        let sut = makeSUT(clientConfiguration: nil)

        #expect(sut.shouldShowBrandedView == false,
                "shouldShowBrandedView must be false when clientConfiguration is nil")
    }

    // MARK: - Delegate forwarding

    @Test("didTapOnContinue forwards the paymentRequestId to the delegate")
    func didTapOnContinueNotifiesDelegate() {
        let sut = makeSUT(paymentRequestId: "req-789")
        let delegate = MockShareInvoiceDelegate()
        sut.viewDelegate = delegate

        sut.didTapOnContinue()

        #expect(delegate.continueTappedRequestId == "req-789",
                "didTapOnContinue must call didTapOnContinueToShareInvoice with the correct paymentRequestId")
    }
}
