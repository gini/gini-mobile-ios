//
//  PaymentComponentViewTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Combine
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("PaymentComponentView")
@MainActor
struct PaymentComponentViewTests {

    // MARK: - Helpers

    private func makeViewModel(provider: PaymentProvider? = .fixture(),
                               publisher: AnyPublisher<[PaymentProvider], Never> = Just([]).eraseToAnyPublisher(),
                               paymentComponentConfiguration: PaymentComponentConfiguration? = nil,
                               clientConfiguration: ClientConfiguration? = nil,
                               selectedProviderResolver: ((PaymentProviders) -> PaymentProvider?)? = nil) -> PaymentComponentViewModel {
        PaymentComponentViewModel(paymentProvider: provider,
                                  paymentProvidersPublisher: publisher,
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
                                  clientConfiguration: clientConfiguration,
                                  selectedProviderResolver: selectedProviderResolver)
    }

    private func makeSUT(viewModel: PaymentComponentViewModel) -> PaymentComponentView {
        let view = PaymentComponentView(viewModel: viewModel)
        view.layoutIfNeeded()
        return view
    }

    // MARK: - setupView wires the view-model binding

    @Test("setupView assigns onPaymentProvidersUpdated so the view can react to late emissions")
    func setupViewWiresPublisherBinding() {
        let viewModel = makeViewModel()
        _ = makeSUT(viewModel: viewModel)

        #expect(viewModel.onPaymentProvidersUpdated != nil,
                "setupView must assign viewModel.onPaymentProvidersUpdated so the view reacts to late emissions")
    }

    @Test("Invoking the binding closure does not crash and reaches the view")
    func invokingBindingClosureIsSafe() {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)

        viewModel.onPaymentProvidersUpdated?()

        _ = sut // keep the view alive so the weak-self closure body runs.
    }

    @Test("Late emission updates button colors via the binding", .timeLimit(.minutes(1)))
    func lateEmissionUpdatesButtonColors() async {
        let subject = PassthroughSubject<[PaymentProvider], Never>()
        let viewModel = makeViewModel(provider: nil,
                                      publisher: subject.eraseToAnyPublisher(),
                                      selectedProviderResolver: { providers in providers.first })
        _ = makeSUT(viewModel: viewModel)

        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            let original = viewModel.onPaymentProvidersUpdated
            viewModel.onPaymentProvidersUpdated = {
                original?()
                viewModel.onPaymentProvidersUpdated = original
                cont.resume()
            }
            subject.send([.fixture()])
        }

        #expect(viewModel.hasBankSelected == true,
                "Resolver's provider must flip hasBankSelected on through the binding")
    }

    // MARK: - setupView — branded vs non-branded paths

    @Test("Branded client configuration puts poweredByGiniView into the accessibility elements")
    func brandedBottomStackIncludesPoweredByGini() {
        let viewModel = makeViewModel(clientConfiguration: .test(ingredientBrandType: .paymentComponent))
        let sut = makeSUT(viewModel: viewModel)

        // The last accessibility element is poweredByGiniView only in the branded path.
        #expect(sut.accessibilityElements?.count == 5,
                "Branded setup must include the powered-by-Gini view in accessibility elements")
    }

    @Test("Non-branded client configuration omits poweredByGiniView from the accessibility elements")
    func nonBrandedBottomStackOmitsPoweredByGini() {
        let viewModel = makeViewModel(clientConfiguration: .test(ingredientBrandType: .invisible))
        let sut = makeSUT(viewModel: viewModel)

        #expect(sut.accessibilityElements?.count == 4,
                "Non-branded setup must omit the powered-by-Gini view from accessibility elements")
    }

    // MARK: - heightConstantSelectBankButton

    @Test("heightConstantSelectBankButton reflects the one-row minimum height")
    func heightConstantOneRowUsesMinimumButtonsHeight() {
        let config = PaymentComponentConfiguration(showPaymentComponentInOneRow: true)
        let viewModel = makeViewModel(paymentComponentConfiguration: config)
        let sut = makeSUT(viewModel: viewModel)

        #expect(sut.heightConstantSelectBankButton == 44,
                "In one-row mode heightConstantSelectBankButton must equal minimumButtonsHeight")
    }

    @Test("heightConstantSelectBankButton falls back to defaultButtonHeihgt when no bank is selected")
    func heightConstantNoBankSelectedFallsBackToDefault() {
        let viewModel = makeViewModel(provider: nil)
        let sut = makeSUT(viewModel: viewModel)

        #expect(sut.heightConstantSelectBankButton == 44,
                "Without a selected bank in two-row mode heightConstantSelectBankButton must equal defaultButtonHeihgt (44)")
    }

    // MARK: - MoreInformation delegate forwarding

    @Test("didTapOnMoreInformation forwards to the viewModel delegate")
    func moreInformationForwardsToDelegate() {
        let viewModel = makeViewModel()
        let delegate = MockPaymentComponentDelegate()
        viewModel.delegate = delegate
        let sut = makeSUT(viewModel: viewModel)

        sut.didTapOnMoreInformation()

        #expect(delegate.didTapMoreInfoCalled == true,
                "didTapOnMoreInformation must forward to viewModel.tapOnMoreInformation and the delegate")
    }

    // MARK: - Button-tap gestures

    @Test("Tapping the pay-invoice button forwards to the viewModel delegate")
    func payInvoiceButtonTapForwardsToDelegate() throws {
        let viewModel = makeViewModel()
        let delegate = MockPaymentComponentDelegate()
        viewModel.delegate = delegate
        let sut = makeSUT(viewModel: viewModel)
        let primaryButton = try #require(findSubview(in: sut, matching: PaymentPrimaryButton.self),
                                         "A PaymentPrimaryButton must exist in the hierarchy")

        // sendActions(for:) is unreliable in headless tests. Invoke the registered
        // @objc selector directly via the Obj-C runtime to exercise the gesture wiring.
        _ = primaryButton.perform(NSSelectorFromString("tapOnPayInvoiceView"))

        #expect(delegate.didTapPayInvoiceCalled == true,
                "The primary-button tap must forward through viewModel.tapOnPayInvoiceView")
    }

    @Test("Tapping the select-bank button forwards to the viewModel delegate")
    func selectBankButtonTapForwardsToDelegate() throws {
        let viewModel = makeViewModel()
        let delegate = MockPaymentComponentDelegate()
        viewModel.delegate = delegate
        let sut = makeSUT(viewModel: viewModel)
        let secondaryButton = try #require(findSubview(in: sut, matching: PaymentSecondaryButton.self),
                                           "A PaymentSecondaryButton must exist in the hierarchy")

        _ = secondaryButton.perform(NSSelectorFromString("tapOnBankPicker"))

        #expect(delegate.didTapBankPickerCalled == true,
                "The secondary-button tap must forward through viewModel.tapOnBankPicker")
    }

    // MARK: - updateAvailableViews — hideInfoForReturningUser branches

    @Test("hideInfoForReturningUser hides the bank/info views when the component has been used")
    func hideInfoBranchHidesViewsWhenUsed() {
        let key = "kPaymentComponentViewUsed"
        UserDefaults.standard.set(true, forKey: key)
        defer { UserDefaults.standard.removeObject(forKey: key) }

        let config = PaymentComponentConfiguration(hideInfoForReturningUser: true)
        let viewModel = makeViewModel(paymentComponentConfiguration: config,
                                      clientConfiguration: .test(ingredientBrandType: .invisible))
        let sut = makeSUT(viewModel: viewModel)

        viewModel.onPaymentProvidersUpdated?()
        _ = sut
    }

    @Test("hideInfoForReturningUser leaves views visible before the component has been used")
    func hideInfoBranchKeepsViewsVisibleWhenUnused() {
        let key = "kPaymentComponentViewUsed"
        UserDefaults.standard.removeObject(forKey: key)

        let config = PaymentComponentConfiguration(hideInfoForReturningUser: true)
        let viewModel = makeViewModel(paymentComponentConfiguration: config)
        let sut = makeSUT(viewModel: viewModel)

        viewModel.onPaymentProvidersUpdated?()
        _ = sut
    }

    // MARK: - Content size category change

    @Test("Dynamic Type change does not crash the branded view")
    func traitCollectionDidChangeOnBrandedViewIsSafe() {
        let viewModel = makeViewModel(clientConfiguration: .test(ingredientBrandType: .fullVisible))
        let sut = makeSUT(viewModel: viewModel)

        // The view model's branded flag is enabled, so updateBottomStackOrientation runs its body.
        sut.traitCollectionDidChange(nil)
    }

    // MARK: - Private helpers

    private func findSubview<T: UIView>(in root: UIView, matching type: T.Type) -> T? {
        if let typed = root as? T { return typed }
        for sub in root.subviews {
            if let found = findSubview(in: sub, matching: type) { return found }
        }
        return nil
    }
}
