//
//  EditLineItemViewControllerTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import Testing
import UIKit
import GiniUtilites
@testable import GiniBankSDK
@testable import GiniCaptureSDK

/**
 Manual `UIViewControllerTransitionCoordinator` mock that invokes the
 alongside-animation and completion closures synchronously, passing itself
 as the transition context. This lets `viewWillTransition(to:with:)` run
 deterministically without a real rotation.
 */
@MainActor
private final class MockTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {

    private(set) var animateCallCount = 0

    // MARK: - UIViewControllerTransitionCoordinatorContext

    var isAnimated: Bool { false }
    var presentationStyle: UIModalPresentationStyle { .none }
    var initiallyInteractive: Bool { false }
    var isInterruptible: Bool { false }
    var isInteractive: Bool { false }
    var isCancelled: Bool { false }
    var transitionDuration: TimeInterval { 0 }
    var percentComplete: CGFloat { 1 }
    var completionVelocity: CGFloat { 1 }
    var completionCurve: UIView.AnimationCurve { .linear }
    var containerView: UIView { UIView() }
    var targetTransform: CGAffineTransform { .identity }

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        nil
    }

    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        nil
    }

    // MARK: - UIViewControllerTransitionCoordinator

    func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
                 completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animateCallCount += 1
        animation?(self)
        completion?(self)
        return true
    }

    func animateAlongsideTransition(in view: UIView?,
                                    animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?,
                                    completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }

    func notifyWhenInteractionEnds(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        // Deprecated API; intentionally empty.
    }

    func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        // Intentionally empty; interaction is never reported in tests.
    }
}

extension GiniConfigurationSharedStateSuite {

    /**
     Covers `EditLineItemViewController`: bottom-sheet conformance values,
     view-model wiring into the embedded `EditLineItemView`, the scroll/content
     hierarchy, accessibility pass-through and the `onDismiss` callback.

     Nested in the shared-state suite because the embedded views read fonts
     from `GiniBankConfiguration.shared`.
     */
    @Suite("EditLineItemViewController")
    @MainActor
    struct EditLineItemViewControllerTests {

        // MARK: - Bottom sheet conformance

