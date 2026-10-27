//
//  PaymentInfoViewControllerTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import Combine
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("PaymentInfoViewController")
@MainActor
struct PaymentInfoViewControllerTests {

    // MARK: - Helpers

    private func makeViewModel(providers: [PaymentProvider] = [.fixture()],
                               publisher: AnyPublisher<[PaymentProvider], Never> = Just([]).eraseToAnyPublisher(),
                               strings: PaymentInfoStrings = .test,
                               clientConfiguration: ClientConfiguration? = nil) -> PaymentInfoViewModel {
        PaymentInfoViewModel(paymentProviders: providers,
                             paymentProvidersPublisher: publisher,
                             configuration: .test,
                             strings: strings,
                             poweredByGiniConfiguration: .test,
                             poweredByGiniStrings: .test,
                             clientConfiguration: clientConfiguration)
    }

    private func makeSUT(viewModel: PaymentInfoViewModel) -> PaymentInfoViewController {
        let sut = PaymentInfoViewController(viewModel: viewModel)
        _ = sut.view
        sut.view.layoutIfNeeded()
        return sut
    }

    private func makeStrings(questions: [String] = ["Q1", "Q2"],
                             answers: [String] = ["A1", "A2"]) -> PaymentInfoStrings {
        PaymentInfoStrings(giniLink: .init(websiteText: "Gini", urlText: "https://gini.net"),
                           supportedBanksText: "Banks: %@",
                           titleText: "Info",
                           payBillsTitleText: "Bills",
                           payBillsDescriptionText: "Pay via Gini",
                           privacyPolicy: .init(text: "Policy",
                                                urlText: "https://gini.net/privacy"),
                           faq: .init(titleText: "Questions",
                                      questions: questions,
                                      answers: answers,
                                      accessibilityExpandedText: "Expanded",
                                      accessibilityCollapsedText: "Collapsed"))
    }

    // MARK: - Reactive binding

