//
//  Utils.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import Foundation
@testable import GiniPayApiLib

func loadFile(withName name: String, ofType type: String) -> Data {
    let fileURLPath: String? = Bundle(for: GiniDocumentTests.self)
        .path(forResource: name, ofType: type)
    let data = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return data!
}

func load<T: Decodable>(fromFile named: String, type: String) -> T {
    let jsonData = loadFile(withName: named, ofType: type)
    
    return (try? JSONDecoder().decode(T.self, from: jsonData))!
}

func loadProviders() -> PaymentProviders {
    let fileURLPath: String? = Bundle(for: GiniApiLibTests.self)
        .path(forResource: "providers", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return (try? JSONDecoder().decode(PaymentProviders.self, from: jsonData!))!
}

func loadPaymentRequests() -> PaymentRequests {
    let fileURLPath: String? = Bundle(for: GiniApiLibTests.self)
        .path(forResource: "paymentRequests", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return (try? JSONDecoder().decode(PaymentRequests.self, from: jsonData!))!
}

func loadProvider() -> PaymentProvider {
    let fileURLPath: String? = Bundle(for: GiniApiLibTests.self)
        .path(forResource: "provider", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return try! JSONDecoder().decode(PaymentProvider.self, from: jsonData!)
}

func loadPaymentRequest() -> PaymentRequest {
    let fileURLPath: String? = Bundle(for: GiniApiLibTests.self)
        .path(forResource: "paymentRequest", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
        return try! JSONDecoder().decode(PaymentRequest.self, from: jsonData!)
}

func loadResolvedPaymentRequest() -> ResolvedPaymentRequest {
    let fileURLPath: String? = Bundle(for: GiniApiLibTests.self)
        .path(forResource: "resolvedPaymentRequest", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
        return try! JSONDecoder().decode(ResolvedPaymentRequest.self, from: jsonData!)
}

func loadPayment() -> Payment {
    let fileURLPath: String? = Bundle(for: GiniApiLibTests.self)
        .path(forResource: "payment", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
        return try! JSONDecoder().decode(Payment.self, from: jsonData!)
}
