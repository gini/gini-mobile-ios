//
//  IOSSystem.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import UIKit

internal class IOSSystem {
    private let device = UIDevice.current
    let manufacturer: String = "Apple"

    var model: String {
        deviceModel()
    }

    var identifierForVendor: String? {
        device.identifierForVendor?.uuidString
    }

    var osName: String {
        device.systemName.lowercased()
    }

    var osVersion: String {
        device.systemVersion
    }

    var systemLanguage: String? {
        Locale.preferredLanguages.first
    }

    var platform: String {
        device.userInterfaceIdiom == .pad  ? "iPadOS" : "iOS"
    }

    // MARK: - Private methods
    private func getPlatformString() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hwMachine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hwMachine, &size, nil, 0)
        return String(cString: hwMachine)
    }

    private func deviceModel() -> String {
        let platform = getPlatformString()
        return getDeviceModel(platform: platform)
    }

    private func getDeviceModel(platform: String) -> String {
        // use server device mapping except for the following exceptions

        if platform == "i386" || platform == "x86_64" {
            return "Simulator"
        }

        return platform
    }
}
