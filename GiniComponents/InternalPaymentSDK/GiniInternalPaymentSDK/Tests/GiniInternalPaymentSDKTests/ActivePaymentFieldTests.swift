//
//  ActivePaymentFieldTests.swift
//  GiniInternalPaymentSDKTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing
@testable import GiniInternalPaymentSDK

// MARK: - Hashable conformance

/**
 `ActivePaymentField` is used as a SwiftUI `.id()` tag for `ScrollViewReader.scrollTo(_:)`,
 which requires `Hashable`. These tests guard against regressions in that conformance.
 */
@Suite("ActivePaymentField — Hashable")
struct ActivePaymentFieldHashableTests {

    @Test("all four cases are distinct Set members")
    func allCasesAreDistinctInSet() {
        let set: Set<ActivePaymentField> = [.recipient, .iban, .amount, .paymentPurpose]

        #expect(set.count == 4,
                "All four ActivePaymentField cases must hash to distinct values so ScrollViewReader can scroll to each field independently")
    }

    @Test("inserting the same case twice does not grow the Set")
    func duplicateCaseDoesNotGrowSet() {
        var set = Set<ActivePaymentField>()
        set.insert(.amount)
        set.insert(.amount)

        #expect(set.count == 1,
                "Inserting .amount twice must deduplicate — Equatable equality must be consistent with Hashable identity")
    }

    @Test("each case can be used as a Dictionary key", arguments: [
        ActivePaymentField.recipient,
        .iban,
        .amount,
        .paymentPurpose
    ])
    func canBeUsedAsDictionaryKey(field: ActivePaymentField) {
        var dict = [ActivePaymentField: String]()
        dict[field] = "sentinel"

        #expect(dict[field] == "sentinel",
                "\(field) must be usable as a Dictionary key — required for Hashable conformance used by SwiftUI .id() and ScrollViewReader.scrollTo()")
    }

    @Test("each case round-trips through a Set without mutation", arguments: [
        ActivePaymentField.recipient,
        .iban,
        .amount,
        .paymentPurpose
    ])
    func caseRoundTripsThroughSet(field: ActivePaymentField) {
        var set = Set<ActivePaymentField>()
        set.insert(field)

        #expect(set.contains(field),
                "\(field) inserted into a Set must be retrievable via contains — hash and equality must agree")
    }
}
