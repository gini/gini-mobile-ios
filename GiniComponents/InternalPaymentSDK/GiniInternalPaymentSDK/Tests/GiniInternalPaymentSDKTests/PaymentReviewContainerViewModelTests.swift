//
//  PaymentReviewContainerViewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("PaymentReviewContainerViewModel")
struct PaymentReviewContainerViewModelTests {

    @Test("onExtractionFetched fires when extractions are set")
    func onExtractionFetchedFiresWhenExtractionsSet() {
        let vm = PaymentReviewContainerViewModel.test()
        var callbackFired = false
        vm.onExtractionFetched = { callbackFired = true }
        vm.extractions = []
        #expect(callbackFired == true)
    }

    @Test("onExtractionFetched fires when paymentInfo is set")
    func onExtractionFetchedFiresWhenPaymentInfoSet() {
        let vm = PaymentReviewContainerViewModel.test()
        var callbackFired = false
        vm.onExtractionFetched = { callbackFired = true }
        vm.paymentInfo = PaymentInfo(recipient: "R",
                                     iban: "DE89370400440532013000",
                                     amount: "1.00:EUR",
                                     purpose: "P",
                                     paymentUniversalLink: "",
                                     paymentProviderId: "id")
        #expect(callbackFired == true)
    }

    @Test("shouldShowBrandedView is false when clientConfiguration is nil")
    func shouldShowBrandedViewIsFalseWithNilConfig() {
        let vm = PaymentReviewContainerViewModel.test()
        #expect(vm.shouldShowBrandedView == false)
    }

    @Test("shouldShowBrandedView is true for fullVisible")
    func shouldShowBrandedViewIsTrueForFullVisible() {
        let vm = makeContainerViewModel(brandType: .fullVisible)
        #expect(vm.shouldShowBrandedView == true)
    }

    @Test("shouldShowBrandedView is false for invisible")
    func shouldShowBrandedViewIsFalseForInvisible() {
        let vm = makeContainerViewModel(brandType: .invisible)
        #expect(vm.shouldShowBrandedView == false)
    }

    @Test("shouldShowBrandedView is false for paymentComponent")
    func shouldShowBrandedViewIsFalseForPaymentComponent() {
        let vm = makeContainerViewModel(brandType: .paymentComponent)
        #expect(vm.shouldShowBrandedView == false)
    }

    @Test("selectedPaymentProvider can be mutated after init")
    func selectedPaymentProviderIsMutable() {
        let vm = PaymentReviewContainerViewModel.test()
        let newProvider = PaymentProvider.fixture(id: "new-bank")
        vm.selectedPaymentProvider = newProvider
        #expect(vm.selectedPaymentProvider.id == "new-bank")
    }
}

// MARK: - Helpers

private func makeContainerViewModel(brandType: GiniHealthAPILibrary.IngredientBrandTypeEnum) -> PaymentReviewContainerViewModel {
    let paymentData = PaymentReviewContainerPaymentData(extractions: nil,
                                                        paymentInfo: nil,
                                                        selectedPaymentProvider: .test,
                                                        displayMode: .bottomSheet)
    let buttons = PaymentReviewContainerButtonsConfiguration(primaryButton: .test,
                                                              secondaryButton: .test)
    let inputs = PaymentReviewContainerInputFieldsConfiguration(defaultStyle: .test,
                                                                 errorStyle: .test,
                                                                 selectionStyle: .test)
    return PaymentReviewContainerViewModel(paymentData: paymentData,
                                            configuration: .test,
                                            strings: .test(),
                                            buttonsConfiguration: buttons,
                                            inputFieldsConfiguration: inputs,
                                            poweredByGiniViewModel: PoweredByGiniViewModel(configuration: .test,
                                                                                            strings: .test),
                                            clientConfiguration: .test(ingredientBrandType: brandType))
}
