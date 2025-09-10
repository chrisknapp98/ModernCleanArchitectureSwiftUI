import Foundation

public protocol DataFetching {
    func fetch(resource: Resource) async throws -> Data
}

public final class HTTPClient: DataFetching {
    private let session: URLSessionProtocol
    private let environment: Environment
    private let urlComponentsInterceptor: URLComponentsInterceptor
    
    public init(
        session: URLSessionProtocol = URLSession.shared,
        environment: Environment,
        urlComponentsInterceptor: URLComponentsInterceptor
    ) {
        self.session = session
        self.environment = environment
        self.urlComponentsInterceptor = urlComponentsInterceptor
    }
    
    public func fetch(resource: Resource) async throws -> Data {
        let request = self.request(for: resource)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            if httpResponse.statusCode == 200 {
                return data
            } else if httpResponse.statusCode == 404 {
                throw NetworkError.notConnectedToInternet
            } else {
                throw NetworkError.invalidResponse
            }
        } catch let error as URLError where error.code == .cancelled {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    private func request(for resource: Resource) -> URLRequest {
        var components = URLComponents()
        
        components.scheme = environment.schema
        components.host = environment.host
        components.path = "/" + environment.version + resource.path
        components.queryItems = resource.query.map { key, value in URLQueryItem(name: key, value: value) }
        
        urlComponentsInterceptor.modify(components: &components)
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = resource.method.rawValue
        
        return request
    }
}

public enum NetworkError: Error {
    case networkError(Error)
    case invalidResponse
    case cancelled
    case notConnectedToInternet
}

public extension HTTPClient {
    struct Environment {
        let schema: String
        let host: String
        let version: String
        
        public init(schema: String, host: String, version: String) {
            self.schema = schema
            self.host = host
            self.version = version
        }
    }
}
