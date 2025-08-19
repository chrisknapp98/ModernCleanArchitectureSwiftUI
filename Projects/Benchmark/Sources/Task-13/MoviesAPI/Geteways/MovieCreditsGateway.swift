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
        do {
            let data = try await client.fetch(resource: Resource(path: "/movie/\(movieID)/credits"))
            let cast = try decoder.decode(MovieCast.self, from: data)
            return cast
        } catch let error as NetworkError {
            if case .notConnectedToInternet = error {
                throw OfflineError()
            }
            throw error
        } catch {
            throw error
        }
    }
}