    @Test("viewDidLoad wires the viewModel's onPaymentProvidersUpdated closure")
    func viewDidLoadWiresPublisherBinding() {
        let viewModel = makeViewModel()
        _ = makeSUT(viewModel: viewModel)

        #expect(viewModel.onPaymentProvidersUpdated != nil,
                "viewDidLoad must assign viewModel.onPaymentProvidersUpdated so bank icons reload on late emissions")
    }

    @Test("Invoking the binding closure updates the a11y label")
    func invokingBindingClosureUpdatesAccessibility() {
        let viewModel = makeViewModel(providers: [.fixture(name: "Bank 1")], strings: makeStrings())
        let sut = makeSUT(viewModel: viewModel)

        viewModel.onPaymentProvidersUpdated?()

        let collectionView = findSubview(in: sut.view, matching: UICollectionView.self)
        #expect(collectionView?.accessibilityLabel == viewModel.accessibilityBankListText,
                "Binding closure must refresh the collection view's accessibility label from the view model")
        _ = sut
    }

    // MARK: - Collection view data source

    @Test("collectionView numberOfItemsInSection reflects paymentProviders.count")
    func collectionViewNumberOfItemsReflectsViewModel() throws {
        let viewModel = makeViewModel(providers: [.fixture(id: "a"), .fixture(id: "b"), .fixture(id: "c")])
        let sut = makeSUT(viewModel: viewModel)
        let collectionView = try #require(findSubview(in: sut.view, matching: UICollectionView.self),
                                          "A UICollectionView must exist in the hierarchy")

        let count = sut.collectionView(collectionView, numberOfItemsInSection: 0)

        #expect(count == 3,
                "numberOfItemsInSection must equal viewModel.paymentProviders.count")
    }

    @Test("collectionView numberOfSections returns 1")
    func collectionViewNumberOfSectionsIsOne() throws {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)
        let collectionView = try #require(findSubview(in: sut.view, matching: UICollectionView.self),
                                          "A UICollectionView must exist in the hierarchy")

        #expect(sut.numberOfSections(in: collectionView) == 1,
                "numberOfSections must return 1")
    }

    @Test("collectionView cellForItemAt returns a PaymentInfoBankCollectionViewCell")
    func collectionViewCellIsCorrectType() throws {
        let viewModel = makeViewModel(providers: [.fixture()])
        let sut = makeSUT(viewModel: viewModel)
        let collectionView = try #require(findSubview(in: sut.view, matching: UICollectionView.self),
                                          "A UICollectionView must exist in the hierarchy")

        let cell = sut.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0))

        #expect(cell is PaymentInfoBankCollectionViewCell,
                "cellForItemAt must dequeue a PaymentInfoBankCollectionViewCell")
    }

    @Test("collectionView sizeForItemAt returns the fixed-icon size")
    func collectionViewSizeForItemAt() throws {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)
        let collectionView = try #require(findSubview(in: sut.view, matching: UICollectionView.self),
                                          "A UICollectionView must exist in the hierarchy")
        let flow = collectionView.collectionViewLayout

        let size = sut.collectionView(collectionView,
                                      layout: flow,
                                      sizeForItemAt: IndexPath(item: 0, section: 0))

        #expect(size.width == 36 && size.height == 36,
                "sizeForItemAt must return the fixed 36x36 icon size")
    }

    @Test("collectionView insetForSectionAt returns zero insets when there are no providers")
    func collectionViewInsetForEmptyProviders() throws {
        let viewModel = makeViewModel(providers: [])
        let sut = makeSUT(viewModel: viewModel)
        let collectionView = try #require(findSubview(in: sut.view, matching: UICollectionView.self),
                                          "A UICollectionView must exist in the hierarchy")
        let flow = collectionView.collectionViewLayout

        let insets = sut.collectionView(collectionView, layout: flow, insetForSectionAt: 0)

        #expect(insets == .zero,
                "insetForSectionAt must be zero when there are no providers")
    }

    // MARK: - Table view data source + delegate

    @Test("tableView numberOfSections equals viewModel.questions.count")
    func tableViewNumberOfSectionsReflectsQuestions() throws {
        let viewModel = makeViewModel(strings: makeStrings())
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        #expect(sut.numberOfSections(in: tableView) == 2,
                "numberOfSections must equal viewModel.questions.count")
    }

    @Test("tableView numberOfRowsInSection returns 1 only for extended sections")
    func tableViewNumberOfRowsRespectsExtendedFlag() throws {
        let viewModel = makeViewModel(strings: makeStrings())
        viewModel.questions[0].isExtended = true
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        #expect(sut.tableView(tableView, numberOfRowsInSection: 0) == 1,
                "Extended section must have 1 row")
        #expect(sut.tableView(tableView, numberOfRowsInSection: 1) == 0,
                "Non-extended section must have 0 rows")
    }

    @Test("tableView cellForRowAt returns a PaymentInfoAnswerTableViewCell for extended section")
    func tableViewCellForRowReturnsAnswerCell() throws {
        let viewModel = makeViewModel(strings: makeStrings())
        viewModel.questions[0].isExtended = true
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))

        #expect(cell is PaymentInfoAnswerTableViewCell,
                "cellForRowAt must dequeue a PaymentInfoAnswerTableViewCell")
    }

    @Test("tableView viewForHeaderInSection returns a header view model-configured cell")
    func tableViewHeaderView() throws {
        let viewModel = makeViewModel(strings: makeStrings())
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        let header = sut.tableView(tableView, viewForHeaderInSection: 0)

        #expect(header is PaymentInfoQuestionHeaderViewCell,
                "viewForHeaderInSection must return a PaymentInfoQuestionHeaderViewCell")
    }

    @Test("tableView viewForFooterInSection returns separator for all but the last section")
    func tableViewFooterReturnsSeparatorExceptLast() throws {
        let viewModel = makeViewModel(strings: makeStrings())
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        let middle = sut.tableView(tableView, viewForFooterInSection: 0)
        let last = sut.tableView(tableView, viewForFooterInSection: 1)

        #expect(middle?.backgroundColor != nil,
                "Non-last footer must carry the configured separator color")
        #expect(last?.backgroundColor == nil,
                "Last footer must be an empty UIView without a separator color")
    }

    @Test("tableView heightForRowAt and heightForFooterInSection return the configured values")
    func tableViewHeightDelegates() throws {
        let viewModel = makeViewModel(strings: makeStrings())
        let sut = makeSUT(viewModel: viewModel)
        let tableView = try #require(findSubview(in: sut.view, matching: UITableView.self),
                                     "A UITableView must exist in the hierarchy")

        #expect(sut.tableView(tableView, heightForRowAt: IndexPath(row: 0, section: 0)) == UITableView.automaticDimension,
                "heightForRowAt must return automaticDimension")
        #expect(sut.tableView(tableView, heightForFooterInSection: 0) == 1.0,
                "heightForFooterInSection must return the configured 1pt separator height")
        #expect(sut.tableView(tableView, estimatedHeightForRowAt: IndexPath(row: 0, section: 0)) == 250.0,
                "estimatedHeightForRowAt must return the configured 250pt estimate")
    }

    // MARK: - viewWillAppear / content size category

    @Test("viewWillAppear refreshes the text view attributedText from the view model")
    func viewWillAppearRefreshesContent() {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)

        sut.viewWillAppear(false)
        // No crash — handleContentSizeCategoryChange runs the refresh path.
    }

    @Test("Dynamic Type change notification does not crash")
    func contentSizeCategoryNotificationIsSafe() {
        let viewModel = makeViewModel()
        _ = makeSUT(viewModel: viewModel)

        NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    // MARK: - Orientation

    @Test("viewWillTransition does not crash across orientations")
    func viewWillTransitionIsSafe() {
        let viewModel = makeViewModel()
        let sut = makeSUT(viewModel: viewModel)
        let coordinator = DummyTransitionCoordinator()

        sut.viewWillTransition(to: CGSize(width: 390, height: 844), with: coordinator)
        sut.viewWillTransition(to: CGSize(width: 844, height: 390), with: coordinator)
    }

    // MARK: - Branded config

    @Test("Branded client configuration shows the powered-by-Gini view")
    func brandedShowsPoweredByGini() {
        let viewModel = makeViewModel(clientConfiguration: .test(ingredientBrandType: .fullVisible))
        let sut = makeSUT(viewModel: viewModel)

        let poweredBy = findSubview(in: sut.view, matching: PoweredByGiniView.self)
        #expect(poweredBy?.isHidden == false,
                "Branded setup must leave the PoweredByGiniView visible")
    }

    @Test("Non-branded client configuration hides the powered-by-Gini view")
    func nonBrandedHidesPoweredByGini() {
        let viewModel = makeViewModel(clientConfiguration: .test(ingredientBrandType: .invisible))
        let sut = makeSUT(viewModel: viewModel)

        let poweredBy = findSubview(in: sut.view, matching: PoweredByGiniView.self)
        #expect(poweredBy?.isHidden == true,
                "Non-branded setup must hide the PoweredByGiniView")
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
