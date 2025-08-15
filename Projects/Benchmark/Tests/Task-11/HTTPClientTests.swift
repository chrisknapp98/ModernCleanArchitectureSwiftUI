import XCTest
@testable import Task_11

final class HTTPClientTests: XCTestCase {
    
    private var sessionMock: URLSessionMock!
    private var urlComponentsInterceptorMock: URLComponentsInterceptorMock!
    
    private var sut: HTTPClient {
        HTTPClient(
            session: sessionMock,
            environment: mockEnvironment(),
            urlComponentsInterceptor: urlComponentsInterceptorMock
        )
    }
    
    override func setUp() {
        super.setUp()
        sessionMock = URLSessionMock()
        urlComponentsInterceptorMock = URLComponentsInterceptorMock()
    }
    
    override func tearDown() {
        sessionMock = nil
        urlComponentsInterceptorMock = nil
        super.tearDown()
    }
    
    func test_givenValidURL_whenFetchingData_thenReturnsData() async throws {
        // given
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        let resource = mockResource()
        sessionMock.data = Data("{\"id\": 1, \"title\": \"Test Post\"}".utf8)
        sessionMock.response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        let sut = sut
        
        // when
        let data = try await sut.fetch(resource: resource)
        
        // then
        XCTAssertNotNil(data)
        XCTAssertEqual(sessionMock.callCount, 1)
    }
    
    func test_givenBadStatusCode_whenFetchingData_thenThrowsExpectedError() async throws {
        // given
        let url = URL(string: "example.com")!
        let resource = mockResource()
        sessionMock.data = Data("{\"id\": 1, \"title\": \"Test Post\"}".utf8)
        sessionMock.response = HTTPURLResponse(
            url: url,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        let sut = sut
        
        // when
        do {
            _ = try await sut.fetch(resource: resource)
            
            // then
            XCTFail("Expected to throw error for invalid URL")
        } catch let error as NetworkError {
            switch error {
            case .invalidResponse:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalid response error, but got \(error)")
            }
        }
    }
    
    func test_givenNotConnectedToInternet_whenFetchingData_thenThrowsExpectedError() async throws {
        // given
        let resource = mockResource()
        sessionMock.error = URLError(.notConnectedToInternet)
        let sut = sut
        
        // when
        do {
            _ = try await sut.fetch(resource: resource)
            
            // then
            XCTFail("Expected to throw error for invalid URL")
        } catch let error as NetworkError {
            switch error {
            case .notConnectedToInternet:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalid response error, but got \(error)")
            }
        }
    }
    
    func test_givenCancelled_whenFetchingData_thenThrowsExpectedError() async throws {
        // given
        let resource = mockResource()
        sessionMock.error = URLError(.cancelled)
        let sut = sut
        
        // when
        do {
            _ = try await sut.fetch(resource: resource)
            
            // then
            XCTFail("Expected to throw error for invalid URL")
        } catch let error as NetworkError {
            switch error {
            case .cancelled:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalid response error, but got \(error)")
            }
        }
    }
    
    func test_givenAnyURLError_whenFetchingData_thenThrowsExpectedError() async throws {
        // given
        let resource = mockResource()
        sessionMock.error = URLError(.unknown)
        let sut = sut
        
        // when
        do {
            _ = try await sut.fetch(resource: resource)
            
            // then
            XCTFail("Expected to throw error for invalid URL")
        } catch let error as NetworkError {
            switch error {
            case .networkError(_):
                XCTAssertTrue(true)
            default:
                XCTFail("Expected invalid response error, but got \(error)")
            }
        }
    }
}

class URLSessionMock: URLSessionProtocol {
    var callCount = 0
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        callCount += 1
        if let error = error {
            throw error
        }
        guard let data, let response else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }
}

func mockEnvironment(
    schema: String = "https",
    host: String = "jsonplaceholder.typicode.com",
    version: String = "v1"
) -> HTTPClient.Environment {
    return HTTPClient.Environment(
        schema: schema,
        host: host,
        version: version
    )
}

class URLComponentsInterceptorMock: URLComponentsInterceptor {
    var callCount = 0
    
    func modify(components: inout URLComponents) {
        callCount += 1
    }
}

func mockResource(
    path: String = "/posts",
    method: HTTPMethod = .GET,
    query: [String: String] = [:]
) -> Resource {
    Resource(
        path: path,
        method: method,
        query: query
    )
}
