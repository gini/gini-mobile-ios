//
//  PaymentProvider.swift
//  GiniHealthAPI
//
//  Created by Nadya Karaban on 15.03.21.
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
    var background: String
    var text: String
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
    var iconLocation: String

    public init(id: String, name: String, appSchemeIOS: String, minAppVersion: MinAppVersions?, colors: ProviderColors, iconLocation: String) {
        self.id = id
        self.name = name
        self.appSchemeIOS = appSchemeIOS
        self.minAppVersion = minAppVersion
        self.colors = colors
        self.iconLocation = iconLocation
    }
}
