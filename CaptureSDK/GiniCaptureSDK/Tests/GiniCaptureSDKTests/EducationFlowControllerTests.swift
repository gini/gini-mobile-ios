//
//  EducationFlowControllerTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniCaptureSDK

final class EducationFlowControllerTests: XCTestCase {

    func testNextStateReturnsShowOriginalFlowWhenShouldNotBeDisplayed() {
        let config = EducationFlowConfiguration(
            maxTotalDisplays: 3,
            numberOfMessages: 2,
            shouldBeDisplayed: { false },
            getDisplayCount: { 0 },
            setDisplayCount: { _ in }
        )

        let controller = EducationFlowController(configuration: config)
        let state = controller.nextState()
        XCTAssertEqual(state,
                       .showOriginalFlow,
                       "Expected .showOriginalFlow when shouldBeDisplayed is false.")
    }

    func testNextStateWithSingleMessage() {
        let config = EducationFlowConfiguration(
            maxTotalDisplays: 2,
            numberOfMessages: 1,
            shouldBeDisplayed: { true },
            getDisplayCount: { 1 }, // 1 % 1 = 0
            setDisplayCount: { _ in }
        )

        let controller = EducationFlowController(configuration: config)
        let state = controller.nextState()

        XCTAssertEqual(state,
                       .showMessage(messageIndex: 0),
                       "Expected messageIndex 0 when there's only one message.")
    }


    func testNextStateReturnsShowOriginalFlowWhenDisplayLimitReached() {
        let config = EducationFlowConfiguration(
            maxTotalDisplays: 3,
            numberOfMessages: 2,
            shouldBeDisplayed: { true },
            getDisplayCount: { 3 },
            setDisplayCount: { _ in }
        )

        let controller = EducationFlowController(configuration: config)
        let state = controller.nextState()
        XCTAssertEqual(state,
                       .showOriginalFlow,
                       "Expected .showOriginalFlow when display count reaches maxTotalDisplays.")
    }

    func testNextStateReturnsCorrectMessageIndex() {
        let config = EducationFlowConfiguration(
            maxTotalDisplays: 5,
            numberOfMessages: 3,
            shouldBeDisplayed: { true },
            getDisplayCount: { 4 },
            setDisplayCount: { _ in }
        )

        let controller = EducationFlowController(configuration: config)
        let state = controller.nextState()
        XCTAssertEqual(state,
                       .showMessage(messageIndex: 1),
                       "Expected .showMessage with messageIndex 1 when displayCount is 4 and numberOfMessages is 3.")
    }

    func testMarkMessageAsShownIncrementsDisplayCount() {
        var displayCount = 2
        let config = EducationFlowConfiguration(
            maxTotalDisplays: 5,
            numberOfMessages: 3,
            shouldBeDisplayed: { true },
            getDisplayCount: { displayCount },
            setDisplayCount: { newCount in displayCount = newCount }
        )

        let controller = EducationFlowController(configuration: config)
        controller.markMessageAsShown()

        XCTAssertEqual(displayCount, 3, "Expected displayCount to be incremented to 3 after markMessageAsShown()")
    }

    func testNextStateReturnsShowOriginalFlowWhenDisplayCountExceedsMaxTotalDisplays() {
        let config = EducationFlowConfiguration(
            maxTotalDisplays: 3,
            numberOfMessages: 2,
            shouldBeDisplayed: { true },
            getDisplayCount: { 5 },
            setDisplayCount: { _ in
                XCTFail("setDisplayCount should not be called when over maxTotalDisplays")
            }
        )

        let controller = EducationFlowController(configuration: config)
        let state = controller.nextState()

        XCTAssertEqual(state,
                       .showOriginalFlow,
                       "Expected .showOriginalFlow when displayCount exceeds maxTotalDisplays.")
    }

    func testNextStateReturnsMessageWhenDisplayCountIsOneBelowLimit() {
        var newDisplayCount: Int?

        let config = EducationFlowConfiguration(
            maxTotalDisplays: 3,
            numberOfMessages: 2,
            shouldBeDisplayed: { true },
            getDisplayCount: { 2 },
            setDisplayCount: { newDisplayCount = $0 }
        )

        let controller = EducationFlowController(configuration: config)
        let state = controller.nextState()
        controller.markMessageAsShown()

        XCTAssertEqual(state,
                       .showMessage(messageIndex: 0),
                       "Expected messageIndex 0 when displayCount is 2.")
        XCTAssertEqual(newDisplayCount,
                       3,
                       "Expected displayCount to be incremented to 3.")
    }
}
