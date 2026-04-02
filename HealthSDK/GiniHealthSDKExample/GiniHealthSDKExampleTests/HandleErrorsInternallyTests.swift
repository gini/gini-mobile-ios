//
//  HandleErrorsInternallyTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
import GiniHealthSDK
import GiniInternalPaymentSDK
import GiniUtilites
@testable import GiniHealthSDKExample

@MainActor
struct HandleErrorsInternallyTests {

    // MARK: - DebugMenuViewController switch initial state

    @Test func switchIsOnWhenInitializedTrue() {
        let vc = makeDebugMenuViewController(handleErrorsInternally: true)
        vc.loadViewIfNeeded()
        let sw = findSwitch(withLabel: "Handle errors internally", in: vc.view)
        #expect(sw != nil, "handleErrorsInternally switch should exist in the view hierarchy")
        #expect(sw?.isOn == true, "Switch should be ON when initialized with handleErrorsInternally: true")
    }

    @Test func switchIsOffWhenInitializedFalse() {
        let vc = makeDebugMenuViewController(handleErrorsInternally: false)
        vc.loadViewIfNeeded()
        let sw = findSwitch(withLabel: "Handle errors internally", in: vc.view)
        #expect(sw != nil, "handleErrorsInternally switch should exist in the view hierarchy")
        #expect(sw?.isOn == false, "Switch should be OFF when initialized with handleErrorsInternally: false")
    }

    // MARK: - DebugMenuViewController delegate notification

    @Test func togglingToFalseNotifiesDelegateWithCorrectValues() {
        let vc = makeDebugMenuViewController(handleErrorsInternally: true)
        vc.loadViewIfNeeded()
        let mockDelegate = MockDebugMenuDelegate()
        vc.delegate = mockDelegate

        let sw = findSwitch(withLabel: "Handle errors internally", in: vc.view)
        sw?.isOn = false
        sw?.sendActions(for: .valueChanged)

        #expect(mockDelegate.lastSwitchType == .handleErrorsInternally,
                "Delegate should receive .handleErrorsInternally type")
        #expect(mockDelegate.lastIsOn == false,
                "Delegate should receive isOn: false")
    }

    @Test func togglingToTrueNotifiesDelegateWithCorrectValues() {
        let vc = makeDebugMenuViewController(handleErrorsInternally: false)
        vc.loadViewIfNeeded()
        let mockDelegate = MockDebugMenuDelegate()
        vc.delegate = mockDelegate

        let sw = findSwitch(withLabel: "Handle errors internally", in: vc.view)
        sw?.isOn = true
        sw?.sendActions(for: .valueChanged)

        #expect(mockDelegate.lastSwitchType == .handleErrorsInternally,
                "Delegate should receive .handleErrorsInternally type")
        #expect(mockDelegate.lastIsOn == true,
                "Delegate should receive isOn: true")
    }

    // MARK: - AppCoordinator behavior

    @Test func shouldHandleErrorInternallyReturnsTrueByDefault() {
        let coordinator = AppCoordinator(window: UIWindow())
        let result = coordinator.shouldHandleErrorInternally(error: .noInstalledApps)
        #expect(result == true, "shouldHandleErrorInternally should return true by default")
    }

    @Test func shouldHandleErrorInternallyReturnsFalseAfterTogglingOff() {
        let coordinator = AppCoordinator(window: UIWindow())
        coordinator.didChangeSwitchValue(type: .handleErrorsInternally, isOn: false)
        let result = coordinator.shouldHandleErrorInternally(error: .noInstalledApps)
        #expect(result == false, "shouldHandleErrorInternally should return false after toggling off")
    }

    @Test func shouldHandleErrorInternallyReturnsTrueAfterRetoggling() {
        let coordinator = AppCoordinator(window: UIWindow())
        coordinator.didChangeSwitchValue(type: .handleErrorsInternally, isOn: false)
        coordinator.didChangeSwitchValue(type: .handleErrorsInternally, isOn: true)
        let result = coordinator.shouldHandleErrorInternally(error: .noInstalledApps)
        #expect(result == true, "shouldHandleErrorInternally should return true after toggling back on")
    }
}

// MARK: - Helpers

@MainActor
private extension HandleErrorsInternallyTests {
    func makeDebugMenuViewController(handleErrorsInternally: Bool) -> DebugMenuViewController {
        DebugMenuViewController(
            showReviewScreen: false,
            useBottomPaymentComponent: false,
            paymentComponentConfiguration: PaymentComponentConfiguration(),
            showPaymentCloseButton: false,
            popupDuration: 3,
            shouldUseAlternativeNavigation: false,
            handleErrorsInternally: handleErrorsInternally
        )
    }

    /// Recursively searches `view` for a `UISwitch` that is a sibling of a `UILabel`
    /// with the given `text` inside the same `UIStackView`.
    func findSwitch(withLabel text: String, in view: UIView) -> UISwitch? {
        if let stack = view as? UIStackView {
            let hasLabel = stack.arrangedSubviews
                .compactMap { $0 as? UILabel }
                .contains(where: { $0.text == text })
            if hasLabel, let sw = stack.arrangedSubviews.compactMap({ $0 as? UISwitch }).first {
                return sw
            }
        }
        for subview in view.subviews {
            if let found = findSwitch(withLabel: text, in: subview) {
                return found
            }
        }
        return nil
    }
}

// MARK: - MockDebugMenuDelegate

private final class MockDebugMenuDelegate: DebugMenuDelegate {
    var lastSwitchType: SwitchType?
    var lastIsOn: Bool?

    func didChangeSwitchValue(type: SwitchType, isOn: Bool) {
        lastSwitchType = type
        lastIsOn = isOn
    }

    func didPickNewLocalization(localization: GiniLocalization) {}
    func didChangeSliderValue(value: Float) {}
    func didCustomizeShareWithFilename(filename: String) {}
    func didTapOnBulkDelete() {}
}
