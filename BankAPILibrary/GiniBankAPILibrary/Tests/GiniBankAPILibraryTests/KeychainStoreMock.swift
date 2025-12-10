//
//  KeychainStoreMock.swift
//  GiniExampleTests
//
//  Copyright © 2018 Gini. All rights reserved.
//

import Foundation
@testable import GiniBankAPILibrary

final class KeychainStoreMock: KeyStore {
    var fakeItems: [KeychainManagerItem] = []

    func fetch(service: KeychainService, key: KeychainKey) -> String? {
        return fakeItems.first(where: { $0.service.rawValue == service.rawValue &&
            $0.key.rawValue == key.rawValue})?.value
    }
    
    func remove(service: KeychainService, key: KeychainKey) throws {
        if let index = fakeItems.firstIndex(where: { $0.service.rawValue == service.rawValue &&
            $0.key.rawValue == key.rawValue}) {
            fakeItems.remove(at: index)
        }
    }
    
    func save(item: KeychainManagerItem) throws {
        if fetch(service: item.service, key: item.key) == nil {
            fakeItems.append(item)
        }
    }
    
    func removeAll() {
        fakeItems.removeAll()
    }
    
}
