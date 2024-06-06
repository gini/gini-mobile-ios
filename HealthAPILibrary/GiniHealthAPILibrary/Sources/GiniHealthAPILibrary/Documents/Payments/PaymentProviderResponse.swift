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
 Struct for payment provider colors in payment provider response
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
 Enum for platforms supported by payment providers. We now support iOS and Android
 */
public enum PlatformSupported: String, Codable {
    case ios
    case android
}
/**
 Struct for payment provider response
 */
public struct PaymentProviderResponse: Codable {
    public var id: String
    public var name: String
    public var appSchemeIOS: String
    public var colors: ProviderColors
    public var minAppVersion: MinAppVersions?
    public var iconLocation: String
    public var appStoreUrlIOS: String?
    public var universalLinkIOS: String
    public var index: Int?
    public var gpcSupportedPlatforms: [PlatformSupported]
    public var openWithSupportedPlatforms: [PlatformSupported]

    public init(id: String, name: String, appSchemeIOS: String, minAppVersion: MinAppVersions?, colors: ProviderColors, iconLocation: String, appStoreUrlIOS: String?, universalLinkIOS: String, index: Int?, gpcSupportedPlatforms: [PlatformSupported], openWithSupportedPlatforms: [PlatformSupported]) {
        self.id = id
        self.name = name
        self.appSchemeIOS = appSchemeIOS
        self.minAppVersion = minAppVersion
        self.colors = colors
        self.iconLocation = iconLocation
        self.appStoreUrlIOS = appStoreUrlIOS
        self.universalLinkIOS = universalLinkIOS
        self.index = index
        self.gpcSupportedPlatforms = gpcSupportedPlatforms
        self.openWithSupportedPlatforms = openWithSupportedPlatforms
    }
}
