import Foundation
import HTTPClient
import MoviesDomain

public final class MovieCreditsGateway: MovieCreditsUseCase {
    private let client: DataFetching
    private let decoder = JSONDecoder()

    public init(client: DataFetching) {
        self.client = client
    }
    
    public func fetchCast(movieID: MovieID) async throws -> MovieCast {
    }
}
