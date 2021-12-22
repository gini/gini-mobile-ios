//
//  PaymentProvider.swift
//  GiniHealthAPI
//
//  Created by Nadya Karaban on 15.03.21.
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
    var minAppVersion: MinAppVersions?
    public var iconData: Data

    public init(id: String, name: String, appSchemeIOS: String, minAppVersion: MinAppVersions?, colors: ProviderColors, iconData: Data) {
        self.id = id
        self.name = name
        self.appSchemeIOS = appSchemeIOS
        self.minAppVersion = minAppVersion
        self.colors = colors
        self.iconData = iconData
    }
}
public typealias PaymentProviders = [PaymentProvider]
