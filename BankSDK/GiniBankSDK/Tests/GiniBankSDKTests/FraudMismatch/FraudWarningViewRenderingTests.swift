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

    private static let qrIBAN = "PL12 1000 0111 0100 1000"
    private static let printedIBAN = "DE89 3704 0044 0532 0130 00"

    @Test("FraudWarningContainer renders qrPrinted variant without crashing")
    func containerRendersQrPrinted() {
        renderContainer(for: .qrPrinted(qrIBAN: Self.qrIBAN, printedIBAN: Self.printedIBAN))
    }

    @Test("FraudWarningContainer renders country variant without crashing")
    func containerRendersCountry() {
        renderContainer(for: .country(senderName: "Elektro Brandt GmbH",
                                      senderCountry: "DE",
                                      iban: Self.qrIBAN))
    }

    @Test("FraudWarningContainer renders combined variant without crashing")
    func containerRendersCombined() {
        renderContainer(for: .combined(senderName: "Elektro Brandt GmbH",
                                       senderCountry: "DE",
                                       qrIBAN: Self.qrIBAN,
                                       printedIBAN: Self.printedIBAN))
    }

    private func renderContainer(for content: FraudWarningContent) {
        let viewModel = FraudWarningViewModel(content: content, eventHandler: nil)
        let container = FraudWarningContainer(viewModel: viewModel)

        let hosting = UIHostingController(rootView: container)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}
