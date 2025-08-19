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
        let url = "https://api.themoviedb.org/3/search/movie"
        var components = URLComponents(string: url)!
        components.queryItems = [URLQueryItem(name: "query", value: query), URLQueryItem(name: "page", value: String(page))]
        let data = try await client.fetch(resource: Resource(url: components.url!))
        let result = try decoder.decode(PageResult<Movie>.self, from: data)
        return result
    }
}
