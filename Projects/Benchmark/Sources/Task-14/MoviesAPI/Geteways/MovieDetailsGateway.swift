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
        let resource = Resource(path: "/movie/\(movieID.rawValue)", method: .get, query: ["append_to_response": "keywords"])
        let data = try await client.fetch(resource: resource)
        return try decoder.decode(MovieDetail.self, from: data)

    }
}
