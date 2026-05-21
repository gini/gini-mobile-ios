//
//  PaymentInfoViewModelTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("PaymentInfoViewModel")
@MainActor
struct PaymentInfoViewModelTests {

    // MARK: - Helpers

    private func makeSUT(providers: [PaymentProvider] = [],
                         strings: PaymentInfoStrings = .test,
                         clientConfiguration: ClientConfiguration? = nil) -> PaymentInfoViewModel {
        PaymentInfoViewModel(paymentProviders: providers,
                             configuration: .test,
                             strings: strings,
                             poweredByGiniConfiguration: .test,
                             poweredByGiniStrings: .test,
                             clientConfiguration: clientConfiguration)
    }

    /** Builds a `PaymentInfoStrings` with the given questions and answers and no link placeholders in the body text. */
    private func makeStrings(questions: [String] = [],
                             answers: [String] = [],
                             supportedBanksFormat: String = "Banks") -> PaymentInfoStrings {
        PaymentInfoStrings(giniLink: .init(websiteText: "Gini",
                                           urlText: "https://gini.net"),
                           supportedBanksText: supportedBanksFormat,
                           titleText: "Info",
                           payBillsTitleText: "Bills",
                           payBillsDescriptionText: "Description",
                           privacyPolicy: .init(text: "Policy",
                                                urlText: "https://gini.net/privacy"),
                           faq: .init(titleText: "Questions",
                                      questions: questions,
                                      answers: answers,
                                      accessibilityExpandedText: "Expanded",
                                      accessibilityCollapsedText: "Collapsed"))
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

    // MARK: - accessibilityBankListText

    @Test("accessibilityBankListText joins provider names using the format string")
    func accessibilityBankListTextJoinsProviderNames() {
        let p1 = PaymentProvider.fixture(id: "ing", name: "ING")
        let p2 = PaymentProvider.fixture(id: "dkb", name: "DKB")
        let strings = makeStrings(supportedBanksFormat: "Banks: %@")
        let sut = makeSUT(providers: [p1, p2], strings: strings)

        #expect(sut.accessibilityBankListText == "Banks: ING, DKB",
                "accessibilityBankListText must join all provider names separated by \", \"")
    }

