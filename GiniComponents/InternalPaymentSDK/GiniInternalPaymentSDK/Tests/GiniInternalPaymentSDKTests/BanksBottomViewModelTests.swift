//
//  BanksBottomViewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Combine
import UIKit
import GiniHealthAPILibrary
import GiniUtilites
@testable import GiniInternalPaymentSDK

@Suite("BanksBottomViewModel")
@MainActor
struct BanksBottomViewModelTests {

    // MARK: - Helpers

    private func makeSUT(providers: [PaymentProvider] = [.fixture()],
                         selectedProvider: PaymentProvider? = nil,
                         publisher: AnyPublisher<[PaymentProvider], Never> = Just([]).eraseToAnyPublisher(),
                         urlOpener: MockURLOpener = MockURLOpener(),
                         clientConfiguration: ClientConfiguration? = nil) -> BanksBottomViewModel {
        BanksBottomViewModel(paymentProviders: providers,
                             paymentProvidersPublisher: publisher,
                             selectedPaymentProvider: selectedProvider,
                             configuration: .test,
                             strings: .test,
                             poweredByGiniConfiguration: .test,
                             poweredByGiniStrings: .test,
                             moreInformationConfiguration: .test,
                             moreInformationStrings: .test,
                             paymentInfoConfiguration: .test,
                             paymentInfoStrings: .test,
                             urlOpener: URLOpener(urlOpener),
                             clientConfiguration: clientConfiguration)
    }

    // MARK: - Reactive publisher subscription

