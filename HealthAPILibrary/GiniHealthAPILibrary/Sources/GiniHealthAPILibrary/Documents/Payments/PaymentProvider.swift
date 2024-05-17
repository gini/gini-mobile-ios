//
//  PaymentProvider.swift
//  GiniHealthAPI
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation
/**
 Struct for payment provider
 */
public struct PaymentProvider: Codable {
    public var id: String
    public var name: String
    public var appSchemeIOS: String
    public var colors: ProviderColors
    public var minAppVersion: MinAppVersions?
    public var iconData: Data
    public var appStoreUrlIOS: String?
    public var universalLinkIOS: String
    public var gpcSupported: Bool = true
    public var index: Int?

    public init(id: String, name: String, appSchemeIOS: String, minAppVersion: MinAppVersions?, colors: ProviderColors, iconData: Data, appStoreUrlIOS: String?, universalLinkIOS: String, index: Int?) {
        self.id = id
        self.name = name
        self.appSchemeIOS = appSchemeIOS
        self.minAppVersion = minAppVersion
        self.colors = colors
        self.iconData = iconData
        self.appStoreUrlIOS = appStoreUrlIOS
        self.universalLinkIOS = universalLinkIOS
        self.index = index
    }
}
public typealias PaymentProviders = [PaymentProvider]

extension PaymentProvider: Equatable {
    public static func == (lhs: PaymentProvider, rhs: PaymentProvider) -> Bool {
        lhs.id == rhs.id
    }
}
