//
//  MainScreenUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import Foundation
class MainScreenUITests: GiniBankSDKExampleUITests {
    
    func testMainScreenFunctionality() throws {
        let mainScreen = initializeMainScreen()
        mainScreen.assertMainScreenTitle()
        mainScreen.assertMainScreenSubHeading()
        mainScreen.tapPhotoPaymentButton()
        mainScreen.tapCameraIconButton()
        mainScreen.tapConfigurationButton()
    }
    
}
