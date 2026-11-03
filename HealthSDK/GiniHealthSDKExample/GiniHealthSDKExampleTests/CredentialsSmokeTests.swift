//
//  CredentialsSmokeTests.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniHealthSDKExample

/**
 Smoke tests that pin the mapping between the build-time-generated
 `Credentials` enum (produced by `scripts/generate_credentials.sh`) and
 the global constants exported by `CredentialsManager.swift`.

 These do not exercise the generator itself — that is covered by
 `scripts/test_generate_credentials.sh`. They prove that whatever the
 generator wrote is observable through the global call sites the Health
 example app uses.
 */
final class CredentialsSmokeTests: XCTestCase {

    func testCredentialsEnumExposesAllKeys() {
        /// Compile-time proof the generated enum has every expected field.
        /// If the generator shape drifts, this suite fails to build.
        XCTAssertFalse(Credentials.clientID.isEmpty,
                       "`.env.local` must populate GINI_CLIENT_ID before this suite runs.")
        _ = Credentials.clientPassword
        _ = Credentials.clientDomain
    }

    func testGlobalsMatchGeneratedEnum() {
        XCTAssertEqual(clientID, Credentials.clientID)
        XCTAssertEqual(clientPassword, Credentials.clientPassword)
        XCTAssertEqual(clientDomain, Credentials.clientDomain)
    }
}
