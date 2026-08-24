//
//  GiniBottomSheetAccessibilityRestorableTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Covers GiniBottomSheetAccessibilityRestorable: the default
//  accessibilityFocusTargetViewController resolution and the delayed
//  accessibility restoration after a bottom sheet is dismissed.

import Testing
import UIKit
@testable import GiniUtilites

/// Manual mock conformer (class-based, as the protocol requires AnyObject).
private final class MockBottomSheetCoordinator: GiniBottomSheetAccessibilityRestorable {
    let presenterViewController: UIViewController

    init(presenterViewController: UIViewController) {
        self.presenterViewController = presenterViewController
    }
}

@Suite("GiniBottomSheetAccessibilityRestorable — accessibility restoration")
@MainActor
struct GiniBottomSheetAccessibilityRestorableTests {

    /**
     Waits until the main queue has executed all blocks scheduled with a deadline
     earlier than `delay`. The production code schedules its restoration via
     `DispatchQueue.main.asyncAfter(0.1)`; enqueueing our continuation with a
     later deadline on the same serial queue guarantees deterministic ordering.
     */
    private func waitForMainQueue(after delay: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                continuation.resume()
            }
        }
    }

    // MARK: - accessibilityFocusTargetViewController

    @Test("Default focus target is the presenter itself for a plain view controller")
    func defaultFocusTargetIsPresenterForPlainViewController() {
        let presenter = UIViewController()
        let coordinator = MockBottomSheetCoordinator(presenterViewController: presenter)

        #expect(coordinator.accessibilityFocusTargetViewController === presenter)
    }

    @Test("Default focus target is the top view controller for a navigation controller presenter")
    func defaultFocusTargetIsTopViewControllerForNavigationController() {
        let rootViewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        let coordinator = MockBottomSheetCoordinator(presenterViewController: navigationController)

        #expect(coordinator.accessibilityFocusTargetViewController === rootViewController)
    }

    // MARK: - restoreAccessibilityAfterBottomSheetDismissal

    @Test("Restoration resets accessibilityElementsHidden on the presenter's view after the delay")
    func restorationResetsPresenterViewAccessibility() async {
        let presenter = UIViewController()
        presenter.view.accessibilityElementsHidden = true
        let coordinator = MockBottomSheetCoordinator(presenterViewController: presenter)

        coordinator.restoreAccessibilityAfterBottomSheetDismissal()

        /// Not yet restored — the production code delays by 0.1s.
        #expect(presenter.view.accessibilityElementsHidden == true)

        await waitForMainQueue(after: 0.3)
        #expect(presenter.view.accessibilityElementsHidden == false)
    }

    @Test("Restoration also resets the navigation bar for a navigation controller presenter")
    func restorationResetsNavigationBarAccessibility() async {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.view.accessibilityElementsHidden = true
        navigationController.navigationBar.accessibilityElementsHidden = true
        let coordinator = MockBottomSheetCoordinator(presenterViewController: navigationController)

        coordinator.restoreAccessibilityAfterBottomSheetDismissal()

        await waitForMainQueue(after: 0.3)
        #expect(navigationController.view.accessibilityElementsHidden == false)
        #expect(navigationController.navigationBar.accessibilityElementsHidden == false)
    }

    @Test("Restoration is skipped safely when the coordinator is deallocated before the delay fires")
    func restorationSkippedWhenCoordinatorDeallocated() async {
        let presenter = UIViewController()
        presenter.view.accessibilityElementsHidden = true
        var coordinator: MockBottomSheetCoordinator? = MockBottomSheetCoordinator(presenterViewController: presenter)

        coordinator?.restoreAccessibilityAfterBottomSheetDismissal()
        coordinator = nil

        await waitForMainQueue(after: 0.3)
        /// The weak-self guard must prevent any restoration once the coordinator is gone.
        #expect(presenter.view.accessibilityElementsHidden == true)
    }
}
