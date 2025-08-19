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
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/credits"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await client.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(MovieCast.self, from: data)
    }
}
