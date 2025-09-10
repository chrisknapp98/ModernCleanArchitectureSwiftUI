import Foundation
import HTTPClient
import MoviesDomain

public final class SearchMoviesGateway: MovieSearchUseCase {
    private let client: DataFetching
    private let decoder = JSONDecoder()
    private let dateDormatter = DateFormatter()

    public init(client: DataFetching) {
        self.client = client
        dateDormatter.dateFormat = "YYYY-MM-DD"
        decoder.userInfo[.dateFormatter] = dateDormatter
    }

    public func search(query: String, page: Int) async throws -> PageResult<Movie> {
        let url = URL(string: "https://api.themoviedb.org/3/search/movie")!
        let parameters: [String: String] = [
            "query": query,
            "page": "\(page)",
            "api_key": "YOUR_API_KEY" // Replace with your actual API key
        ]
        
        let request = URLRequest(url: url, parameters: parameters)
        
        let response: SearchMoviesResponse = try await client.fetch(request, decoder: decoder)
        
        return PageResult(items: response.results, totalPages: response.totalPages)
    }
}
