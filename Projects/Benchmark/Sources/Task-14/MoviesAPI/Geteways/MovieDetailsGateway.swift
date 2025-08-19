import Foundation
import HTTPClient
import MoviesDomain

public final class MovieDetailsGateway: MovieDetailUseCaseProtocol {
    private let client: DataFetching
    private let decoder = JSONDecoder()
    private let dateDormatter = DateFormatter()

    public init(client: DataFetching) {
        self.client = client
        dateDormatter.dateFormat = "YYYY-MM-DD"
        decoder.dateDecodingStrategy = .formatted(dateDormatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func fetchDetail(for movieID: MovieID) async throws -> MovieDetail {
        let resource = Resource(path: "/movie/\(movieID)")
        do {
            let data = try await client.fetch(resource: resource)
            let movieDetail = try decoder.decode(MovieDetail.self, from: data)
            return movieDetail
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
