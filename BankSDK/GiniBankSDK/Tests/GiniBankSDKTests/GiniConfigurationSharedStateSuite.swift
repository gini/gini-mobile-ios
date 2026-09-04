//
//  GiniConfigurationSharedStateSuite.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Testing

/**
 Parent suite for all tests that read or mutate the `GiniConfiguration.shared` singleton.

 `GiniBankConfiguration.captureConfiguration()` writes into `GiniConfiguration.shared`
 and returns it, and `GiniBankNetworkingScreenApiCoordinator.startSDK` mutates the same
 singleton (partly via async main-queue dispatches). Swift Testing runs suites in
 parallel by default, so two suites touching that singleton can overwrite each other's
 state mid-assertion and fail flakily.

 The `.serialized` trait applies recursively, so every suite nested in this enum runs
 serially relative to the others. Nest any new suite that touches
 `GiniConfiguration.shared` inside this type.
 */
@Suite("GiniConfiguration shared-state tests", .serialized)
enum GiniConfigurationSharedStateSuite {}
