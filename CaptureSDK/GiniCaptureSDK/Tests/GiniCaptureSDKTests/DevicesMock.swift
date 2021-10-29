//
//  DevicesMock.swift
//  GiniCapture-Unit-Tests
//
//  Created by Enrique del Pozo Gómez on 2/19/19.
//

import UIKit
@testable import GiniCaptureSDK
final class IpadDevice: UIDevice {
    override var userInterfaceIdiom: UIUserInterfaceIdiom {
        return .pad
    }
}

final class IphoneDevice: UIDevice {
    
    override var userInterfaceIdiom: UIUserInterfaceIdiom {
        return .phone
    }
    
}
