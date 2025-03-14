//
//  SkontoEdgeCase.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

enum SkontoEdgeCase {
    case expired
    case paymentToday
    case payByCash

    var analyticsValue: String {
        switch self {
            case .expired:
                return "expired"
            case .paymentToday:
                return "pay_today"
            case .payByCash:
                return "pay_by_cash"
        }
    }
}
