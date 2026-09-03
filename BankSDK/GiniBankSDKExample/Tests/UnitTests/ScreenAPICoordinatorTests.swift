//
//  ScreenAPICoordinatorTests.swift
//  GiniCapture_Tests
//
//  Created by Enrique del Pozo Gómez on 11/14/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDKExample
@testable import GiniBankAPILibrary
@testable import GiniBankSDK


final class ScreenAPICoordinatorTests: XCTestCase {
    
    let client = Client(id: "",
                        secret: "",
                        domain: "")
    var screenAPICoordinator: ScreenAPICoordinator?
    
    func testInitialization() {
        screenAPICoordinator = ScreenAPICoordinator(apiEnvironment: .production,
                                                    enablePinningSDK: false,
                                                    configuration: GiniBankConfiguration(),
                                                    importedDocuments: nil,
                                                    client: client,
                                                    documentMetadata: nil)
        screenAPICoordinator?.start()
        
        XCTAssertNotNil(screenAPICoordinator?.rootViewController,
                        "the root view controller should never be nil")
        XCTAssertTrue(screenAPICoordinator?.childCoordinators.count == 0,
                      "there should not be child coordinators on initialization")
        XCTAssertNotNil(screenAPICoordinator?.screenAPIViewController.delegate as? ScreenAPICoordinator,
                        "screen API view controller delegate should be the coordinator")
    }

}
