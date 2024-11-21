//
//  NetworkingScreenApiCoordinatorTests.swift
//
//  Copyright © 2024 Gini GmbH. All rights reserved.
//

@testable import GiniBankAPILibrary
@testable import GiniBankSDK
@testable import GiniCaptureSDK
import XCTest

private class MockTokenSource: AlternativeTokenSource {
    var tokenToReturn: Token?
    func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        if let tokenToReturn {
            completion(.success(tokenToReturn))
        } else {
            completion(.failure(.requestCancelled))
        }
    }
}

private class MockCaptureResultsDelegate: GiniCaptureResultsDelegate {
    func giniCaptureAnalysisDidFinishWith(result: AnalysisResult) {
    }
    
    func giniCaptureDidCancelAnalysis() {
    }
    
    func giniCaptureDidEnterManually() {
    }
}

private class MockTrackingDelegate: GiniCaptureTrackingDelegate {
    func onOnboardingScreenEvent(event: Event<OnboardingScreenEventType>) {
    }
    
    func onCameraScreenEvent(event: Event<CameraScreenEventType>) {
    }
    
    func onReviewScreenEvent(event: Event<ReviewScreenEventType>) {
    }
    
    func onAnalysisScreenEvent(event: Event<AnalysisScreenEventType>) {
    }
}

final class NetworkingScreenApiCoordinatorTests: XCTestCase {

    func testInitWithAlternativeTokenSource() throws {
        /// ready
        let source = MockTokenSource()
        let testToken = Token(expiration: .init(), scope: "scope", type: "type", accessToken: "some_totally_random_gibberish")
        source.tokenToReturn = testToken
        let resultsDelegate = MockCaptureResultsDelegate()
        let cfg = GiniBankConfiguration()
        let metadata = Document.Metadata(branchId: "branch")
        let trackingDelegate = MockTrackingDelegate()

        /// set
        let coord = GiniBankNetworkingScreenApiCoordinator(alternativeTokenSource: source, resultsDelegate: resultsDelegate, configuration: cfg, documentMetadata: metadata, trackingDelegate: trackingDelegate)
        let service = try XCTUnwrap(
            (
                (coord.documentService as? GiniCaptureSDK.DocumentService)?
                    .captureNetworkService as? DefaultCaptureNetworkService
            )?.documentService
        )

        /// test

        // check default api domain
        XCTAssertEqual(service.apiDomain.domainString, "pay-api.gini.net")

        // check for correct token
        let logInExpectation = self.expectation(description: "login")
        var receivedTokenOptional: Token?
        service.sessionManager.logIn { result in
            switch result {
                case .success(let token):
                receivedTokenOptional = token
                logInExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failure: \(error.localizedDescription)")
            }
        }
        wait(for: [logInExpectation], timeout: 1)

        let receivedToken = try XCTUnwrap(receivedTokenOptional)
        XCTAssertEqual(receivedToken, testToken)

        // check for delegates/configs
        XCTAssertNotNil(coord.resultsDelegate as? MockCaptureResultsDelegate)
        XCTAssertEqual(coord.giniBankConfiguration, cfg)
        XCTAssertNotNil(coord.trackingDelegate as? MockTrackingDelegate)
        XCTAssertEqual(coord.documentService.metadata?.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey], "branch")
    }

    func testViewControllerWithAlternativeTokenSource() throws {
        /// ready
        let source = MockTokenSource()
        let testToken = Token(expiration: .init(), scope: "scope", type: "type", accessToken: "some_totally_random_gibberish")
        source.tokenToReturn = testToken
        let resultsDelegate = MockCaptureResultsDelegate()
        let cfg = GiniBankConfiguration()
        let metadata = Document.Metadata(branchId: "branch")
        let trackingDelegate = MockTrackingDelegate()

        /// set
        let vc = try XCTUnwrap(
            GiniBank.viewController(withAlternativeTokenSource: source, configuration: cfg, resultsDelegate: resultsDelegate, documentMetadata: metadata, trackingDelegate: trackingDelegate) as? ContainerNavigationController
        )
        let coord = try XCTUnwrap(
            vc.coordinator as? GiniBankNetworkingScreenApiCoordinator
        )
        let service = try XCTUnwrap(
            (
                (coord.documentService as? GiniCaptureSDK.DocumentService)?
                    .captureNetworkService as? DefaultCaptureNetworkService
            )?.documentService
        )

        /// test

        // check default api domain
        XCTAssertEqual(service.apiDomain.domainString, "pay-api.gini.net")

        // check for correct token
        let logInExpectation = self.expectation(description: "login")
        var receivedTokenOptional: Token?
        service.sessionManager.logIn { result in
            switch result {
                case .success(let token):
                receivedTokenOptional = token
                logInExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failure: \(error.localizedDescription)")
            }
        }
        wait(for: [logInExpectation], timeout: 1)

        let receivedToken = try XCTUnwrap(receivedTokenOptional)
        XCTAssertEqual(receivedToken, testToken)

        // check for delegates/configs
        XCTAssertNotNil(coord.resultsDelegate as? MockCaptureResultsDelegate)
        XCTAssertEqual(coord.giniBankConfiguration, cfg)
        XCTAssertNotNil(coord.trackingDelegate as? MockTrackingDelegate)
        XCTAssertEqual(coord.documentService.metadata?.headers[Document.Metadata.headerKeyPrefix + Document.Metadata.branchIdHeaderKey], "branch")
    }
}
