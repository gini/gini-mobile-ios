//
//  GiniBankSDKExampleUITests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//


import XCTest

final class GiniBankSDKExampleUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()


        app.buttons["Fotoüberweisung"].tap()
       let captureButton = app.buttons["CaptureButton"]

//        let element = app.navigationBars["Aufnahme"].buttons["Hilfe"]

        self.waitForElementToAppear(element: captureButton, timeout: 10)
        captureButton.tap()
        
//        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Tipps für bessere Ergebnisse"]/*[[".cells.staticTexts[\"Tipps für bessere Ergebnisse\"]",".staticTexts[\"Tipps für bessere Ergebnisse\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.navigationBars["Tipps"].buttons["Hilfe Zurück"].tap()
//        app.navigationBars["Hilfe"].buttons["Kamera Zurück"].tap()
        

    }

    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")

        expectation(for: existsPredicate,
                    evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
