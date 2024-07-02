//
//  GiniMainScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
class GiniMainScreenUITests: GiniBankSDKExampleUITests {
    
    func testMainScreenFunctionality() throws {
        let mainScreen = initializeMainScreen()
        mainScreen.assertMainScreenTitle()
        mainScreen.assertMainScreenSubHeading()
        mainScreen.tapPhotoPaymentButton()
        mainScreen.tapCameraIconButton()
        mainScreen.tapConfigurationButton()
    }
    
}
