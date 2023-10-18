//
//  Device.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 13.09.23.
//

import UIKit

class Device {
    static var small: Bool {
        return UIScreen.main.bounds.width <= 320
    }
}
