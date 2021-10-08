//
//  PaymentProvider.swift
//  GiniHealthAPILib
//
//  Created by Nadya Karaban on 15.03.21.
//

import Foundation

/**
 Struct for MinAppVersions in payment provider response
 */
struct MinAppVersions: Codable {
    var ios: String?
    var android: String?
}
/**
 Struct for payment provider response
 */
public struct PaymentProvider: Codable {
    public var id: String
    public var name: String
    public var appSchemeIOS: String
    var minAppVersion: MinAppVersions?
}

public typealias PaymentProviders = [PaymentProvider]
