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
        let resource = Resource(path: "/movie\(movieID.value)/credits")
        let data = try await client.fetch(resource: resource)
        let movieCast = try decoder.decode(MovieCast.self, from: data)
        return movieCast
    }
}
