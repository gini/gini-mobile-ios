//
//  Utils.swift
//  GiniExampleTests
//
//  Created by Enrique del Pozo Gómez on 1/14/18.
//  Copyright © 2018 Gini. All rights reserved.
//

import Foundation
@testable import GiniBankAPILibrary

func loadFile(withName name: String, ofType type: String) -> Data {
    let fileURLPath: String? = Bundle.module
        .path(forResource: name, ofType: type)
    let data = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return data!
}

func load<T: Decodable>(fromFile named: String, type: String) -> T {
    let jsonData = loadFile(withName: named, ofType: type)
    
    return (try? JSONDecoder().decode(T.self, from: jsonData))!
}

func loadPaymentRequests() -> PaymentRequests {
    let fileURLPath: String? = Bundle.module
        .path(forResource: "paymentRequests", ofType: "json")
    let jsonData = try? Data.init(contentsOf: URL(fileURLWithPath: fileURLPath!))
    
    return (try? JSONDecoder().decode(PaymentRequests.self, from: jsonData!))!
}
func loadPaymentRequest() -> PaymentRequest {
    guard let fileURLPath = Bundle.module.path(forResource: "paymentRequest", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let request = try? JSONDecoder().decode(PaymentRequest.self, from: jsonData) else {
        fatalError(" Could not load paymentRequest.json in tests")
    }
    return request
}

func loadResolvedPaymentRequest() -> ResolvedPaymentRequest {
    guard let fileURLPath = Bundle.module.path(forResource: "resolvedPaymentRequest", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let request = try? JSONDecoder().decode(ResolvedPaymentRequest.self, from: jsonData) else {
        fatalError("Could not load resolvedPaymentRequest.json in tests")
    }
    return request
}

func loadPayment() -> Payment {
    guard let fileURLPath = Bundle.module.path(forResource: "payment", ofType: "json"),
          let jsonData = try? Data(contentsOf: URL(fileURLWithPath: fileURLPath)),
          let payment = try? JSONDecoder().decode(Payment.self, from: jsonData) else {
        fatalError("Could not load payment.json in tests")
    }
    return payment
}
