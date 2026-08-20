//
//  DismissMessageViewTests.swift
//  GiniCaptureSDK
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import UIKit
@testable import GiniCaptureSDK

@Suite("DismissMessageView")
struct DismissMessageViewTests {

    private typealias Helper = ViewHierarchyTestHelper

    private static let dismissTitle = NSLocalizedStringPreferredFormat("ginicapture.dismiss.message.title",
                                                                       comment: "Title for the dismiss message view")

    // MARK: - Appearance

    @Test("Title label shows the localized dismiss message title")
    @MainActor func titleLabelShowsLocalizedTitle() throws {
        let sut = DismissMessageView()

        let titleLabel = try #require(Helper.firstLabel(withText: Self.dismissTitle, in: sut))
        #expect(titleLabel.numberOfLines == 0)
        #expect(titleLabel.textAlignment == .center)
        /// Localization must resolve to real copy, not fall back to the key.
        #expect(Self.dismissTitle != "ginicapture.dismiss.message.title")
    }

    @Test("View is styled as a rounded, bordered container")
    @MainActor func viewIsStyledAsRoundedBorderedContainer() {
        let sut = DismissMessageView()

        #expect(sut.backgroundColor == .clear)
        #expect(sut.layer.cornerRadius == 14)
        #expect(sut.layer.borderWidth == 1)
        #expect(sut.layer.masksToBounds)
    }

    @Test("Progress view starts empty with the accent tint")
    @MainActor func progressViewStartsEmpty() throws {
        let sut = DismissMessageView()

        let progressView = try #require(Helper.firstView(ofType: UIProgressView.self, in: sut))
        #expect(progressView.progress == 0.0)
        #expect(Helper.colorsEqual(progressView.progressTintColor, .GiniCapture.accent1))
    }

    // MARK: - Accessibility

    @Test("View is a single accessibility button labeled with the title")
    @MainActor func accessibilityConfiguration() {
        let sut = DismissMessageView()

        #expect(sut.isAccessibilityElement)
        #expect(sut.accessibilityTraits.contains(.button))
        #expect(sut.accessibilityLabel == Self.dismissTitle)
    }

    // MARK: - Interaction

    @Test("Tap gesture fires the onTap callback")
    @MainActor func tapFiresOnTapCallback() throws {
        let sut = DismissMessageView()
        var tapCallCount = 0
        sut.onTap = { tapCallCount += 1 }

        #expect(sut.isUserInteractionEnabled)
        let tapGesture = sut.gestureRecognizers?.compactMap { $0 as? UITapGestureRecognizer }.first
        #expect(tapGesture != nil, "A tap gesture recognizer should be installed")

        /// The gesture action cannot be fired directly in unit tests,
        /// so invoke the wired-up handler through the responder.
        _ = sut.perform(NSSelectorFromString("handleTap"))

        #expect(tapCallCount == 1)
    }

    @Test("Tap without a callback does not crash")
    @MainActor func tapWithoutCallbackIsNoOp() {
        let sut = DismissMessageView()

        _ = sut.perform(NSSelectorFromString("handleTap"))

        #expect(sut.onTap == nil)
    }

    // MARK: - Progress timer

    @Test("Progress advances over time while the view is alive")
    @MainActor func progressAdvancesOverTime() throws {
        let sut = DismissMessageView()
        let progressView = try #require(Helper.firstView(ofType: UIProgressView.self, in: sut))

        /// Pump the main run loop so the scheduled progress timer can tick.
        RunLoop.main.run(until: Date().addingTimeInterval(0.1))

        #expect(progressView.progress > 0.0, "Progress should advance after the timer ticks")
        #expect(progressView.progress < 1.0, "Progress should not be complete yet")
    }

    @Test("Progress timer releases the view and invalidates after deallocation")
    @MainActor func progressTimerDoesNotRetainView() {
        var sut: DismissMessageView? = DismissMessageView()
        weak var weakSut = sut

        /// Let the timer tick once while the view is alive.
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        sut = nil

        #expect(weakSut == nil, "The progress timer must not retain the view")

        /// Pump the run loop once more so the orphaned timer invalidates itself.
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
    }
}
