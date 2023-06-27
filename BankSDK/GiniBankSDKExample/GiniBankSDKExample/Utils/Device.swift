//
//  Device.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 19.06.23.
//

import UIKit

struct Device {
	static var small: Bool {
		return UIScreen.main.bounds.width <= 320
	}
}
