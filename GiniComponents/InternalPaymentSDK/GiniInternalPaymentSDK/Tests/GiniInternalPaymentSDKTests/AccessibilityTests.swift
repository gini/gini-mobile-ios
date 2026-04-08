//
//  AccessibilityTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
//  Regression guard for the VoiceOver portrait bug (iOS 18.x / iPhone 11).
//  These tests verify:
//    1. BottomSheetViewController.dimmedView is hidden from VoiceOver.
//    2. The dimmed overlay starts transparent so the dismiss-fade direction is correct.
//    3. InstallAppBottomView and ShareInvoiceBottomView clear accessibilityViewIsModal
//       on viewWillDisappear so VoiceOver can navigate back to the presenter.
//    4. PaymentComponentBottomView does not set accessibilityViewIsModal on the VC itself.
//  The UIDevice.isPortrait() orientation-fallback fix is covered by UIDeviceOrientationTests.

import Testing
import UIKit
@testable import GiniInternalPaymentSDK

// MARK: - Test factories

/// Minimal `BottomSheetConfiguration` suitable for unit tests.
private extension BottomSheetConfiguration {
    static var test: BottomSheetConfiguration {
        BottomSheetConfiguration(backgroundColor: .white,
                                 rectangleColor: .systemGray4,
                                 dimmingBackgroundColor: UIColor.black.withAlphaComponent(0.5))
    }
}

private extension ButtonConfiguration {
    static var test: ButtonConfiguration {
        ButtonConfiguration(backgroundColor: .systemBlue,
                            borderColor: .clear,
                            titleColor: .white,
                            titleFont: .systemFont(ofSize: 16, weight: .semibold),
                            shadowColor: .clear,
                            cornerRadius: 8,
                            borderWidth: 0,
                            shadowRadius: 0,
                            withBlurEffect: false)
    }
}

private extension PoweredByGiniConfiguration {
    static var test: PoweredByGiniConfiguration {
        PoweredByGiniConfiguration(poweredByGiniLabelFont: .systemFont(ofSize: 12),
                                   poweredByGiniLabelAccentColor: .label,
                                   giniIcon: UIImage())
    }
}

private extension PoweredByGiniStrings {
    static var test: PoweredByGiniStrings {
        PoweredByGiniStrings(poweredByGiniText: "Powered by Gini")
    }
}

private extension InstallAppConfiguration {
    static var test: InstallAppConfiguration {
        InstallAppConfiguration(titleAccentColor: .label,
                                titleFont: .systemFont(ofSize: 18, weight: .bold),
                                moreInformationFont: .systemFont(ofSize: 14),
                                moreInformationTextColor: .label,
                                moreInformationAccentColor: .systemBlue,
                                moreInformationIcon: UIImage(),
                                appStoreIcon: UIImage(),
                                bankIconBorderColor: .systemGray4,
                                closeIcon: UIImage(),
                                closeIconAccentColor: .label)
    }
}

private extension InstallAppStrings {
    static var test: InstallAppStrings {
        InstallAppStrings(titlePattern: "Install [BANK]",
                          moreInformationTipPattern: "Tip: open [BANK]",
                          moreInformationNotePattern: "Note: install [BANK]",
                          continueLabelText: "Continue",
                          accessibilityAppStoreText: "App Store",
                          accessibilityBankLogoText: "Bank logo",
                          accessibilityCloseIconText: "Close")
    }
}

private extension ShareInvoiceConfiguration {
    static var test: ShareInvoiceConfiguration {
        ShareInvoiceConfiguration(titleFont: .systemFont(ofSize: 18, weight: .bold),
                                  titleAccentColor: .label,
                                  descriptionFont: .systemFont(ofSize: 14),
                                  descriptionTextColor: .label,
                                  descriptionAccentColor: .systemBlue,
                                  paymentInfoBorderColor: .systemGray4,
                                  titlePaymentInfoTextColor: .label,
                                  subtitlePaymentInfoTextColor: .secondaryLabel,
                                  titlepaymentInfoFont: .systemFont(ofSize: 14, weight: .semibold),
                                  subtitlePaymentInfoFont: .systemFont(ofSize: 12),
                                  closeIcon: UIImage(),
                                  closeIconAccentColor: .label)
    }
}

private extension ShareInvoiceStrings {
    static var test: ShareInvoiceStrings {
        ShareInvoiceStrings(continueLabelText: "Continue",
                            titleTextPattern: "Share invoice with [BANK]",
                            descriptionTextPattern: "Description for [BANK]",
                            recipientLabelText: "Recipient",
                            amountLabelText: "Amount",
                            ibanLabelText: "IBAN",
                            purposeLabelText: "Purpose",
                            accessibilityQRCodeImageText: "QR code",
                            accessibilityCloseIconText: "Close")
    }
}

// MARK: - View controller factories

private func makeInstallAppBottomView() -> InstallAppBottomView {
    let viewModel = InstallAppBottomViewModel(selectedPaymentProvider: nil,
                                              installAppConfiguration: .test,
                                              strings: .test,
                                              primaryButtonConfiguration: .test,
                                              poweredByGiniConfiguration: .test,
                                              poweredByGiniStrings: .test,
                                              clientConfiguration: nil)
    return InstallAppBottomView(viewModel: viewModel,
                                bottomSheetConfiguration: .test)
}

