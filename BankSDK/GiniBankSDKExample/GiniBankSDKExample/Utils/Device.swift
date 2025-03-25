//
//  Device.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 13.09.23.
//

import UIKit

class Device {
    static var small: Bool {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight <= 667 // Targets iPhone SE 1st Gen, 6/7/8, SE 2nd Gen
    }
}