        @Test("Bottom sheet configuration hides the drag indicator and uses full screen in landscape")
        func bottomSheetConfigurationValues() throws {
            let viewController = try makeViewController()

            #expect(!viewController.shouldShowDragIndicator,
                    "The edit sheet should not show a drag indicator")
            #expect(viewController.shouldShowInFullScreenInLandscapeMode,
                    "The edit sheet should use full screen in landscape")
        }

        // MARK: - View hierarchy and view model wiring

        @Test("The embedded edit view is populated with the line item values")
        func embeddedViewIsPopulatedWithLineItemValues() throws {
            let viewController = try makeViewController()

            viewController.loadViewIfNeeded()

            let editView = try #require(findView(ofType: EditLineItemView.self,
                                                 in: viewController.view),
                                        "The controller should embed an EditLineItemView")
            let elements = try #require(editView.accessibilityElements)
            let nameView = try #require(elements[3] as? NameLabelView)
            let priceView = try #require(elements[4] as? PriceLabelView)
            let quantityView = try #require(elements[5] as? QuantityView)

            #expect(nameView.text == "Nike Sportswear Air Max 97 - Sneaker")
            #expect(priceView.priceValue == Decimal(string: "10.99"))
            #expect(priceView.currencyValue == "eur")
            #expect(quantityView.quantity == 2)
        }

        @Test("Container views pass accessibility through to the edit view content")
        func containerViewsPassAccessibilityThrough() throws {
            let viewController = try makeViewController()

            viewController.loadViewIfNeeded()

            let editView = try #require(findView(ofType: EditLineItemView.self,
                                                 in: viewController.view))
            #expect(!editView.isAccessibilityElement)
            #expect(!editView.shouldGroupAccessibilityChildren)
        }

        // MARK: - Dismissal callback

        @Test("onDismiss fires when the view disappears")
        func onDismissFiresOnViewWillDisappear() throws {
            let viewController = try makeViewController()
            viewController.loadViewIfNeeded()
            var dismissCallCount = 0
            viewController.onDismiss = { dismissCallCount += 1 }

            viewController.viewWillDisappear(false)

            /// Current behavior: the callback fires on every disappearance, by any means.
            #expect(dismissCallCount == 1)
        }

        @Test("Disappearing without an onDismiss handler does not crash")
        func viewWillDisappearWithoutHandlerIsSafe() throws {
            let viewController = try makeViewController()
            viewController.loadViewIfNeeded()

            viewController.viewWillDisappear(false)

            #expect(viewController.onDismiss == nil)
        }

        // MARK: - Appearance and accessibility notification

        @Test("Appearing posts the delayed accessibility layout change without crashing")
        func viewDidAppearPostsDelayedAccessibilityNotification() async throws {
            let viewController = try makeViewController()
            viewController.loadViewIfNeeded()

            viewController.viewDidAppear(false)

            /// The accessibility notification is posted via
            /// `DispatchQueue.main.asyncAfter(0.1)`; wait past that deadline so
            /// the delayed closure executes while the controller is alive.
            await waitForMainQueue(after: 0.3)
            #expect(viewController.isViewLoaded,
                    "The controller must survive the delayed accessibility post")
        }

        // MARK: - Rotation

        @Test("Rotation animates alongside the transition and rebuilds the orientation constraints")
        func viewWillTransitionRebuildsOrientationConstraints() throws {
            let viewController = try makeViewController()
            viewController.loadViewIfNeeded()
            let editView = try #require(findView(ofType: EditLineItemView.self,
                                                 in: viewController.view))
            let contentView = try #require(editView.superview)
            let initialCount = horizontalConstraintCount(for: editView, in: contentView)
            #expect(initialCount == 2,
                    "The initial layout installs one leading and one trailing constraint")

            let transitionCoordinator = MockTransitionCoordinator()
            viewController.viewWillTransition(to: CGSize(width: 852, height: 393),
                                              with: transitionCoordinator)

            #expect(transitionCoordinator.animateCallCount == 1,
                    "The controller should animate its layout alongside the transition")
            #expect(horizontalConstraintCount(for: editView, in: contentView) == initialCount,
                    "Rotation must replace the orientation constraints, not accumulate them")
        }

        // MARK: - Size binding

        @Test("Scroll view content size updates resize the bottom sheet detent")
        func contentSizeUpdateResizesBottomSheet() async throws {
            let viewController = try makeViewController()
            viewController.loadViewIfNeeded()
            let scrollView = try #require(findView(ofType: EmptyScrollView.self,
                                                   in: viewController.view),
                                          "The controller embeds an EmptyScrollView")

            /// Drive the `$size` publisher the controller subscribes to.
            scrollView.contentSize = CGSize(width: 320, height: 420)

            /// The value hops the main queue twice (once inside EmptyScrollView,
            /// once in the controller's sink), so wait for both dispatches.
            await waitForMainQueue(after: 0.2)

            if #available(iOS 16, *) {
                let presentationController = try #require(viewController.sheetPresentationController)
                let customIdentifier = UISheetPresentationController.Detent.Identifier("customHeight")
                #expect(presentationController.selectedDetentIdentifier == customIdentifier,
                        "The sink should apply a custom-height detent for the new content size")
            }
        }

        // MARK: - Helpers

        /**
         Waits until the main queue has executed all blocks scheduled with an
         earlier deadline. Enqueueing the continuation on the same serial queue
         with a later deadline guarantees deterministic ordering.
         */
        private func waitForMainQueue(after delay: TimeInterval) async {
            await withCheckedContinuation { continuation in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    continuation.resume()
                }
            }
        }

        /// Counts the active leading/trailing constraints between the edit view and its container.
        private func horizontalConstraintCount(for editView: UIView,
                                               in containerView: UIView) -> Int {
            containerView.constraints.filter { constraint in
                guard constraint.isActive else { return false }
                let involvesEditView = constraint.firstItem === editView || constraint.secondItem === editView
                let isHorizontal = constraint.firstAttribute == .leading || constraint.firstAttribute == .trailing
                return involvesEditView && isHorizontal
            }.count
        }

        private func makeViewController() throws -> EditLineItemViewController {
            let lineItem = try ExtractionResultFixture.lineItem(at: 0)
            let viewModel = EditLineItemViewModel(lineItem: lineItem, index: 0)
            return EditLineItemViewController(lineItemViewModel: viewModel)
        }

        private func findView<View: UIView>(ofType viewType: View.Type, in root: UIView) -> View? {
            if let match = root as? View {
                return match
            }
            for subview in root.subviews {
                if let match = findView(ofType: viewType, in: subview) {
                    return match
                }
            }
            return nil
        }
    }
}
