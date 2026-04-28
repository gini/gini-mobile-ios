//
//  InstallAppBottomViewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("InstallAppBottomViewModel")
@MainActor
struct InstallAppBottomViewModelTests {

    // MARK: - Helpers

    private func makeSUT(provider: PaymentProvider? = .make(name: "Test Bank"),
                         clientConfiguration: ClientConfiguration? = nil) -> InstallAppBottomViewModel {
        InstallAppBottomViewModel(selectedPaymentProvider: provider,
                                  installAppConfiguration: .test,
                                  strings: .test,
                                  primaryButtonConfiguration: .test,
                                  poweredByGiniConfiguration: .test,
                                  poweredByGiniStrings: .test,
                                  clientConfiguration: clientConfiguration)
    }

    // MARK: - [BANK] substitution in titleText

    @Test("titleText substitutes [BANK] with the provider name")
    func titleTextSubstitutesBankName() {
        let sut = makeSUT(provider: .make(name: "N26"))

        #expect(sut.titleText == "Install N26",
                "titleText must replace [BANK] with the selected payment provider's name")
    }

    @Test("titleText substitutes [BANK] with empty string when provider is nil")
    func titleTextWithNilProvider() {
        let sut = makeSUT(provider: nil)

        #expect(sut.titleText == "Install ",
                "titleText must replace [BANK] with an empty string when no provider is given")
    }

    // MARK: - moreInformationLabelText

    /// In a unit-test environment, no custom URL scheme can be opened, so `isBankInstalled` is always false.
    /// The note pattern is therefore always selected in tests.
    @Test("moreInformationLabelText uses notePattern because bank is not installed in test environment")
    func moreInformationLabelTextUsesNotePattern() {
        let sut = makeSUT(provider: .make(name: "DKB"))

        #expect(sut.moreInformationLabelText == "Note: install DKB",
                "moreInformationLabelText must use moreInformationNotePattern when bank is not installed")
    }

    @Test("moreInformationLabelText substitutes [BANK] with empty string when provider is nil")
    func moreInformationLabelTextNilProvider() {
        let sut = makeSUT(provider: nil)

        #expect(sut.moreInformationLabelText == "Note: install ",
                "moreInformationLabelText must replace [BANK] with empty string when no provider is given")
    }

    // MARK: - bankImageIcon

    @Test("bankImageIcon falls back to an empty UIImage when provider has no icon data")
    func bankImageIconIsImageWithEmptyData() {
        let sut = makeSUT(provider: .make())

        // UIImage(data: Data()) returns nil, so iconData.toImage ?? UIImage() resolves to UIImage()
        #expect(sut.bankImageIcon.size == .zero,
                "bankImageIcon must fall back to an empty UIImage with zero size when the provider has no icon data")
        #expect(sut.bankImageIcon.cgImage == nil,
                "bankImageIcon fallback image must not have backing CGImage data when the provider has no icon data")
    }

    // MARK: - shouldShowBrandedView

    @Test("shouldShowBrandedView is true only for fullVisible",
          arguments: zip(
            [GiniHealthAPILibrary.IngredientBrandTypeEnum.fullVisible, .paymentComponent, .invisible],
            [true, false, false]
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

    // MARK: - Delegate forwarding

    @Test("didTapOnContinue notifies the delegate")
    func didTapOnContinueNotifiesDelegate() {
        let sut = makeSUT()
        let delegate = MockInstallAppDelegate()
        sut.viewDelegate = delegate

        sut.didTapOnContinue()

        #expect(delegate.didTapContinueCalled == true,
                "didTapOnContinue must call didTapOnContinue on the viewDelegate")
    }
}
