//
//  PaymentComponentViewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("PaymentComponentViewModel")
@MainActor
struct PaymentComponentViewModelTests {

    // MARK: - Helpers

    private func makeSUT(provider: PaymentProvider? = .fixture(),
                         paymentComponentConfiguration: PaymentComponentConfiguration? = nil,
                         clientConfiguration: ClientConfiguration? = nil) -> PaymentComponentViewModel {
        PaymentComponentViewModel(paymentProvider: provider,
                                  primaryButtonConfiguration: .test,
                                  secondaryButtonConfiguration: .test,
                                  configuration: .test,
                                  strings: .test,
                                  poweredByGiniConfiguration: .test,
                                  poweredByGiniStrings: .test,
                                  moreInformationConfiguration: .test,
                                  moreInformationStrings: .test,
                                  minimumButtonsHeight: 44,
                                  paymentComponentConfiguration: paymentComponentConfiguration,
                                  clientConfiguration: clientConfiguration)
    }

    // MARK: - hasBankSelected

    @Test("hasBankSelected is true when a payment provider is given")
    func hasBankSelectedTrueWithProvider() {
        let sut = makeSUT()

        #expect(sut.hasBankSelected == true,
                "hasBankSelected must be true when a non-nil payment provider is supplied")
    }

    @Test("hasBankSelected is false when payment provider is nil")
    func hasBankSelectedFalseWithNilProvider() {
        let sut = makeSUT(provider: nil)

        #expect(sut.hasBankSelected == false,
                "hasBankSelected must be false when no payment provider is supplied")
    }

    // MARK: - bankName

    @Test("bankName reflects the payment provider name")
    func bankNameReflectsProviderName() {
        let sut = makeSUT(provider: .fixture(name: "Sparkasse"))

        #expect(sut.bankName == "Sparkasse",
                "bankName must equal the payment provider's name")
    }

    @Test("bankName is nil when payment provider is nil")
    func bankNameNilWithNilProvider() {
        let sut = makeSUT(provider: nil)

        #expect(sut.bankName == nil,
                "bankName must be nil when no payment provider is supplied")
    }

    // MARK: - selectBankButtonText

    @Test("selectBankButtonText shows placeholder when showPaymentComponentInOneRow is true")
    func selectBankButtonTextOneRow() {
        let config = PaymentComponentConfiguration(showPaymentComponentInOneRow: true)
        let sut = makeSUT(provider: .fixture(name: "ING"), paymentComponentConfiguration: config)

        #expect(sut.selectBankButtonText == "Select bank",
                "selectBankButtonText must return the placeholder when showPaymentComponentInOneRow is true")
    }

    @Test("selectBankButtonText shows bank name when showPaymentComponentInOneRow is false and bank is selected")
    func selectBankButtonTextTwoRowWithBank() {
        let config = PaymentComponentConfiguration(showPaymentComponentInOneRow: false)
        let sut = makeSUT(provider: .fixture(name: "ING"), paymentComponentConfiguration: config)

        #expect(sut.selectBankButtonText == "ING",
                "selectBankButtonText must return the bank name when in two-row mode and a bank is selected")
    }

    @Test("selectBankButtonText shows placeholder when showPaymentComponentInOneRow is false and no bank is selected")
    func selectBankButtonTextTwoRowNoBank() {
        let config = PaymentComponentConfiguration(showPaymentComponentInOneRow: false)
        let sut = makeSUT(provider: nil, paymentComponentConfiguration: config)

        #expect(sut.selectBankButtonText == "Select bank",
                "selectBankButtonText must return the placeholder when no bank is selected")
    }

    // MARK: - showPaymentComponentInOneRow

    @Test("showPaymentComponentInOneRow defaults to false when paymentComponentConfiguration is nil")
    func showPaymentComponentInOneRowDefaultsFalse() {
        let sut = makeSUT(paymentComponentConfiguration: nil)

        #expect(sut.showPaymentComponentInOneRow == false,
                "showPaymentComponentInOneRow must default to false when paymentComponentConfiguration is nil")
    }

    // MARK: - hideInfoForReturningUser

    @Test("hideInfoForReturningUser defaults to false when paymentComponentConfiguration is nil")
    func hideInfoForReturningUserDefaultsFalse() {
        let sut = makeSUT(paymentComponentConfiguration: nil)

        #expect(sut.hideInfoForReturningUser == false,
                "hideInfoForReturningUser must default to false when paymentComponentConfiguration is nil")
    }

    @Test("hideInfoForReturningUser reflects the paymentComponentConfiguration value")
    func hideInfoForReturningUserReflectsConfig() {
        let config = PaymentComponentConfiguration(hideInfoForReturningUser: true)
        let sut = makeSUT(paymentComponentConfiguration: config)

        #expect(sut.hideInfoForReturningUser == true,
                "hideInfoForReturningUser must reflect the value set in paymentComponentConfiguration")
    }

    // MARK: - shouldShowBrandedView

    @Test("shouldShowBrandedView is true for paymentComponent and fullVisible, false for invisible",
          arguments: zip(
            [GiniHealthAPILibrary.IngredientBrandTypeEnum.paymentComponent, .fullVisible, .invisible],
            [true, true, false]
          ))
    func shouldShowBrandedView(brandType: GiniHealthAPILibrary.IngredientBrandTypeEnum, expected: Bool) {
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

    // MARK: - isPaymentComponentUsed / tapOnPayInvoiceView

    /// Removes the payment-component-used flag before the body runs and restores
    /// a clean state afterwards, so each test starts and ends with no persisted value.
    private func withCleanPaymentComponentKey(_ body: () -> Void) {
        let key = "kPaymentComponentViewUsed"
        UserDefaults.standard.removeObject(forKey: key)
        defer { UserDefaults.standard.removeObject(forKey: key) }
        body()
    }

    @Test("isPaymentComponentUsed is false when the key has not been set")
    func isPaymentComponentUsedFalseInitially() {
        withCleanPaymentComponentKey {
            let sut = makeSUT()

            #expect(sut.isPaymentComponentUsed() == false,
                    "isPaymentComponentUsed must return false before tapOnPayInvoiceView is called")
        }
    }

    @Test("tapOnPayInvoiceView marks the component as used in UserDefaults")
    func tapOnPayInvoiceViewMarksAsUsed() {
        withCleanPaymentComponentKey {
            let sut = makeSUT()
            sut.tapOnPayInvoiceView()

            #expect(sut.isPaymentComponentUsed() == true,
                    "tapOnPayInvoiceView must set the UserDefaults usage flag to true")
        }
    }

    @Test("tapOnPayInvoiceView notifies delegate")
    func tapOnPayInvoiceViewNotifiesDelegate() {
        withCleanPaymentComponentKey {
            let sut = makeSUT()
            let delegate = MockPaymentComponentDelegate()
            sut.delegate = delegate

            sut.tapOnPayInvoiceView()

            #expect(delegate.didTapPayInvoiceCalled == true,
                    "tapOnPayInvoiceView must call didTapOnPayInvoice on the delegate")
        }
    }
}
