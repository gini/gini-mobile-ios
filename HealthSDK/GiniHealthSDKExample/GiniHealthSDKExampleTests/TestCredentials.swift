//
//  TestCredentials.swift
//  GiniHealthSDKExampleTests
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniHealthSDKExample

/// Resolves test credentials from CI environment variables when available,
/// falling back to the local CredentialsManager constants for development.
var testClientID: String {
    let value = ProcessInfo.processInfo.environment["CLIENT_ID"] ?? ""
    return value.isEmpty ? clientID : value
}

var testClientPassword: String {
    let value = ProcessInfo.processInfo.environment["CLIENT_SECRET"] ?? ""
    return value.isEmpty ? clientPassword : value
}

var testClientDomain: String {
    let value = ProcessInfo.processInfo.environment["CLIENT_DOMAIN"] ?? ""
    return value.isEmpty ? clientDomain : value
}
