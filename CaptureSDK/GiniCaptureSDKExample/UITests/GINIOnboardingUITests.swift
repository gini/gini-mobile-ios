import XCTest

class GINIOnboardingUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        app.launch()
    }

    func testScreenAPILaunchAndClose() {
        let screenAPIButton = app.buttons["Screen API"]
        screenAPIButton.tap()

        let closeButton = app.navigationBars["Dokument fotografieren"].buttons.firstMatch
        closeButton.tap()

        XCTAssert(screenAPIButton.exists, "should be back to launch screen including the screen api launch button")
    }
}