    @Test("accessibilityBankListText is empty substitution when no providers are given")
    func accessibilityBankListTextNoProviders() {
        let strings = makeStrings(supportedBanksFormat: "Banks: %@")
        let sut = makeSUT(providers: [], strings: strings)

        #expect(sut.accessibilityBankListText == "Banks: ",
                "accessibilityBankListText must substitute an empty string when there are no providers")
    }

    // MARK: - questions setup

    @Test("questions array count matches the input questions count")
    func questionsCountMatchesInput() {
        let strings = makeStrings(questions: ["Q1", "Q2"], answers: ["A1", "A2"])
        let sut = makeSUT(strings: strings)

        #expect(sut.questions.count == 2,
                "questions must have the same count as the input questions array")
    }

    @Test("questions are not extended on initialization")
    func questionsAreNotExtendedByDefault() {
        let strings = makeStrings(questions: ["Q"], answers: ["A"])
        let sut = makeSUT(strings: strings)

        #expect(sut.questions.first?.isExtended == false,
                "every question must have isExtended = false after initialization")
    }

    @Test("questions array is empty when no questions are provided")
    func questionsEmptyWhenNoneProvided() {
        let sut = makeSUT(strings: .test)

        #expect(sut.questions.isEmpty,
                "questions must be empty when the strings fixture supplies no questions")
    }

    // MARK: - infoQuestionHeaderViewModel

    @Test("infoQuestionHeaderViewModel returns model with the correct title")
    func infoQuestionHeaderViewModelTitle() {
        let strings = makeStrings(questions: ["FAQ Title"], answers: ["FAQ Answer"])
        let sut = makeSUT(strings: strings)

        let headerVM = sut.infoQuestionHeaderViewModel(at: 0)

        #expect(headerVM.titleText == "FAQ Title",
                "infoQuestionHeaderViewModel must expose the question title at the requested index")
    }

    // MARK: - infoAnswerCellModel

    @Test("infoAnswerCellModel returns model with the configured text color")
    func infoAnswerCellModelTextColor() {
        let strings = makeStrings(questions: ["Q"], answers: ["Some answer text"])
        let sut = makeSUT(strings: strings)

        let answerVM = sut.infoAnswerCellModel(at: 0)

        #expect(answerVM.answerTextColor == .label,
                "infoAnswerCellModel must use the answerCellTextColor from the configuration")
    }

    // MARK: - infoQuestionHeaderViewModel — toggle accessibility strings

    @Test("infoQuestionHeaderViewModel exposes the configured expanded accessibility text")
    func infoQuestionHeaderViewModelExpandedText() {
        let strings = makeStrings(questions: ["Q"], answers: ["A"])
        let sut = makeSUT(strings: strings)

        let header = sut.infoQuestionHeaderViewModel(at: 0)

        #expect(header.toggleAccessibilityStrings.expanded == "Expanded",
                "toggleAccessibilityStrings.expanded must match the strings fixture value")
    }

    @Test("infoQuestionHeaderViewModel exposes the configured collapsed accessibility text")
    func infoQuestionHeaderViewModelCollapsedText() {
        let strings = makeStrings(questions: ["Q"], answers: ["A"])
        let sut = makeSUT(strings: strings)

        let header = sut.infoQuestionHeaderViewModel(at: 0)

        #expect(header.toggleAccessibilityStrings.collapsed == "Collapsed",
                "toggleAccessibilityStrings.collapsed must match the strings fixture value")
    }

    @Test("infoQuestionHeaderViewModel returns isExpanded false when question is not extended")
    func infoQuestionHeaderViewModelIsNotExpandedByDefault() {
        let strings = makeStrings(questions: ["Q"], answers: ["A"])
        let sut = makeSUT(strings: strings)

        let header = sut.infoQuestionHeaderViewModel(at: 0)

        #expect(header.isExpanded == false,
                "isExpanded must be false when the question has not been toggled open")
    }

    @Test("infoQuestionHeaderViewModel returns isExpanded true after question is extended")
    func infoQuestionHeaderViewModelIsExpandedAfterToggle() {
        let strings = makeStrings(questions: ["Q"], answers: ["A"])
        let sut = makeSUT(strings: strings)
        sut.questions[0].isExtended = true

        let header = sut.infoQuestionHeaderViewModel(at: 0)

        #expect(header.isExpanded == true,
                "isExpanded must be true when the question has been marked as extended")
    }

    @Test("infoQuestionHeaderViewModel reflects title at the given index")
    func infoQuestionHeaderViewModelTitleAtIndex() {
        let strings = makeStrings(questions: ["First", "Second"], answers: ["A1", "A2"])
        let sut = makeSUT(strings: strings)

        #expect(sut.infoQuestionHeaderViewModel(at: 0).titleText == "First")
        #expect(sut.infoQuestionHeaderViewModel(at: 1).titleText == "Second")
    }

    @Test("infoQuestionHeaderViewModel for multiple questions each reports its own isExpanded state")
    func infoQuestionHeaderViewModelPerQuestionExpansion() {
        let strings = makeStrings(questions: ["Q1", "Q2"], answers: ["A1", "A2"])
        let sut = makeSUT(strings: strings)
        sut.questions[1].isExtended = true

        #expect(sut.infoQuestionHeaderViewModel(at: 0).isExpanded == false,
                "question 0 must remain collapsed")
        #expect(sut.infoQuestionHeaderViewModel(at: 1).isExpanded == true,
                "question 1 must be expanded after setting isExtended")
    }

    // MARK: - refreshAttributedContent

    @Test("refreshAttributedContent preserves the description text string")
    func refreshPreservesContent() {
        let sut = makeSUT()
        let textBefore = sut.payBillsDescriptionAttributedText.string

        sut.refreshAttributedContent()

        #expect(sut.payBillsDescriptionAttributedText.string == textBefore,
                "refreshAttributedContent must not alter the text content")
    }

    @Test("refreshAttributedContent preserves expanded state of open FAQ sections")
    func refreshPreservesExpandedSections() {
        let strings = makeStrings(questions: ["Q1", "Q2"], answers: ["A1", "A2"])
        let sut = makeSUT(strings: strings)
        sut.questions[1].isExtended = true

        sut.refreshAttributedContent()

        #expect(sut.questions[0].isExtended == false,
                "collapsed section must remain collapsed after refresh")
        #expect(sut.questions[1].isExtended == true,
                "expanded section must remain expanded after refresh")
    }

    @Test("refreshAttributedContent updates payBillsDescriptionLinkAttributes using links.font")
    func refreshUpdatesLinkAttributes() {
        let sut = makeSUT()
        let expectedSize = sut.configuration.links.font.pointSize

        sut.refreshAttributedContent()

        let resolvedFont = sut.payBillsDescriptionLinkAttributes[.font] as? UIFont
        #expect(resolvedFont?.pointSize == expectedSize,
                "payBillsDescriptionLinkAttributes must use configuration.links.font after refresh")
    }

    // MARK: - infoBankCellModel

    @Test("infoBankCellModel exposes the configured border color")
    func infoBankCellModelBorderColor() {
        let providers = [PaymentProvider.fixture()]
        let sut = makeSUT(providers: providers)

        let cellModel = sut.infoBankCellModel(at: 0)

        #expect(cellModel.borderColor == .systemGray4,
                "infoBankCellModel must use the bankCellBorderColor from the configuration")
    }

    @Test("infoBankCellModel falls back to an empty UIImage when provider has no icon data")
    func infoBankCellModelEmptyIcon() {
        let providers = [PaymentProvider.fixture()]
        let sut = makeSUT(providers: providers)

        let cellModel = sut.infoBankCellModel(at: 0)

        // Provider fixture uses empty Data(), so toImage returns nil → UIImage() fallback
        #expect(cellModel.bankImageIcon.size == .zero,
                "infoBankCellModel must fall back to an empty UIImage when the provider has no icon data")
    }
}
