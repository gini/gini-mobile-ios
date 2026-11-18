//
//  FraudWarningViewRenderingTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Testing
@testable import GiniBankSDK

@Suite("FraudWarningView rendering")
@MainActor
struct FraudWarningViewRenderingTests {

    private static let stubQRIBAN = "PL12 1000 0111 0100 1000"
    private static let stubPrintedIBAN = "DE89 3704 0044 0532 0130 00"

    @Test("FraudWarningContainer renders without crashing")
    func containerRenders() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: nil)
        renderInWindow(FraudWarningContainer(viewModel: viewModel))
    }

    @Test("FraudWarningContainer renders with the expandable opened")
    func containerRendersWithExpandableOpen() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: nil)
        viewModel.isExpandedProtectMyself = true

        renderInWindow(FraudWarningContainer(viewModel: viewModel))
    }

    @Test("FraudWarningView renders standalone without crashing")
    func viewRendersStandalone() {
        let viewModel = FraudWarningViewModel(qrIBAN: Self.stubQRIBAN,
                                              printedIBAN: Self.stubPrintedIBAN,
                                              delegate: nil)
        let view = FraudWarningView(viewModel: viewModel,
                                    onCancel: { },
                                    onProceed: { })

        renderInWindow(view)
    }

    @Test("FraudWarningView renders with long IBAN strings without crashing")
    func viewRendersWithLongIBANs() {
        let longIBAN = "DE89370400440532013000DE89370400440532013000"
        let viewModel = FraudWarningViewModel(qrIBAN: longIBAN,
                                              printedIBAN: longIBAN,
                                              delegate: nil)
        let view = FraudWarningView(viewModel: viewModel,
                                    onCancel: { },
                                    onProceed: { })

        renderInWindow(view)
    }

    private func renderInWindow<Content: View>(_ view: Content) {
        let hosting = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}
