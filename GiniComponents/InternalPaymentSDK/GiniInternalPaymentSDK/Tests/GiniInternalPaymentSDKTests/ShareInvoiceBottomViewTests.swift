//
//  ShareInvoiceBottomViewTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthAPILibrary
@testable import GiniInternalPaymentSDK

@Suite("ShareInvoiceBottomView")
@MainActor
struct ShareInvoiceBottomViewTests {

    // MARK: - Helpers

    private func makeSUT(provider: PaymentProvider? = .fixture(name: "Test Bank")) -> ShareInvoiceBottomView {
        let viewModel = ShareInvoiceBottomViewModel(selectedPaymentProvider: provider,
                                                    configuration: .test,
                                                    strings: .test,
                                                    primaryButtonConfiguration: .test,
                                                    poweredByGiniConfiguration: .test,
                                                    poweredByGiniStrings: .test,
                                                    qrCodeData: Data(),
                                                    paymentInfo: nil,
                                                    paymentRequestId: "req-123",
                                                    clientConfiguration: nil)
        let sut = ShareInvoiceBottomView(viewModel: viewModel, bottomSheetConfiguration: .test)
        _ = sut.view // force view load
        return sut
    }

    /**
     Recursively searches `root` for the split-stack view: the first `UIStackView`
     whose two arranged subviews are themselves `UIStackView`s.
     This uniquely identifies the private `splitStacKView` property.
     */
    private func findSplitStackView(in root: UIView) -> UIStackView? {
        if let stack = root as? UIStackView,
           stack.arrangedSubviews.count == 2,
           stack.arrangedSubviews.allSatisfy({ $0 is UIStackView }) {
            return stack
        }
        for sub in root.subviews {
            if let found = findSplitStackView(in: sub) {
                return found
            }
        }
        return nil
    }

    // MARK: - Portrait layout via targetSize

    @Test("portrait targetSize produces a vertical split-stack with fill alignment")
    func portraitTargetSizeUsesVerticalLayout() {
        let sut = makeSUT()

        sut.updateViews(for: CGSize(width: 390, height: 844))

        let split = findSplitStackView(in: sut.view)
        #expect(split != nil, "Split stack view should be present in the view hierarchy")
        #expect(split?.axis == .vertical,
                "Portrait targetSize must produce a vertical split-stack axis")
        #expect(split?.alignment == .fill,
                "Portrait split-stack alignment must be .fill")
    }

    @Test("square targetSize (width == height) is treated as portrait")
    func squareTargetSizeIsPortrait() {
        let sut = makeSUT()

        sut.updateViews(for: CGSize(width: 500, height: 500))

        let split = findSplitStackView(in: sut.view)
        #expect(split?.axis == .vertical,
                "Equal-dimension targetSize (w == h) must use portrait (vertical) layout")
    }

    // MARK: - Landscape layout via targetSize

    @Test("landscape targetSize produces a horizontal split-stack with top alignment")
    func landscapeTargetSizeUsesHorizontalLayoutWithTopAlignment() {
        let sut = makeSUT()

        sut.updateViews(for: CGSize(width: 844, height: 390))

        let split = findSplitStackView(in: sut.view)
        #expect(split != nil, "Split stack view should be present in the view hierarchy")
        #expect(split?.axis == .horizontal,
                "Landscape targetSize must produce a horizontal split-stack axis")
        #expect(split?.alignment == .top,
                "Landscape split-stack alignment must be .top (regression fix: was .fill)")
    }

    // MARK: - nil targetSize

    @Test("nil targetSize does not crash")
    func nilTargetSizeDoesNotCrash() {
        let sut = makeSUT()
        // Must not crash; orientation falls back to UIDevice.isPortrait()
        sut.updateViews(for: nil)
    }

    // MARK: - Switching orientations

    @Test("layout switches correctly when updateViews is called multiple times")
    func layoutSwitchesBetweenOrientations() {
        let sut = makeSUT()

        sut.updateViews(for: CGSize(width: 390, height: 844)) // portrait
        let afterPortrait = findSplitStackView(in: sut.view)
        #expect(afterPortrait?.axis == .vertical)

        sut.updateViews(for: CGSize(width: 844, height: 390)) // landscape
        let afterLandscape = findSplitStackView(in: sut.view)
        #expect(afterLandscape?.axis == .horizontal)
        #expect(afterLandscape?.alignment == .top)

        sut.updateViews(for: CGSize(width: 390, height: 844)) // back to portrait
        let afterPortraitAgain = findSplitStackView(in: sut.view)
        #expect(afterPortraitAgain?.axis == .vertical)
        #expect(afterPortraitAgain?.alignment == .fill)
    }
}
