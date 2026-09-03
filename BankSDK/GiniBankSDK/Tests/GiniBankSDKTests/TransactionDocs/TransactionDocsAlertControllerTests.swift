//
//  TransactionDocsAlertControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK

class TransactionDocsAlertControllerTests: XCTestCase {
    fileprivate var mockViewController: MockViewController!

    override func setUp() {
        super.setUp()
        mockViewController = MockViewController()
    }

    override func tearDown() {
        mockViewController = nil
        super.tearDown()
    }

    func testAlertControllerIsPresented() {
        TransactionDocsAlertController.show(on: mockViewController,
                                            alwaysAttachHandler: {
                                                // Not testing the implementation of this closure
                                            },
                                            attachOnceHandler: {
                                                // Not testing the implementation of this closure
                                            },
                                            doNotAttachHandler: {
                                                // Not testing the implementation of this closure
                                            })

        XCTAssertTrue(mockViewController.presentCalled,
                      "Expected present() to be called when presenting alert controller")
        XCTAssertNotNil(mockViewController.viewControllerToPresent as? UIAlertController,
                        "Expected presented view controller to be of type UIAlertController")

        let alertController = mockViewController.viewControllerToPresent as? UIAlertController
        XCTAssertEqual(alertController?.actions.count,
                       3,
                       "Expected UIAlertController to have exactly 3 actions")
    }
}

fileprivate class MockViewController: UIViewController {
    var presentCalled = false
    var viewControllerToPresent: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCalled = true
        self.viewControllerToPresent = viewControllerToPresent
    }
}
