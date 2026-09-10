//
//  DelayableMockSessionManager.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniHealthAPILibrary

/**
 Session-manager mock that mirrors `MockSessionManager`'s fixture routing but
 defers `.extractions` API-method callbacks by `extractionsDelay` seconds.

 Used by the silent-drop regression tests: the deferred callback opens a real
 window between the initial `fetchDocument` completion (which fires
 synchronously through the base mock) and the extractions completion — long
 enough for a test to drop its strong reference to `GiniHealth` before the
 pending closure fires. Any regression that re-introduces `[weak self]` on the
 inner extractions closures in `GiniHealth.swift` would silently drop the
 caller's completion; these tests would then time out.
 */
final class DelayableMockSessionManager: SessionManagerProtocol {

    private let base = MockSessionManager()
    let extractionsDelay: TimeInterval

    init(extractionsDelay: TimeInterval = 0.1) {
        self.extractionsDelay = extractionsDelay
    }

    func data<T>(resource: T,
                 cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                 completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {
        if let apiMethod = resource.method as? APIMethod, case .extractions = apiMethod {
            let base = self.base
            DispatchQueue.global().asyncAfter(deadline: .now() + extractionsDelay) {
                base.data(resource: resource,
                          cancellationToken: cancellationToken,
                          completion: completion)
            }
        } else {
            base.data(resource: resource,
                      cancellationToken: cancellationToken,
                      completion: completion)
        }
    }

    func upload<T>(resource: T,
                   data: Data,
                   cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                   completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {
        base.upload(resource: resource,
                    data: data,
                    cancellationToken: cancellationToken,
                    completion: completion)
    }

    func download<T>(resource: T,
                     cancellationToken: GiniHealthAPILibrary.CancellationToken?,
                     completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T: GiniHealthAPILibrary.Resource {
        base.download(resource: resource,
                      cancellationToken: cancellationToken,
                      completion: completion)
    }

    func logIn(completion: @escaping (Result<GiniHealthAPILibrary.Token, GiniHealthAPILibrary.GiniError>) -> Void) {
        base.logIn(completion: completion)
    }

    func logOut() {
        base.logOut()
    }
}
