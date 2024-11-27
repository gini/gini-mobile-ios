//
//  SessionManager.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
import GiniHealthAPILibrary

public typealias CompletionResult<T> = (Result<T, GiniError>) -> Void

/// Cancellation token needed during the analysis process
public final class CancellationToken {
    internal let healthToken: GiniHealthAPILibrary.CancellationToken

    /// Indicates if the analysis has been cancelled
    public var isCancelled: Bool {
        get { healthToken.isCancelled }
        set { healthToken.isCancelled = newValue }
    }

    public init() {
        self.healthToken = GiniHealthAPILibrary.CancellationToken()
    }

    public init(healthToken: GiniHealthAPILibrary.CancellationToken) {
        self.healthToken = healthToken
    }

    /// Cancels the current task
    public func cancel() {
        healthToken.cancel()
    }
}
