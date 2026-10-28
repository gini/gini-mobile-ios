//
//  CredentialsSmokeTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDKExample
@testable import GiniBankAPILibrary

/**
 Smoke tests that pin the mapping between the build-time-generated
 `Credentials` enum (produced by `scripts/generate_credentials.sh`) and
 the `CredentialsManager.fetch*ClientFromBundle()` factories.

 These do not exercise the generator itself — that is covered by
 `scripts/test_generate_credentials.sh`. They prove that whatever the
 generator wrote is observable through the public `CredentialsManager`
 call sites that the app uses.
 */
final class CredentialsSmokeTests: XCTestCase {

    func testCredentialsEnumExposesAllKeys() {
        /// Compile-time proof the generated enum has every expected field.
        /// If the generator shape drifts, this suite fails to build.
        XCTAssertFalse(Credentials.clientID.isEmpty,
                       "`.env.local` must populate GINI_CLIENT_ID before this suite runs.")
        _ = Credentials.clientPassword
        _ = Credentials.clientDomain
        _ = Credentials.cxClientID
        _ = Credentials.cxClientPassword
        _ = Credentials.stageClientID
        _ = Credentials.stageClientPassword
    }

    func testFetchClientFromBundleProducesClientID() {
        let client = CredentialsManager.fetchClientFromBundle()
        XCTAssertEqual(client.id, Credentials.clientID)
        XCTAssertEqual(client.secret, Credentials.clientPassword)
        XCTAssertEqual(client.domain, Credentials.clientDomain)
    }

    func testFetchCXClientFromBundleProducesCXID() {
        let client = CredentialsManager.fetchCXClientFromBundle()
        XCTAssertEqual(client.id, Credentials.cxClientID)
        XCTAssertEqual(client.secret, Credentials.cxClientPassword)
        XCTAssertEqual(client.domain, Credentials.clientDomain)
    }
}
