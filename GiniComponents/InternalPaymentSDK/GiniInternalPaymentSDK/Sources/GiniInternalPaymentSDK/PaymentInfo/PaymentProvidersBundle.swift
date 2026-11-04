//
//  PaymentProvidersBundle.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Combine
import GiniHealthAPILibrary

/**
 Pairs an initial payment-provider snapshot with the publisher that emits later updates.
 */
public struct PaymentProvidersBundle {
    public let initial: GiniHealthAPILibrary.PaymentProviders
    public let publisher: AnyPublisher<GiniHealthAPILibrary.PaymentProviders, Never>

    public init(initial: GiniHealthAPILibrary.PaymentProviders,
                publisher: AnyPublisher<GiniHealthAPILibrary.PaymentProviders, Never>) {
        self.initial = initial
        self.publisher = publisher
    }
}
