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
        let url = URL(string: "https://api.example.com/movies/")!.appendingPathComponent(movieID.id)
        let (data, _) = try await client.fetchData(from: url)
        let movieDetail = try decoder.decode(MovieDetail.self, from: data)
        return movieDetail
    }
}
