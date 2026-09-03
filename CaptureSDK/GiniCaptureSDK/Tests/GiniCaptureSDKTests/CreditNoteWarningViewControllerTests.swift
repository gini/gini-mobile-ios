//
//  CreditNoteWarningViewControllerTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

@Suite("CreditNoteWarningViewController")
struct CreditNoteWarningViewControllerTests {

    private typealias Helper = ViewHierarchyTestHelper
    private typealias Strings = CreditNoteWarningViewController.Strings

    @MainActor
    private func makeSUT(onCancel: @escaping () -> Void = {},
                         onProceed: @escaping () -> Void = {}) -> CreditNoteWarningViewController {
        let sut = CreditNoteWarningViewController(onCancel: onCancel,
                                                  onProceed: onProceed)
        sut.loadViewIfNeeded()
        return sut
    }

    // MARK: - Content

    @Test("Title and description show the localized credit note warning strings")
    @MainActor func showsLocalizedTitleAndDescription() throws {
        let sut = makeSUT()

        #expect(Helper.firstLabel(withText: Strings.title, in: sut.view) != nil,
                "Title label should show the localized credit note warning title")
        #expect(Helper.firstLabel(withText: Strings.description, in: sut.view) != nil,
                "Description label should show the localized credit note warning description")

        /// The localized values must resolve to real copy, not fall back to the keys.
        #expect(Strings.title != Strings.titleKey)
        #expect(Strings.description != Strings.descriptionKey)
    }

    @Test("Icon uses the error icon with the warning tint and error background")
    @MainActor func iconUsesErrorStyling() throws {
        let sut = makeSUT()

        let imageView = try #require(Helper.firstView(ofType: UIImageView.self, in: sut.view))
        #expect(imageView.image != nil)
        #expect(imageView.image == CreditNoteWarningViewController.Images.errorIcon)
        #expect(Helper.colorsEqual(imageView.tintColor,
                                   CreditNoteWarningViewController.Colors.errorTintColor))
        #expect(Helper.colorsEqual(imageView.superview?.backgroundColor,
                                   CreditNoteWarningViewController.Colors.imageBGColor))
    }

    // MARK: - Buttons

    @Test("Primary button is Cancel and secondary button is Proceed, primary first")
    @MainActor func buttonTitlesAndOrder() throws {
        let sut = makeSUT()

        #expect(sut.buttonsViewContainer.primaryButton.title(for: .normal) == Strings.cancelButton)
        #expect(sut.buttonsViewContainer.secondaryButton.title(for: .normal) == Strings.proceedButton)
        #expect(Strings.cancelButton != Strings.cancelButtonKey)
        #expect(Strings.proceedButton != Strings.proceedButtonKey)

        let stack = try #require(Helper.firstView(ofType: UIStackView.self,
                                                  in: sut.buttonsViewContainer))
        #expect(stack.arrangedSubviews.first === sut.buttonsViewContainer.primaryButton)
        #expect(stack.arrangedSubviews.last === sut.buttonsViewContainer.secondaryButton)
    }

    @Test("Tapping Cancel invokes onCancel only")
    @MainActor func cancelTapInvokesOnCancel() {
        var cancelCallCount = 0
        var proceedCallCount = 0
        let sut = makeSUT(onCancel: { cancelCallCount += 1 },
                          onProceed: { proceedCallCount += 1 })

        Helper.tap(sut.buttonsViewContainer.primaryButton)

        #expect(cancelCallCount == 1)
        #expect(proceedCallCount == 0)
    }

    @Test("Tapping Proceed invokes onProceed only")
    @MainActor func proceedTapInvokesOnProceed() {
        var cancelCallCount = 0
        var proceedCallCount = 0
        let sut = makeSUT(onCancel: { cancelCallCount += 1 },
                          onProceed: { proceedCallCount += 1 })

        Helper.tap(sut.buttonsViewContainer.secondaryButton)

        #expect(cancelCallCount == 0)
        #expect(proceedCallCount == 1)
    }
}
