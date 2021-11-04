import XCTest

class GINIAnalysisUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        app.launch()
    }
    
    func testAnalysisIsPresent() {
        app.buttons["Screen API"].tap()
        app.buttons["Auslösen"].tap()
        let reviewScreen = app.navigationBars["1 von 1"]
        _ = reviewScreen.waitForExistence(timeout: 5)
        app.navigationBars["1 von 1"].buttons["Weiter"].tap()
        
        let analysisScreenLeftButton = app.navigationBars.buttons["Abbrechen"]
        XCTAssert(analysisScreenLeftButton.exists, "navigation bar with title 'Etwas Geduld, analysiere Foto' should be displayed")
    }
}
