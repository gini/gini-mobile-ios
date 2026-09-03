//
//  ButtonsViewTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

@Suite("ButtonsView")
struct ButtonsViewTests {

    private static let primaryTitle = "Primary title"
    private static let secondaryTitle = "Secondary title"

    @MainActor
    private func makeSUT(buttonOrder: [ButtonsView.ButtonType] = [.primary, .secondary]) -> ButtonsView {
        ButtonsView(secondaryButtonTitle: Self.secondaryTitle,
                    primaryButtonTitle: Self.primaryTitle,
                    buttonOrder: buttonOrder)
    }

    @MainActor
    private func stackView(of sut: ButtonsView) -> UIStackView? {
        sut.subviews.compactMap { $0 as? UIStackView }.first
    }

    // MARK: - Button configuration

    @Test("Buttons expose the injected titles")
    @MainActor func buttonsUseInjectedTitles() {
        let sut = makeSUT()

        #expect(sut.primaryButton.title(for: .normal) == Self.primaryTitle)
        #expect(sut.secondaryButton.title(for: .normal) == Self.secondaryTitle)
    }

    @Test("Accessibility labels match the button titles")
    @MainActor func accessibilityLabelsMatchTitles() {
        let sut = makeSUT()

        #expect(sut.primaryButton.accessibilityLabel == Self.primaryTitle)
        #expect(sut.secondaryButton.accessibilityLabel == Self.secondaryTitle)
    }

    @Test("Buttons use the bold body text style font")
    @MainActor func buttonsUseBodyBoldFont() {
        let sut = makeSUT()
        let expectedFont = GiniConfiguration.shared.textStyleFonts[.bodyBold]

        #expect(sut.primaryButton.titleLabel?.font == expectedFont)
        #expect(sut.secondaryButton.titleLabel?.font == expectedFont)
    }

    @Test("Each button has a minimum height constraint of 50pt")
    @MainActor func buttonsHaveMinimumHeightConstraint() throws {
        let sut = makeSUT()

        for button in [sut.primaryButton, sut.secondaryButton] {
            let heightConstraint = try #require(button.constraints.first {
                $0.firstAttribute == .height && $0.relation == .greaterThanOrEqual
            }, "Button should have a greater-than-or-equal height constraint")
            #expect(heightConstraint.constant == 50)
            #expect(heightConstraint.isActive)
        }
    }

    // MARK: - Button order

    @Test("Button order drives the arranged subviews order",
          arguments: [[ButtonsView.ButtonType.primary, .secondary],
                      [ButtonsView.ButtonType.secondary, .primary]])
    @MainActor func buttonOrderDrivesArrangedSubviews(order: [ButtonsView.ButtonType]) throws {
        let sut = makeSUT(buttonOrder: order)
        let stack = try #require(stackView(of: sut), "ButtonsView should contain a stack view")

        let expectedButtons: [UIButton] = order.map {
            $0 == .primary ? sut.primaryButton : sut.secondaryButton
        }
        #expect(stack.arrangedSubviews.count == expectedButtons.count)
        for (arranged, expected) in zip(stack.arrangedSubviews, expectedButtons) {
            #expect(arranged === expected)
        }
    }

    // MARK: - Layout

    @Test("Stack view is pinned to all edges of the container")
    @MainActor func stackViewPinnedToEdges() throws {
        let sut = makeSUT()
        let stack = try #require(stackView(of: sut))

        #expect(stack.superview === sut)
        let attributes = Set(sut.constraints.map { $0.firstAttribute })
        #expect(attributes.isSuperset(of: [.top, .bottom, .leading, .trailing]))
    }

    @Test("Stack view axis matches the current device orientation")
    @MainActor func stackViewAxisMatchesOrientation() throws {
        let sut = makeSUT()
        let stack = try #require(stackView(of: sut))
        let expectedAxis: NSLayoutConstraint.Axis = UIDevice.current.isLandscape ? .horizontal : .vertical

        #expect(stack.axis == expectedAxis)
        #expect(stack.distribution == .fillEqually)
        #expect(stack.spacing == 12)
    }

    @Test("Trait collection change re-evaluates the stack view axis")
    @MainActor func traitChangeReappliesAxis() throws {
        let sut = makeSUT()
        let stack = try #require(stackView(of: sut))

        /// Force an out-of-sync axis, then simulate a trait change.
        stack.axis = UIDevice.current.isLandscape ? .vertical : .horizontal
        sut.traitCollectionDidChange(nil)

        let expectedAxis: NSLayoutConstraint.Axis = UIDevice.current.isLandscape ? .horizontal : .vertical
        #expect(stack.axis == expectedAxis)
    }
}
