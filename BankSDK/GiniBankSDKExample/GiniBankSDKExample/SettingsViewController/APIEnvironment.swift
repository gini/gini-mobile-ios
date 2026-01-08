//
//  APIEnvironment.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import GiniBankAPILibrary

enum APIEnvironment: String {
    case production = "Prod"
    case stage = "Stage"

    var api: APIDomain {
        switch self {
        case .production:
            return .default
        case .stage:
            return .custom(domain: "pay-api.stage.gini.net", tokenSource: nil)
        }
    }

   var userApi: UserDomain {
        switch self {
        case .production:
            return .default
        case .stage:
            return .custom(domain: "user.stage.gini.net")
        }
    }
}
