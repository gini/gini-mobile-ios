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
        return deviceModel()
    }

    var identifierForVendor: String? {
        return device.identifierForVendor?.uuidString
    }

    var osName: String {
        return device.systemName.lowercased()
    }

    var osVersion: String {
        return device.systemVersion
    }

   let platform: String = "iOS"

    var systemLanguage: String? {
        return Locale.preferredLanguages.first
    }

    private func getPlatformString() -> String {
        var name: [Int32] = [CTL_HW, HW_MACHINE]
        var size: Int = 2
        sysctl(&name, 2, nil, &size, nil, 0)
        var hw_machine = [CChar](repeating: 0, count: Int(size))
        sysctl(&name, 2, &hw_machine, &size, nil, 0)
        let platform = String(cString: hw_machine)
        return platform
    }

    private func deviceModel() -> String {
        let platform = getPlatformString()
        return getDeviceModel(platform: platform)
    }

    private var isRunningInAppExtension: Bool {
        return Bundle.main.bundlePath.hasSuffix(".appex")
    }

    private func getDeviceModel(platform: String) -> String {
        // use server device mapping except for the following exceptions

        if platform == "i386" || platform == "x86_64" {
            return "Simulator"
        }

        return platform
    }
}
