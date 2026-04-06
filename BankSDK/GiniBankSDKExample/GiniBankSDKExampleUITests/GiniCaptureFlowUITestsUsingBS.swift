//
//  GiniCaptureFlowUITestsUsingBS.swift
//  GiniBankSDKExampleUITests
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//

import XCTest
import BrowserStackTestHelper

class GiniCaptureFlowUITestsUsingBS: GiniBankSDKExampleUITests {
    
    // MARK: - Capture Flow Test for Photopayment flow using Browserstack

    func testPPCaptureFlow() throws {
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        let injector: InjectorProtocol = InjectorFactory.createInstance()
        let injected = expectation(description: "camera injection complete")
        injector.injectImage(imageName: "Photopayment_Invoice1.png") { response in
            print(response.toDictionary())
            injected.fulfill()
        }
        wait(for: [injected], timeout: 10)

        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10), "Capture button should appear")
        captureScreen.captureButton.tap()

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15), "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5), "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        let doneButton = app.navigationBars.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10), "Done button should exist on the extraction screen")

        let ibanContainer = app.otherElements.containing(.staticText, identifier: "iban").firstMatch
        XCTAssertTrue(ibanContainer.waitForExistence(timeout: 5), "IBAN field container should exist on the extraction screen")
        let ibanField = ibanContainer.textFields.firstMatch
        XCTAssertTrue(ibanField.exists, "IBAN text field should exist")
        XCTAssertFalse((ibanField.value as? String)?.isEmpty ?? true, "IBAN field should not be empty")

        doneButton.tap()

        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5), "Should return to main screen after tapping Done")
    }
    
    // MARK: - Capture Flow Test for CX payment using Browserstack - need to check the image used here its not completely injecting into the BS camera looks like some dimention issue
    
    func testCXCaptureFlow() throws {
        mainScreen.configurationButton.tap()
        let crossBorderButton = app.buttons["Cross-border"]
        XCTAssertTrue(crossBorderButton.waitForExistence(timeout: 5), "Cross-border option should exist in Product Tag section")
        crossBorderButton.tap()

        let crossBorderClientButton = app.buttons["Cross border client"]
        XCTAssertTrue(crossBorderClientButton.waitForExistence(timeout: 5), "Cross border client option should exist in Credentials Set section")
        crossBorderClientButton.tap()

        let okButton = app.alerts.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5), "OK button should appear after credentials change")
        okButton.tap()

        settingScreen.closeButton.tap()
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()

        let injector: InjectorProtocol = InjectorFactory.createInstance()
        let injected = expectation(description: "camera injection complete")
        injector.injectImage(imageName: "Swift_AccNo_routing_DOLL.png") { response in
            print(response.toDictionary())
            injected.fulfill()
        }
        wait(for: [injected], timeout: 10)

        XCTAssertTrue(captureScreen.captureButton.waitForExistence(timeout: 10), "Capture button should appear")
        captureScreen.captureButton.tap()

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15), "Process button should appear in review screen")
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5), "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        let doneButton = app.navigationBars.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10), "Done button should exist on extraction screen")

        let extractionFields: [String] = [
            "creditorName", "creditorIBAN", "creditorAccountNumber", "creditorStreet",
            "creditorCity", "creditorPostalCode", "creditorCountry", "creditorAgentBIC",
            "creditorAgentName", "creditorAgentStreet", "creditorAgentCity", "currency",
            "instructedAmount", "remittanceInformation", "chargeBearer", "purposeCode",
            "instructionPriority", "bankInstructionCode", "economicCode", "creditorNationalId",
            "creditorAgentABA", "creditorAgentTransitNumber", "creditorAgentCNAPS",
            "creditorAgentSortCode", "creditorAgentBOKCode", "creditorAgentISPB",
            "creditorAgentBSB", "creditorAgentIFSC", "creditorAgentBankBranchCode",
            "creditorAgentIBGCode", "creditorAgentThaiCode", "creditorAgentBranchCode",
            "creditorAgentNZCode", "creditorCLABE"
        ]
        var extractionResults: [String: String] = [:]
        for field in extractionFields {
            let textField = app.textFields[field]
            let staticText = app.staticTexts[field]
            if textField.exists {
                extractionResults[field] = textField.value as? String ?? "present (no value)"
            } else if staticText.exists {
                extractionResults[field] = staticText.label.isEmpty ? "present (empty)" : staticText.label
            } else {
                extractionResults[field] = "not found"
            }
        }
        let found = extractionResults.filter { $0.value != "not found" }.keys.sorted()
        let notFound = extractionResults.filter { $0.value == "not found" }.keys.sorted()
        print("=== Extraction Screen Field Report ===")
        print("Found (\(found.count)):")
        found.forEach { print("  [FOUND] \($0): \(extractionResults[$0]!)") }
        print("Not Found (\(notFound.count)):")
        notFound.forEach { print("  [NOT FOUND] \($0)") }
        print("======================================")
        XCTAssertFalse(found.isEmpty, "None of the expected CX extraction fields were found on the extraction screen")

        let keyFields = ["creditorIBAN", "creditorAccountNumber", "creditorName", "creditorAgentBIC"]
        print("=== Key Payment Fields Verification ===")
        var anyKeyFieldHasValue = false
        for field in keyFields {
            let value = extractionResults[field]
            if let value = value, !value.isEmpty, value != "not found", value != "present (empty)", value != "present (no value)" {
                print("  [VALUE] \(field): \(value)")
                anyKeyFieldHasValue = true
            } else {
                print("[EMPTY] \(field): not available or empty")
            }
        }
        XCTAssertTrue(anyKeyFieldHasValue, "All key payment fields (creditorIBAN, creditorAccountNumber, creditorName, creditorAgentBIC) are empty or not found")
        print("=======================================")

        doneButton.tap()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5), "Should return to main screen after tapping Done")
    }
    
    
    // MARK: - Upload photo from gallery Flow Test for CX payment using Browserstack

    func testCXflowGalleryUpload() {
        mainScreen.configurationButton.tap()
        let crossBorderButton = app.buttons["Cross-border"]
        XCTAssertTrue(crossBorderButton.waitForExistence(timeout: 5), "Cross-border option should exist in Product Tag section")
        crossBorderButton.tap()

        let crossBorderClientButton = app.buttons["Cross border client"]
        XCTAssertTrue(crossBorderClientButton.waitForExistence(timeout: 5), "Cross border client option should exist in Credentials Set section")
        crossBorderClientButton.tap()

        let okButton = app.alerts.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5), "OK button should appear after credentials change")
        okButton.tap()

        settingScreen.closeButton.tap()
        mainScreen.photoPaymentButton.tap()
        mainScreen.handleCameraPermission(answer: true)
        onboadingScreen.skipOnboardingScreens()
        captureScreen.filesButton.tap()
        captureScreen.uploadPhotoButton.tap()
        mainScreen.handlePhotoPermission(answer: true)
        uploadLatestPhotoFromGallery()

        XCTAssertTrue(reviewScreen.processButton.waitForExistence(timeout: 15))
        reviewScreen.waitForElementToBecomeEnabled(reviewScreen.processButton, timeout: 10)
        reviewScreen.processButton.tap()

        XCTAssertTrue(transactionDocsScreen.onlyForThisTransaction.waitForExistence(timeout: 5), "Transaction docs option should appear")
        transactionDocsScreen.onlyForThisTransaction.tap()

        let doneButton = app.navigationBars.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 10), "Done button should exist on extraction screen")

        let extractionFields: [String] = [
            "creditorName", "creditorIBAN", "creditorAccountNumber", "creditorStreet",
            "creditorCity", "creditorPostalCode", "creditorCountry", "creditorAgentBIC",
            "creditorAgentName", "creditorAgentStreet", "creditorAgentCity", "currency",
            "instructedAmount", "remittanceInformation", "chargeBearer", "purposeCode",
            "instructionPriority", "bankInstructionCode", "economicCode", "creditorNationalId",
            "creditorAgentABA", "creditorAgentTransitNumber", "creditorAgentCNAPS",
            "creditorAgentSortCode", "creditorAgentBOKCode", "creditorAgentISPB",
            "creditorAgentBSB", "creditorAgentIFSC", "creditorAgentBankBranchCode",
            "creditorAgentIBGCode", "creditorAgentThaiCode", "creditorAgentBranchCode",
            "creditorAgentNZCode", "creditorCLABE"
        ]
        var extractionResults: [String: String] = [:]
        for field in extractionFields {
            let textField = app.textFields[field]
            let staticText = app.staticTexts[field]
            if textField.exists {
                extractionResults[field] = textField.value as? String ?? "present (no value)"
            } else if staticText.exists {
                extractionResults[field] = staticText.label.isEmpty ? "present (empty)" : staticText.label
            } else {
                extractionResults[field] = "not found"
            }
        }
        let found = extractionResults.filter { $0.value != "not found" }.keys.sorted()
        let notFound = extractionResults.filter { $0.value == "not found" }.keys.sorted()
        print("=== Extraction Screen Field Report ===")
        print("Found (\(found.count)):")
        found.forEach { print("  [FOUND] \($0): \(extractionResults[$0]!)") }
        print("Not Found (\(notFound.count)):")
        notFound.forEach { print("  [NOT FOUND] \($0)") }
        print("======================================")
        XCTAssertFalse(found.isEmpty, "None of the expected extraction fields were found on the extraction screen")

        let keyFields = ["creditorIBAN", "creditorAccountNumber", "creditorName", "creditorAgentBIC"]
        print("=== Key Payment Fields Verification ===")
        var anyKeyFieldHasValue = false
        for field in keyFields {
            let value = extractionResults[field]
            if let value = value, !value.isEmpty, value != "not found", value != "present (empty)", value != "present (no value)" {
                print("  [VALUE] \(field): \(value)")
                anyKeyFieldHasValue = true
            } else {
                print("  [EMPTY] \(field): not available or empty")
            }
        }
        XCTAssertTrue(anyKeyFieldHasValue, "All key payment fields (creditorIBAN, creditorAccountNumber, creditorName, creditorAgentBIC) are empty or not found")
        print("=======================================")

        doneButton.tap()
        XCTAssertTrue(mainScreen.photoPaymentButton.waitForExistence(timeout: 5), "Should return to main screen after tapping Done")
    }
    
}
