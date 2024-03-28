//
//  PaymentProvider.swift
//  GiniHealthAPI
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import Foundation

/**
 Struct for MinAppVersions in payment provider response
 */
public struct MinAppVersions: Codable {
    var ios: String?
    var android: String?
    public init(ios: String?, android: String?) {
        self.ios = ios
        self.android = android
    }
}

/**
 Struct for MinAppVersions in payment provider response
 */
public struct ProviderColors: Codable {
    public var background: String
    public var text: String
    public init(background: String, text: String) {
        self.background = background
        self.text = text
    }
}
/**
 Struct for payment provider response
 */
public struct PaymentProviderResponse: Codable {
    public var id: String
    public var name: String
    public var appSchemeIOS: String
    public var colors: ProviderColors
    var minAppVersion: MinAppVersions?
    public var iconLocation: String
    public var appStoreUrlIOS: String?
    public var universalLinkIOS: String

    public init(id: String, name: String, appSchemeIOS: String, minAppVersion: MinAppVersions?, colors: ProviderColors, iconLocation: String, appStoreUrlIOS: String?, universalLinkIOS: String) {
        self.id = id
        self.name = name
        self.appSchemeIOS = appSchemeIOS
        self.minAppVersion = minAppVersion
        self.colors = colors
        self.iconLocation = iconLocation
        self.appStoreUrlIOS = appStoreUrlIOS
        self.universalLinkIOS = universalLinkIOS
    }
}
