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
    var token: Token?
    init(token: Token? = nil) {
        self.token = token
    }
    func fetchToken(completion: @escaping (Result<Token, GiniError>) -> Void) {
        if let token {
            completion(.success(token))
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
    private var tokenSource: MockTokenSource!
    private var resultsDelegate: MockCaptureResultsDelegate!
    private var configuration: GiniBankConfiguration!
    private var metadata: Document.Metadata!
    private var trackingDelegate: MockTrackingDelegate!

    override func setUp() {
        tokenSource = makeTokenSource()
        resultsDelegate = MockCaptureResultsDelegate()
        configuration = GiniBankConfiguration()
        metadata = Document.Metadata(branchId: "branch")
        trackingDelegate = MockTrackingDelegate()
    }

    func testInitWithAlternativeTokenSource() throws {
//        let (coordinator, service) = try makeCoordinatorAndService()
//
//        // check domain
//        XCTAssertEqual(service.apiDomain.domainString, "pay-api.gini.net", "Service api domain should match our default")
//
//        // check token
//        let receivedToken = try XCTUnwrap(
//            login(service: service),
//            "Should log in successfully"
//        )
//        XCTAssertEqual(receivedToken, tokenSource.token, "Received token should match the expected token")
//
//        // check for delegates/configs
//        XCTAssertNotNil(
//            coordinator.resultsDelegate as? MockCaptureResultsDelegate,
//            "Coordinator should have correct results delegate instance"
//        )
//        XCTAssertEqual(coordinator.giniBankConfiguration, configuration, "Coordinator should have correct configuration instance")
//        XCTAssertNotNil(
//            coordinator.trackingDelegate as? MockTrackingDelegate,
//            "Coordinator should have correct tracking delegate instance"
//        )
//        XCTAssertEqual(coordinator.documentService.metadata?.headers, metadata.headers, "Metadata headers should match")
    }

    func testViewControllerWithAlternativeTokenSource() throws {
//        let (coordinator, service) = try makeCoordinatorAndService(fromViewController: true)
//
//        // check domain
//        XCTAssertEqual(service.apiDomain.domainString, "pay-api.gini.net", "Service api domain should match our default")
//
//        // check token
//        let receivedToken = try XCTUnwrap(
//            login(service: service),
//            "Should log in successfully"
//        )
//        XCTAssertEqual(receivedToken, tokenSource.token, "Received token should match the expected token")
//
//        // check for delegates/configs
//        XCTAssertNotNil(
//            coordinator.resultsDelegate as? MockCaptureResultsDelegate,
//            "Coordinator should have correct results delegate instance"
//        )
//        XCTAssertEqual(coordinator.giniBankConfiguration, configuration, "Coordinator should have correct configuration instance")
//        XCTAssertNotNil(
//            coordinator.trackingDelegate as? MockTrackingDelegate,
//            "Coordinator should have correct tracking delegate instance"
//        )
//        XCTAssertEqual(coordinator.documentService.metadata?.headers, metadata.headers, "Metadata headers should match")
    }
}

private extension NetworkingScreenApiCoordinatorTests {
    func makeTokenSource() -> MockTokenSource {
        MockTokenSource(
            token:
                Token(
                    expiration: .init(),
                    scope: "the_scope",
                    type: "the_type",
                    accessToken: "some_totally_random_gibberish"
                )
        )
    }

    func makeCoordinatorAndService(fromViewController: Bool = false) throws -> (GiniBankNetworkingScreenApiCoordinator, DefaultDocumentService) {
        let coordinator: GiniBankNetworkingScreenApiCoordinator
        if fromViewController {
            let viewController = try XCTUnwrap(
                GiniBank.viewController(
                    withAlternativeTokenSource: tokenSource,
                    configuration: configuration,
                    resultsDelegate: resultsDelegate,
                    documentMetadata: metadata,
                    trackingDelegate: trackingDelegate
                ) as? ContainerNavigationController,
                "There should be an instance of `ContainerNavigationController`"
            )
            coordinator = try XCTUnwrap(
                viewController.coordinator as? GiniBankNetworkingScreenApiCoordinator,
                "The instance of `ContainerNavigationController` should have a coordinator of type `GiniBankNetworkingScreenApiCoordinator"
            )
        } else {
            coordinator = GiniBankNetworkingScreenApiCoordinator(
                alternativeTokenSource: tokenSource,
                resultsDelegate: resultsDelegate,
                configuration: configuration,
                documentMetadata: metadata,
                trackingDelegate: trackingDelegate
            )
        }
        let documentService = try XCTUnwrap(
            coordinator.documentService as? GiniCaptureSDK.DocumentService,
            "The coordinator should have a document service of type `GiniCaptureSDK.DocumentService"
        )
        let captureNetworkService = try XCTUnwrap(
            documentService.captureNetworkService as? DefaultCaptureNetworkService,
            "The document service should have a capture network service of type `DefaultCaptureNetworkService"
        )


        return (coordinator, captureNetworkService.documentService)
    }

    func login(service: DefaultDocumentService) throws -> Token? {
        let logInExpectation = self.expectation(description: "login")
        var receivedToken: Token?
        service.sessionManager.logIn { result in
            switch result {
                case .success(let token):
                receivedToken = token
                logInExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failure: \(error.localizedDescription)")
            }
        }
        wait(for: [logInExpectation], timeout: 1)
        return receivedToken
    }
}
