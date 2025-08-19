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
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(MovieDetail.self, from: data)

    }
}