private func makeShareInvoiceBottomView() -> ShareInvoiceBottomView {
    let viewModel = ShareInvoiceBottomViewModel(selectedPaymentProvider: nil,
                                                configuration: .test,
                                                strings: .test,
                                                primaryButtonConfiguration: .test,
                                                poweredByGiniConfiguration: .test,
                                                poweredByGiniStrings: .test,
                                                qrCodeData: Data(),
                                                paymentInfo: nil,
                                                paymentRequestId: "test-request-id",
                                                clientConfiguration: nil)
    return ShareInvoiceBottomView(viewModel: viewModel,
                                  bottomSheetConfiguration: .test)
}

// MARK: - BottomViewType

/// Compile-time–safe enumeration of the two bottom-sheet view controllers whose
/// `viewWillDisappear` teardown is under test.  Using an enum instead of raw strings
/// means Swift exhaustiveness checking replaces the previous unreachable `default: throw`
/// branch, and a typo in a case name is a compiler error rather than a silent test skip.
enum BottomViewType: CaseIterable, CustomTestStringConvertible {
    case installApp
    case shareInvoice

    var testDescription: String {
        switch self {
        case .installApp:
            "InstallAppBottomView"
        case .shareInvoice:
            "ShareInvoiceBottomView"
        }
    }
}

// MARK: - Tests

/// Regression tests for the four VoiceOver portrait-orientation bugs covered here.
///
/// All tests use `@MainActor` because they create and mutate `UIView`/`UIViewController`
/// objects, which must be accessed on the main thread.
@Suite("Accessibility — VoiceOver portrait regression guard")
@MainActor
struct AccessibilityTests {

    // MARK: BottomSheetViewController — dimmedView

    /// `dimmedView` is the first subview added to the root view.  It must never appear
    /// in the accessibility tree: VoiceOver navigating in portrait would land on this
    /// full-screen opaque view first and find no readable content, falling silent.
    @Test("dimmedView is hidden from VoiceOver")
    func dimmedViewHiddenFromVoiceOver() throws {
        final class ConcreteSheet: BottomSheetViewController {}
        let vc = ConcreteSheet(configuration: .test)
        vc.loadViewIfNeeded()

        let overlay = try #require(
            vc.view.subviews.first,
            "BottomSheetViewController must have at least one subview (the dimmed overlay)"
        )
        #expect(
            overlay.isAccessibilityElement == false,
            "dimmedView must not be an accessibility element"
        )
        #expect(
            overlay.accessibilityElementsHidden == true,
            "dimmedView must hide its subtree — sibling views must remain reachable"
        )
    }

    /// Verifies the dismiss-animation direction fix: `dimmedView` starts at alpha 0
    /// so the fade-out animation works correctly (was previously fading *to* maxAlpha).
    @Test("dimmedView starts transparent before presentation")
    func dimmedViewStartsTransparent() throws {
        final class ConcreteSheet: BottomSheetViewController {}
        let vc = ConcreteSheet(configuration: .test)
        vc.loadViewIfNeeded()

        let overlay = try #require(vc.view.subviews.first)
        #expect(
            overlay.alpha == 0,
            "dimmedView alpha must be 0 before animatePresent() runs — dismiss must fade to 0, not to maxDimmedAlpha"
        )
    }

    // MARK: BottomSheet views — viewWillDisappear teardown

    /// Parameterized to guard both `InstallAppBottomView` and `ShareInvoiceBottomView`
    /// against regressions in a single test definition.  `BottomViewType` is a compile-time
    /// safe enum, so Swift exhaustiveness checking replaces the previous `default: throw`
    /// error path that could never be reached.
    @Test(
        "accessibilityViewIsModal is cleared on viewWillDisappear",
        arguments: BottomViewType.allCases
    )
    func modalFlagClearedOnDisappear(viewType: BottomViewType) {
        let vc: UIViewController = switch viewType {
        case .installApp:
            makeInstallAppBottomView()
        case .shareInvoice:
            makeShareInvoiceBottomView()
        }

        vc.loadViewIfNeeded()
        vc.view.accessibilityViewIsModal = true
        vc.viewWillDisappear(false)

        #expect(
            vc.view.accessibilityViewIsModal == false,
            "[\(viewType.testDescription)] accessibilityViewIsModal must be cleared in viewWillDisappear"
        )
    }

    // MARK: PaymentComponentBottomView

    /// Verifies that `PaymentComponentBottomView` does not start with
    /// `accessibilityViewIsModal` set on its view before presentation.
    @Test("PaymentComponentBottomView view.accessibilityViewIsModal starts as false")
    func paymentComponentBottomViewModalStartsFalse() {
        let vc = PaymentComponentBottomView(
            paymentView: UIView(),
            bottomSheetConfiguration: .test
        )
        vc.loadViewIfNeeded()
        #expect(
            vc.view.accessibilityViewIsModal == false,
            "accessibilityViewIsModal must be false until postAccessibilityFocus fires; setting it prematurely traps VoiceOver before the sheet is visible"
        )
    }
}

// MARK: - Test support

