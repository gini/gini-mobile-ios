//
//  PaymentProvider.swift
//  GiniHealthSDK
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
import GiniHealthAPILibrary
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
    public var index: Int?
    public var gpcSupportedPlatforms: [PlatformSupported]
    public var openWithSupportedPlatforms: [PlatformSupported]

    public init(id: String, name: String, appSchemeIOS: String, minAppVersion: MinAppVersions?, colors: ProviderColors, iconData: Data, appStoreUrlIOS: String?, universalLinkIOS: String, index: Int?, gpcSupportedPlatforms: [PlatformSupported], openWithSupportedPlatforms: [PlatformSupported]) {
        self.id = id
        self.name = name
        self.appSchemeIOS = appSchemeIOS
        self.minAppVersion = minAppVersion
        self.colors = colors
        self.iconData = iconData
        self.appStoreUrlIOS = appStoreUrlIOS
        self.universalLinkIOS = universalLinkIOS
        self.index = index
        self.gpcSupportedPlatforms = gpcSupportedPlatforms
        self.openWithSupportedPlatforms = openWithSupportedPlatforms
    }
}
public typealias PaymentProviders = [PaymentProvider]

extension PaymentProvider: Equatable {
    public static func == (lhs: PaymentProvider, rhs: PaymentProvider) -> Bool {
        lhs.id == rhs.id
    }
}

/**
 Struct for MinAppVersions in payment provider response
 */
public struct MinAppVersions: Codable {
    internal let healthMinAppVersions: GiniHealthAPILibrary.MinAppVersions

    public init(ios: String?, android: String?) {
        self.healthMinAppVersions = GiniHealthAPILibrary.MinAppVersions(ios: ios, android: android)
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
