//
//  BanksBottomViewTests.swift
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

@Suite("BanksBottomView")
@MainActor
struct BanksBottomViewTests {

    // MARK: - Helpers

    private func makeViewModel(providers: [PaymentProvider] = [.fixture()],
                               publisher: AnyPublisher<[PaymentProvider], Never> = Just([]).eraseToAnyPublisher(),
                               clientConfiguration: ClientConfiguration? = nil) -> BanksBottomViewModel {
        BanksBottomViewModel(paymentProviders: providers,
                             paymentProvidersPublisher: publisher,
                             selectedPaymentProvider: nil,
                             configuration: .test,
                             strings: .test,
                             poweredByGiniConfiguration: .test,
                             poweredByGiniStrings: .test,
                             moreInformationConfiguration: .test,
                             moreInformationStrings: .test,
                             paymentInfoConfiguration: .test,
                             paymentInfoStrings: .test,
                             urlOpener: URLOpener(MockURLOpener()),
                             clientConfiguration: clientConfiguration)
    }

    private func makeSUT(viewModel: BanksBottomViewModel) -> BanksBottomView {
        let sut = BanksBottomView(viewModel: viewModel, bottomSheetConfiguration: .test)
        _ = sut.view
        sut.view.layoutIfNeeded()
        return sut
    }

    // MARK: - Reactive binding

    @Test("viewDidLoad wires the viewModel's onPaymentProvidersUpdated closure")
    func viewDidLoadWiresPublisherBinding() {
        let viewModel = makeViewModel()
        _ = makeSUT(viewModel: viewModel)

        #expect(viewModel.onPaymentProvidersUpdated != nil,
                "viewDidLoad must assign viewModel.onPaymentProvidersUpdated so the sheet reloads on late emissions")
    }

    @Test("Invoking the binding closure does not crash")
    func invokingBindingClosureIsSafe() {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)

        viewModel.onPaymentProvidersUpdated?()
        _ = sut
    }

    // MARK: - Branded accessory

    @Test("Branded client configuration shows the powered-by-Gini view in the bottom stack")
    func brandedBottomStackIncludesPoweredByGini() {
        let viewModel = makeViewModel(clientConfiguration: .test(ingredientBrandType: .fullVisible))
        let sut = makeSUT(viewModel: viewModel)

        let hasPoweredByGini = findSubview(in: sut.view, matching: PoweredByGiniView.self) != nil
        #expect(hasPoweredByGini,
                "Branded setup must insert PoweredByGiniView into the bottom stack")
    }

    @Test("Non-branded client configuration omits the powered-by-Gini view")
    func nonBrandedBottomStackOmitsPoweredByGini() {
        let viewModel = makeViewModel(clientConfiguration: .test(ingredientBrandType: .invisible))
        let sut = makeSUT(viewModel: viewModel)

        let hasPoweredByGini = findSubview(in: sut.view, matching: PoweredByGiniView.self) != nil
        #expect(hasPoweredByGini == false,
                "Non-branded setup must not insert PoweredByGiniView")
    }

    // MARK: - Table view delegate / data source

    @Test("tableView numberOfRowsInSection reflects viewModel.paymentProviders.count")
    func numberOfRowsReflectsViewModel() throws {
        let viewModel = makeViewModel(providers: [.fixture(id: "a"), .fixture(id: "b")])
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        let rows = sut.tableView(tableView, numberOfRowsInSection: 0)

        #expect(rows == 2,
                "Row count must match viewModel.paymentProviders.count")
    }

    @Test("tableView cellForRowAt returns the configured bank-selection cell")
    func cellForRowConfiguresCell() throws {
        let viewModel = makeViewModel(providers: [.fixture(id: "a", name: "Bank A")])
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        #expect(cell is BankSelectionTableViewCell,
                "cellForRowAt must dequeue a BankSelectionTableViewCell")
    }

    @Test("tableView didSelectRowAt forwards the tapped provider to the view delegate")
    func didSelectRowForwardsToDelegate() throws {
        let provider = PaymentProvider.fixture(id: "selected", name: "Selected Bank")
        let viewModel = makeViewModel(providers: [provider])
        let delegate = MockBanksSelectionDelegate()
        viewModel.viewDelegate = delegate
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))

        #expect(delegate.selectedProvider?.id == "selected",
                "didSelectRowAt must forward the row's provider to the view delegate")
    }

    // MARK: - Orientation + content size category

    @Test("viewWillTransition does not crash when invoked with portrait size")
    func viewWillTransitionPortraitIsSafe() {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)
        let coordinator = DummyTransitionCoordinator()

        sut.viewWillTransition(to: CGSize(width: 390, height: 844), with: coordinator)
    }

    @Test("viewWillTransition does not crash when invoked with landscape size")
    func viewWillTransitionLandscapeIsSafe() {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)
        let coordinator = DummyTransitionCoordinator()

        sut.viewWillTransition(to: CGSize(width: 844, height: 390), with: coordinator)
    }

    @Test("contentSizeCategory change notification does not crash")
    func contentSizeCategoryNotificationIsSafe() {
        let viewModel = makeViewModel()
        _ = makeSUT(viewModel: viewModel)

        NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    // MARK: - MoreInformation extension

    @Test("didTapOnMoreInformation does not crash when presenting")
    func didTapOnMoreInformationIsSafe() {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)

        // The view is not in a window, so present will no-op without crashing.
        sut.didTapOnMoreInformation()
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

/// Fulfils the UIKit transition coordinator contract with no-op defaults — enough
/// to drive viewWillTransition without presenting a real view hierarchy.
final class DummyTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {
    var isAnimated: Bool { true }
    var presentationStyle: UIModalPresentationStyle { .none }
    var initiallyInteractive: Bool { false }
    var isInterruptible: Bool { false }
    var isInteractive: Bool { false }
    var isCancelled: Bool { false }
    var transitionDuration: TimeInterval { 0 }
    var percentComplete: CGFloat { 0 }
    var completionVelocity: CGFloat { 0 }
    var completionCurve: UIView.AnimationCurve { .linear }
    var containerView: UIView { UIView() }
    var targetTransform: CGAffineTransform { .identity }

    func animate(alongsideTransition animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?,
                 completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransition(in view: UIView?,
                                    animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?,
                                    completion: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransition(in view: UIView?,
                                    animation: ((any UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        return true
    }

    func notifyWhenInteractionEnds(_ handler: @escaping (any UIViewControllerTransitionCoordinatorContext) -> Void) {
        handler(self)
    }

    func notifyWhenInteractionChanges(_ handler: @escaping (any UIViewControllerTransitionCoordinatorContext) -> Void) {
        handler(self)
    }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? { nil }
    func view(forKey key: UITransitionContextViewKey) -> UIView? { nil }
}
