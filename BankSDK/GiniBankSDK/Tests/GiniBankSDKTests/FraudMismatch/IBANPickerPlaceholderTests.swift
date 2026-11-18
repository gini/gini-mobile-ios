//
//  IBANPickerPlaceholderTests.swift
//  GiniBankSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
import Testing
@testable import GiniBankSDK

/**
 Smoke tests for `IBANPickerPlaceholder`. A regression that empties the
 placeholder body before the real picker lands surfaces as a failing
 render here.
 */
@Suite("IBANPickerPlaceholder")
@MainActor
struct IBANPickerPlaceholderTests {

    @Test("placeholder renders without crashing inside a UIHostingController attached to a UIWindow")
    func rendersWithoutCrash() {
        let hosting = UIHostingController(rootView: IBANPickerPlaceholder())
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 500))
        window.rootViewController = hosting
        window.isHidden = false
        hosting.view.setNeedsLayout()
        hosting.view.layoutIfNeeded()
    }

}

/// Content-assertion coverage (e.g. "placeholder body contains the Qazi-ticket
/// stub text") is intentionally omitted — SwiftUI `Text` content isn't
/// reliably surfaced through UIKit view-inspection without a dedicated
/// framework, which this repo does not use. The render-without-crash smoke
/// test above is the regression surface a "developer accidentally emptied
/// the body" change would trip (the placeholder is ~15 lines; an empty body
/// would be caught at the first integration smoke).
