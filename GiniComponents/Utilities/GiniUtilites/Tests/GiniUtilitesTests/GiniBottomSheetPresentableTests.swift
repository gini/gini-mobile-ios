//
//  GiniBottomSheetPresentableTests.swift
//  GiniUtilitesTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Covers GiniBottomSheetPresentable: configureBottomSheet detent and grabber
//  configuration, updateBottomSheetHeight custom detents, and the
//  presentAsBottomSheet accessibility side effects.

import Testing
import UIKit
@testable import GiniUtilites

/// Manual conformer used as the system under test (no third-party mocks).
private final class BottomSheetHostViewController: UIViewController, GiniBottomSheetPresentable {
    var shouldShowDragIndicator: Bool = true
    var shouldShowInFullScreenInLandscapeMode: Bool = false
}

/// Spy presenter that records the presentation request and invokes the
/// completion synchronously — real UIKit presentation never completes in an
/// unhosted test bundle, so awaiting it would hang the suite.
private final class SpyPresenterViewController: UIViewController {
    private(set) var presentedController: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        presentedController = viewControllerToPresent
        completion?()
    }
}

@Suite("GiniBottomSheetPresentable — sheet configuration and presentation")
@MainActor
struct GiniBottomSheetPresentableTests {

    // MARK: - configureBottomSheet

    @Test("configureBottomSheet sets the modal presentation style to pageSheet")
    func configureSetsPageSheetPresentationStyle() {
        let sheetController = BottomSheetHostViewController()

        sheetController.configureBottomSheet()

        #expect(sheetController.modalPresentationStyle == .pageSheet)
    }

    @Test("configureBottomSheet applies the drag indicator preference to the grabber",
          arguments: [true, false])
    func configureAppliesGrabberPreference(shouldShowDragIndicator: Bool) throws {
        let sheetController = BottomSheetHostViewController()
        sheetController.shouldShowDragIndicator = shouldShowDragIndicator

        sheetController.configureBottomSheet()

        let presentationController = try #require(sheetController.sheetPresentationController)
        #expect(presentationController.prefersGrabberVisible == shouldShowDragIndicator)
        #expect(presentationController.prefersScrollingExpandsWhenScrolledToEdge == false)
    }

    @Test("configureBottomSheet sets edge attachment opposite to the full-screen-landscape flag",
          arguments: [true, false])
    func configureAppliesEdgeAttachment(shouldShowInFullScreenInLandscapeMode: Bool) throws {
        let sheetController = BottomSheetHostViewController()
        sheetController.shouldShowInFullScreenInLandscapeMode = shouldShowInFullScreenInLandscapeMode

        sheetController.configureBottomSheet()

        let presentationController = try #require(sheetController.sheetPresentationController)
        #expect(presentationController.prefersEdgeAttachedInCompactHeight == !shouldShowInFullScreenInLandscapeMode)
    }

    @Test("configureBottomSheet with large detent installs a single .large detent")
    func configureWithLargeDetentInstallsLargeDetent() throws {
        let sheetController = BottomSheetHostViewController()

        sheetController.configureBottomSheet(shouldIncludeLargeDetent: true)

        let presentationController = try #require(sheetController.sheetPresentationController)
        #expect(presentationController.detents.count == 1)
        if #available(iOS 16, *) {
            #expect(presentationController.detents.first?.identifier == .large)
        }
    }

    @Test("configureBottomSheet with full-screen landscape mode installs a single .medium detent")
    func configureWithFullScreenLandscapeInstallsMediumDetent() throws {
        let sheetController = BottomSheetHostViewController()
        sheetController.shouldShowInFullScreenInLandscapeMode = true

        sheetController.configureBottomSheet(shouldIncludeLargeDetent: false)

        let presentationController = try #require(sheetController.sheetPresentationController)
        #expect(presentationController.detents.count == 1)
        if #available(iOS 16, *) {
            #expect(presentationController.detents.first?.identifier == .medium)
        }
    }

    @Test("configureBottomSheet default configuration installs a single custom half-screen detent on iOS 16+")
    func configureDefaultInstallsCustomHalfScreenDetent() throws {
        let sheetController = BottomSheetHostViewController()
        sheetController.shouldShowInFullScreenInLandscapeMode = false

        sheetController.configureBottomSheet(shouldIncludeLargeDetent: false)

        let presentationController = try #require(sheetController.sheetPresentationController)
        #expect(presentationController.detents.count == 1)
        if #available(iOS 16, *) {
            let identifier = try #require(presentationController.detents.first?.identifier)
            #expect(identifier != .medium)
            #expect(identifier != .large)
        }
    }

    // MARK: - updateBottomSheetHeight

    @Test("updateBottomSheetHeight installs and selects the customHeight detent on iOS 16+")
    func updateHeightInstallsAndSelectsCustomDetent() throws {
        let sheetController = BottomSheetHostViewController()
        sheetController.configureBottomSheet()

        sheetController.updateBottomSheetHeight(300)

        let presentationController = try #require(sheetController.sheetPresentationController)
        if #available(iOS 16, *) {
            #expect(presentationController.detents.count == 1)
            let expectedIdentifier = UISheetPresentationController.Detent.Identifier("customHeight")
            #expect(presentationController.detents.first?.identifier == expectedIdentifier)
            #expect(presentationController.selectedDetentIdentifier == expectedIdentifier)
        }
    }

    @Test("updateBottomSheetHeight re-applies the drag indicator preference",
          arguments: [true, false])
    func updateHeightReappliesGrabberPreference(shouldShowDragIndicator: Bool) throws {
        let sheetController = BottomSheetHostViewController()
        sheetController.shouldShowDragIndicator = shouldShowDragIndicator
        sheetController.configureBottomSheet()

        sheetController.updateBottomSheetHeight(240)

        if #available(iOS 16, *) {
            let presentationController = try #require(sheetController.sheetPresentationController)
            #expect(presentationController.prefersGrabberVisible == shouldShowDragIndicator)
        }
    }

    // MARK: - presentAsBottomSheet

    @Test("presentAsBottomSheet hides the presenter from accessibility and makes the sheet modal")
    func presentAsBottomSheetConfiguresAccessibility() {
        let presenter = SpyPresenterViewController()
        let sheetController = BottomSheetHostViewController()
        var completionCallCount = 0

        sheetController.presentAsBottomSheet(from: presenter,
                                             animated: false) {
            completionCallCount += 1
        }

        #expect(presenter.presentedController === sheetController)
        #expect(sheetController.modalPresentationStyle == .pageSheet)
        #expect(presenter.view.accessibilityElementsHidden == true)
        #expect(sheetController.view.accessibilityViewIsModal == true)
        #expect(completionCallCount == 1)
    }
}
