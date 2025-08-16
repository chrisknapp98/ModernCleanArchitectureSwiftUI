import XCTest
@testable import Task_15
@testable import HTTPClient
@testable import MoviesDomain

final class SearchMoviesGatewayTests: XCTestCase {
    
    private var dataFetchingMock: DataFetchingMock!

    override func setUp() {
        super.setUp()
        dataFetchingMock = DataFetchingMock()
    }
    
    override func tearDown() {
        dataFetchingMock = nil
        super.tearDown()
    }
    
    private var sut: Task_15.SearchMoviesGateway {
        SearchMoviesGateway(client: dataFetchingMock)
    }
    
    func test_givenValidData_whenFetchingMovies_thenReturnsData() async throws {
        // given
        let movieName = "Test Movie"
        let movie = mockMovie(title: movieName)
        let page = mockPageResult(results: [movie], totalPages: 1, totalResults: 1)

        let encoder = makeMoviesEncoder()
        let jsonData = try encoder.encode(page)
        dataFetchingMock.data = jsonData

        let sut = sut

        // when
        let result = try await sut.search(query: "", page: 1)

        // then
        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results.first?.title, movieName)
        XCTAssertEqual(dataFetchingMock.callCount, 1)
    }
    
    func test_givenAnyError_whenFetchingMovies_thenRethrowsError() async throws {
        // given
        let thrownError = ErrorMock.mockError
        dataFetchingMock.error = thrownError

        let sut = sut

        // when
        do {
            _ = try await sut.search(query: "", page: 1)
            XCTFail("Expected to throw an error, but did not.")
        } catch let error as ErrorMock {
            // then
            switch error {
            case .mockError:
                XCTAssertTrue(true)
                XCTAssertEqual(dataFetchingMock.callCount, 1)
            default:
                XCTFail("Expected NetworkError.cancelled, but got \(error).")
            }
        } catch {
            XCTFail("Expected OfflineError, but got \(error).")
        }
    }

}
                              
class DataFetchingMock: DataFetching {
    var callCount = 0
    var data: Data?
    var error: Error?
    
    func fetch(resource: Resource) async throws -> Data {
        callCount += 1
        if let error {
            throw error
        }
        guard let data else {
            throw ErrorMock.notDefined
        }
        return data
    }
}

enum ErrorMock: Error {
    case notDefined
    case mockError
}

func mockResource(
    path: String = "/posts",
    method: HTTPMethod = .GET,
    query: [String: String] = [:]
) -> Resource {
    Resource(
        path: path,
        method: method,
        query: query
    )
}

func mockPageResult<T: Codable>(
    page: Int = 1,
    results: [T] = [T](),
    totalPages: Int = 1,
    totalResults: Int = 0
) -> PageResult<T> {
    PageResult(
        page: page,
        results: results,
        totalPages: totalPages,
        totalResults: totalResults
    )
}

func mockMovie(
    adult: Bool = false,
    backdropPath: String? = "/mockBackdrop.jpg",
    id: MovieID = MovieID(rawValue: 1),
    overview: String = "This is a mock movie for testing purposes.",
    popularity: Double = 10.0,
    posterPath: String? = "/mockPoster.jpg",
    releaseDate: Date? = Date(),
    title: String = "Mock Movie",
    video: Bool = false,
    voteAverage: Double = 8.5,
    voteCount: Int = 100
) -> Movie {
    Movie(
        adult: adult,
        backdropPath: backdropPath,
        id: id,
        overview: overview,
        popularity: popularity,
        posterPath: posterPath,
        releaseDate: releaseDate,
        title: title,
        video: video,
        voteAverage: voteAverage,
        voteCount: voteCount
    )
}

private func makeMoviesEncoder() -> JSONEncoder {
    let df = DateFormatter()
    df.calendar = Calendar(identifier: .gregorian)
    df.locale = Locale(identifier: "en_US_POSIX")
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "yyyy-MM-dd"

    let enc = JSONEncoder()
    enc.keyEncodingStrategy = .convertToSnakeCase
    enc.userInfo[.dateFormatter] = df
    enc.dateEncodingStrategy = .formatted(df)
    return enc
}