    @Test("Replays the publisher's current value on init", .timeLimit(.minutes(1)))
    func replaysCurrentValueOnInit() async {
        let subject = CurrentValueSubject<[PaymentProvider], Never>([.fixture()])
        let sut = makeSUT(providers: [],
                          publisher: subject.eraseToAnyPublisher())

        await awaitProvidersUpdate(on: sut)

        #expect(sut.paymentProviders.count == 1,
                "CurrentValueSubject replays its current value on subscribe; init must apply it")
    }

    @Test("Late publisher emission reapplies providers and fires the update closure", .timeLimit(.minutes(1)))
    func lateEmissionReappliesAndFiresClosure() async {
        let subject = CurrentValueSubject<[PaymentProvider], Never>([])
        let sut = makeSUT(providers: [],
                          publisher: subject.eraseToAnyPublisher())

        await awaitProvidersUpdate(on: sut) {
            subject.send([.fixture(id: "a"), .fixture(id: "b")])
        }

        #expect(sut.paymentProviders.count == 2,
                "paymentProviders must reflect the latest emission from the publisher")
    }

    @Test("Empty emission still fires the update closure", .timeLimit(.minutes(1)))
    func emptyEmissionStillFiresClosure() async {
        let subject = CurrentValueSubject<[PaymentProvider], Never>([.fixture()])
        let sut = makeSUT(providers: [],
                          publisher: subject.eraseToAnyPublisher())

        await awaitProvidersUpdate(on: sut)

        await awaitProvidersUpdate(on: sut) {
            subject.send([])
        }

        #expect(sut.paymentProviders.isEmpty,
                "An empty emission must drain the applied providers")
    }

    @Test("Late emission applies the iOS-platform filter", .timeLimit(.minutes(1)))
    func lateEmissionAppliesIOSFilter() async {
        let subject = CurrentValueSubject<[PaymentProvider], Never>([])
        let sut = makeSUT(providers: [],
                          publisher: subject.eraseToAnyPublisher())

        let iosProvider = PaymentProvider.fixture(id: "ios-ok")
        let androidOnly = PaymentProvider.fixture(id: "android-only",
                                                  gpcSupportedPlatforms: [.android],
                                                  openWithSupportedPlatforms: [])

        await awaitProvidersUpdate(on: sut) {
            subject.send([iosProvider, androidOnly])
        }

        #expect(sut.paymentProviders.count == 1,
                "Android-only providers must be filtered out on late emissions too")
        #expect(sut.paymentProviders.first?.paymentProvider.id == "ios-ok",
                "Only the iOS-supported provider should remain after filtering")
    }

    @Test("Delivers emission on the main queue regardless of send queue", .timeLimit(.minutes(1)))
    func deliversOnMainQueueFromBackgroundSend() async {
        let subject = CurrentValueSubject<[PaymentProvider], Never>([])
        let sut = makeSUT(providers: [],
                          publisher: subject.eraseToAnyPublisher())

        let onMain = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            sut.onPaymentProvidersUpdated = {
                sut.onPaymentProvidersUpdated = nil
                cont.resume(returning: Thread.isMainThread)
            }
            DispatchQueue.global().async {
                subject.send([.fixture()])
            }
        }

        #expect(onMain,
                "Subscription uses .receive(on: .main); closure must fire on the main thread even when send happens on a background queue")
    }

    /// Waits for the next `onPaymentProvidersUpdated` invocation. Pass a
    /// trigger closure to run after installing the one-shot handler — useful
    /// for `subject.send(...)` calls. Deterministic, no sleep.
    private func awaitProvidersUpdate(on sut: BanksBottomViewModel,
                                      trigger: (() -> Void)? = nil) async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            sut.onPaymentProvidersUpdated = {
                sut.onPaymentProvidersUpdated = nil
                cont.resume()
            }
            trigger?()
        }
    }

    // MARK: - Filtering

    @Test("Filters out android-only providers with no iOS platform support")
    func androidOnlyProviderIsExcluded() {
        let androidOnly = PaymentProvider.fixture(id: "android-only",
                                                  gpcSupportedPlatforms: [.android],
                                                  openWithSupportedPlatforms: [])
        let sut = makeSUT(providers: [androidOnly])

        #expect(sut.paymentProviders.isEmpty,
                "Provider with no iOS platform support must be excluded from the list")
    }

    @Test("Includes provider with iOS in gpcSupportedPlatforms")
    func gpcIosProviderIsIncluded() {
        let provider = PaymentProvider.fixture(gpcSupportedPlatforms: [.ios])
        let sut = makeSUT(providers: [provider])

        #expect(sut.paymentProviders.count == 1,
                "Provider with iOS in gpcSupportedPlatforms must be included")
    }

    @Test("Includes provider with iOS in openWithSupportedPlatforms")
    func openWithIosProviderIsIncluded() {
        let provider = PaymentProvider.fixture(gpcSupportedPlatforms: [],
                                               openWithSupportedPlatforms: [.ios])
        let sut = makeSUT(providers: [provider])

        #expect(sut.paymentProviders.count == 1,
                "Provider with iOS in openWithSupportedPlatforms must be included")
    }

    // MARK: - Deduplication

    @Test("Duplicate provider ids produce a single entry")
    func duplicateIdsAreDeduped() {
        let p1 = PaymentProvider.fixture(id: "same-id", name: "Bank A")
        let p2 = PaymentProvider.fixture(id: "same-id", name: "Bank B")
        let sut = makeSUT(providers: [p1, p2])

        #expect(sut.paymentProviders.count == 1,
                "Duplicate provider ids must be deduplicated to a single entry")
    }

    // MARK: - Sorting

    @Test("Installed provider appears before uninstalled provider")
    func installedProviderSortsFirst() {
        let installed = PaymentProvider.fixture(id: "installed",
                                             name: "Installed Bank",
                                             appSchemeIOS: "installedbank://")
        let notInstalled = PaymentProvider.fixture(id: "not-installed",
                                                name: "Not Installed",
                                                appSchemeIOS: "notinstalled://")
        let mockOpener = MockURLOpener(installedScheme: "installedbank")
        let sut = makeSUT(providers: [notInstalled, installed], urlOpener: mockOpener)

        #expect(sut.paymentProviders.first?.paymentProvider.id == "installed",
                "Installed provider must sort before uninstalled provider")
    }

    @Test("Among uninstalled providers, lower index sorts first")
    func lowerIndexSortsFirst() {
        let high = PaymentProvider.fixture(id: "high", index: 5)
        let low = PaymentProvider.fixture(id: "low", index: 1)
        let sut = makeSUT(providers: [high, low])

        #expect(sut.paymentProviders.first?.paymentProvider.id == "low",
                "Among equally uninstalled providers, lower index must sort first")
    }

    // MARK: - Selection state

    @Test("Provider matching selectedPaymentProvider is marked isSelected")
    func selectedProviderIsMarked() {
        let selected = PaymentProvider.fixture(id: "selected-id")
        let sut = makeSUT(providers: [selected], selectedProvider: selected)

        #expect(sut.paymentProviders.first?.isSelected == true,
                "Provider whose id matches selectedPaymentProvider must have isSelected = true")
    }

    @Test("Provider not matching selectedPaymentProvider has isSelected = false")
    func nonSelectedProviderIsNotMarked() {
        let provider = PaymentProvider.fixture(id: "other-id")
        let selected = PaymentProvider.fixture(id: "selected-id")
        let sut = makeSUT(providers: [provider], selectedProvider: selected)

        #expect(sut.paymentProviders.first?.isSelected == false,
                "Provider whose id does not match selectedPaymentProvider must have isSelected = false")
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

    // MARK: - paymentProvidersViewModel

    @Test("paymentProvidersViewModel exposes the payment provider name")
    func paymentProvidersViewModelBankName() throws {
        let provider = PaymentProvider.fixture(name: "My Bank")
        let sut = makeSUT(providers: [provider])
        let entry = try #require(sut.paymentProviders.first,
                                 "paymentProviders must not be empty")
        let cellModel = sut.paymentProvidersViewModel(paymentProvider: entry)

        #expect(cellModel.bankName == "My Bank",
                "Cell model must expose the payment provider's name")
    }

}
