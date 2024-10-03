//
//  TransactionDocsAlertControllerTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniBankSDK

class TransactionDocsAlertControllerTests: XCTestCase {
    fileprivate var mockViewController: MockViewController!
    var alwaysAttachHandlerCalled = false
    var attachOnceHandlerCalled = false
    var doNotAttachHandlerCalled = false

    override func setUp() {
        super.setUp()
        mockViewController = MockViewController()
        alwaysAttachHandlerCalled = false
        attachOnceHandlerCalled = false
        doNotAttachHandlerCalled = false
    }

    override func tearDown() {
        mockViewController = nil
        super.tearDown()
    }

    func testAlertControllerIsPresented() {
        TransactionDocsAlertController.show(on: mockViewController,
                                            alwaysAttachHandler: { },
                                            attachOnceHandler: { },
                                            doNotAttachHandler: { })

        XCTAssertTrue(mockViewController.presentCalled)
        XCTAssertNotNil(mockViewController.viewControllerToPresent as? UIAlertController)

        let alertController = mockViewController.viewControllerToPresent as? UIAlertController
        XCTAssertEqual(alertController?.actions.count, 3)
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
