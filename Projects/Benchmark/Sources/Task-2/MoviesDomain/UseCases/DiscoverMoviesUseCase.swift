import Foundation
import Dependencies
import XCTestDynamicOverlay

public protocol DiscoverMoviesUseCaseProtocol {
    func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie>
}

public final class DiscoverMoviesUseCase: DiscoverMoviesUseCaseProtocol {
    private let gateway: DiscoverMoviesGateway
    private let repository: DicoverMoviesRepository
    
    public init(gateway: DiscoverMoviesGateway, repository: DicoverMoviesRepository) {
        self.gateway = gateway
        self.repository = repository
    }
    
    public func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie> {
        let cachedResult = try await repository.fetch(request: request, page: page)
        
        if cachedResult.isEmpty {
            let result = try await gateway.fetch(request: request, page: page)
            try await repository.save(request: request, page: page, result: result)
            return result
        } else {
            return cachedResult
        }
    }
}

public enum DiscoverMoviesUseCaseDependencyKey: TestDependencyKey {
    struct Unimplemented: DiscoverMoviesUseCaseProtocol {
        func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie> {
            unimplemented(#function, placeholder: .init(page: 0, results: [], totalPages: 0, totalResults: 0))
        }
    }
    
    public static var testValue: DiscoverMoviesUseCaseProtocol {
        Unimplemented()
    }
}

extension DependencyValues {
    public var discoverMoviesUseCase: DiscoverMoviesUseCaseProtocol {
        get {
            self[DiscoverMoviesUseCaseDependencyKey.self]
        }
        set {
            self[DiscoverMoviesUseCaseDependencyKey.self] = newValue
        }
    }
}
