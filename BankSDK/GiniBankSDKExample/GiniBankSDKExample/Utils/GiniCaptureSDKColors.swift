//
//  GiniCaptureSDKColors.swift
//  GiniBankSDKExample
//
//  Created by Valentina Iancu on 18.09.23.
//

import UIKit
import GiniCaptureSDK

func giniCaptureColor(_ name: String) -> UIColor {
    return UIColor(named: name, in: GiniCaptureSDK.giniCaptureBundle(), compatibleWith: nil) ?? ColorPalette.defaultBackground
}
