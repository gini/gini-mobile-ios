//
//  ExampleAppUserDefaultsStorage.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import GiniUtilites

struct ExampleAppUserDefaultsStorage {

    @GiniUserDefault("enablePinningSDK", defaultValue: false)
    static var enablePinningSDK: Bool

    @GiniUserDefault("selectedCredentialsSetIndex", defaultValue: 0)
    static var selectedCredentialsSetIndex: Int

    @GiniUserDefault("currentAPIEnvironment", defaultValue: APIEnvironment.production)
    static var currentAPIEnvironment: APIEnvironment
}
