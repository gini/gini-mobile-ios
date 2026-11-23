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

    @Test("FraudWarningContainer renders without crashing")
    func containerRenders() {
        let viewModel = FraudWarningViewModel(qrIBAN: "PL12 1000 0111 0100 1000",
                                              printedIBAN: "DE89 3704 0044 0532 0130 00",
                                              delegate: nil)
        let container = FraudWarningContainer(viewModel: viewModel)

        let hosting = UIHostingController(rootView: container)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }
}
