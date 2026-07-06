//
//  CancellationToken.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

/**
 * Cancellation token needed during the analysis process.
 *
 * Calling `cancel()` sets the `isCancelled` flag so the SDK will discard any
 * subsequent response, and also cancels the underlying network request via
 * the `CancellableTask` returned by the `GiniHTTPClient`.
 */
public final class CancellationToken {
    internal weak var task: CancellableTask?

    // Indicates if the analysis has been cancelled
    public var isCancelled = false

    /**
     * Creates a new cancellation token.
     */
    public init() {
        // Explicit public initializer required for external module access
    }

    /**
     * Cancels the current task.
     *
     * This cancels the underlying network request (both for the default and
     * custom HTTP clients) and sets `isCancelled` to `true`.
     */
    public func cancel() {
        isCancelled = true
        task?.cancel()
    }
}
