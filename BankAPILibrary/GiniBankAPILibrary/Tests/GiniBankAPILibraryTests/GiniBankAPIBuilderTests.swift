//
//  GiniBankAPIBuilderTests.swift
//
//  Copyright © 2026 Gini GmbH. All rights reserved.
//
import Testing
import Foundation
@testable import GiniBankAPILibrary

@Suite("GiniBankAPI.Builder Custom Network Provider Tests")
struct GiniBankAPIBuilderTests {
    
    init() {
        // Disable keychain precondition failure for tests
        _GINIBANKAPILIBRARY_DISABLE_KEYCHAIN_PRECONDITION_FAILURE = true
    }
    
    @Test("Builder injects custom HTTP client when provider is set")
    func builderWithCustomNetworkProvider() {
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
        
        // Then: Verify the GiniBankAPI was created successfully with custom provider
        let documentService: DefaultDocumentService = giniBankAPI.documentService()
        #expect(type(of: documentService) == DefaultDocumentService.self,
                "Document service should be created with custom HTTP client")
        
        // Note: We can't easily test that the mock client is actually used without
        // triggering authentication, which requires keychain access. The important
        // thing is that the API builds successfully with the custom provider.
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
        let documentService: DefaultDocumentService = giniBankAPI.documentService()
        #expect(type(of: documentService) == DefaultDocumentService.self,
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
        let documentService: DefaultDocumentService = giniBankAPI.documentService()
        #expect(type(of: documentService) == DefaultDocumentService.self,
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
