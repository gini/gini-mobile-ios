//
//  TransactionExtensionsTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
import SwiftUI
@testable import GiniInternalPaymentSDK

@Suite("Transaction+Extensions")
struct TransactionExtensionsTests {

    @Test("withoutAnimation sets disablesAnimations to true")
    func withoutAnimationSetsDisablesAnimations() {
        let transaction = Transaction.withoutAnimation

        #expect(transaction.disablesAnimations == true,
                "Transaction.withoutAnimation must set disablesAnimations = true to suppress ambient UIKit animation inheritance from keyboard CATransaction")
    }

    @Test("a default Transaction does not disable animations")
    func defaultTransactionDoesNotDisableAnimations() {
        let transaction = Transaction()

        #expect(transaction.disablesAnimations == false,
                "A default Transaction must have disablesAnimations = false — only withoutAnimation opts in to suppressing animations")
    }
}
