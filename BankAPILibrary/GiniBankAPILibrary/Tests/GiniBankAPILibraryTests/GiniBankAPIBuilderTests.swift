//
//  GiniBankAPIBuilderTests.swift
//
//  Copyright © 2025 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("GiniBankAPI.Builder Custom Network Provider Tests")
struct GiniBankAPIBuilderTests {
    
    @Test("Builder injects custom HTTP client when provider is set")
    func builderWithCustomNetworkProvider() async {
        // Given: A mock HTTP client and network provider
        let mockClient = MockHTTPClient()
        let mockProvider = MockNetworkProvider(httpClient: mockClient)
        
        // When: Building GiniBankAPI with custom network provider
        let giniBankAPI = GiniBankAPI
            .Builder(client: Client(id: "test-client-id",
                                    secret: "test-secret",
                                    domain: "test-domain"))
            .setCustomNetworkProvider(mockProvider)
            .build()
        
        // Then: Verify the custom HTTP client is injected by making a request
        let documentService = giniBankAPI.documentService()
        
        await withCheckedContinuation { continuation in
            documentService.createDocument(fileName: "test.jpg",
                                           docType: nil,
                                           type: .partial(Data()),
                                           metadata: nil) { _ in
                continuation.resume()
            }
        }
        
        // Verify the mock client methods were called (proving injection worked)
        #expect(mockClient.uploadRequestCalled || mockClient.dataRequestCalled,
                "Custom HTTP client should be used for requests")
    }
    
    @Test("Builder creates GiniBankAPI without custom provider")
    func builderWithoutCustomNetworkProvider() {
        // Given: No custom network provider
        let giniBankAPI = GiniBankAPI
            .Builder(client: Client(id: "test-client-id",
                                    secret: "test-secret",
                                    domain: "test-domain"))
            .build()
        
        // Then: GiniBankAPI should build successfully with default networking
        let documentService = giniBankAPI.documentService()
        #expect(documentService != nil,
                "Document service should be created with default networking")
    }
    
    @Test("Builder handles nil custom provider explicitly")
    func builderWithNilCustomNetworkProvider() {
        // Given: Explicitly set to nil
        let giniBankAPI = GiniBankAPI
            .Builder(client: Client(id: "test-client-id",
                                    secret: "test-secret",
                                    domain: "test-domain"))
            .setCustomNetworkProvider(nil)
            .build()
        
        // Then: Should use default networking
        let documentService = giniBankAPI.documentService()
        #expect(documentService != nil,
                "Document service should be created with default networking")
    }
}

// MARK: - Mock Network Provider

private final class MockNetworkProvider: GiniNetworkProvider {
    private let client: GiniHTTPClient
    
    init(httpClient: GiniHTTPClient) {
        self.client = httpClient
    }
    
    func httpClient() -> GiniHTTPClient {
        return client
    }
}
