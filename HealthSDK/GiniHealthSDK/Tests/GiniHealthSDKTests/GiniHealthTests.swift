import XCTest
@testable import GiniHealthSDK
@testable import GiniHealthAPILibrary

final class GiniHealthTests: XCTestCase {
    
    var giniHealthAPI: HealthAPI!
    var giniHealth: GiniHealth!
    
    override func setUp() {
        let sessionManagerMock = SessionManagerMock()
        let documentService = DefaultDocumentService(sessionManager: sessionManagerMock)
        let paymentService = PaymentService(sessionManager: sessionManagerMock)
        giniHealthAPI = MockHealthAPI(docService: documentService, payService: paymentService)
        giniHealth = GiniHealth(with: giniHealthAPI)
    }

    override func tearDown() {
        giniHealth = nil
        super.tearDown()
    }
    
    func testSetConfiguration() throws {
        // Given
        let configuration = GiniHealthConfiguration()
        
        // When
        giniHealth.setConfiguration(configuration)
        
        // Then
        XCTAssertEqual(GiniHealthConfiguration.shared, configuration)
    }
}

class MockHealthAPI: HealthAPI {
    func documentService<T>() -> T where T : GiniHealthAPILibrary.DocumentService {
        return docService as! T
    }
    
    func paymentService() -> GiniHealthAPILibrary.PaymentService {
        payService!
    }
    
    public var docService: DocumentService!
    public var payService: PaymentService?
    
    init(docService: DocumentService!, payService: PaymentService? = nil) {
        self.docService = docService
        self.payService = payService
    }
}

final class SessionManagerMock: SessionManagerProtocol {
    func upload<T>(resource: T, data: Data, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        //
    }
    
    func download<T>(resource: T, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        //
    }
    
    func logIn(completion: @escaping (Result<GiniHealthAPILibrary.Token, GiniHealthAPILibrary.GiniError>) -> Void) {
        //
    }
    
    func logOut() {
        //
    }
    
    func data<T>(resource: T, cancellationToken: GiniHealthAPILibrary.CancellationToken?, completion: @escaping GiniHealthAPILibrary.CompletionResult<T.ResponseType>) where T : GiniHealthAPILibrary.Resource {
        //
    }
    
}
