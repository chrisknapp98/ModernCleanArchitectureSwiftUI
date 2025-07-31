import XCTest
import Dependencies
@testable import Task_2

final class DiscoverMoviesUseCaseTests: XCTestCase {
    
    private var gatewayMock: DiscoverMoviesGatewayMock!
    private var repositoryMock: DiscoverMoviesRepositoryMock!
    
    @MainActor
    private var sut: DiscoverMoviesUseCaseProtocol {
        DiscoverMoviesUseCase(
            gateway: gatewayMock,
            repository: repositoryMock
        )
    }
    
    override func setUp() {
        super.setUp()
        gatewayMock = DiscoverMoviesGatewayMock()
        repositoryMock = DiscoverMoviesRepositoryMock()
    }
    
    override func tearDown() {
        gatewayMock = nil
        repositoryMock = nil
        super.tearDown()
    }
    
    @MainActor
    func test_givenMoviesForPageOne_whenFetching_thenReturnPageResultAndSave() async throws {
        // given
        let expectedMovies = [
            mockMovie(title: "Test Movie 1"),
            mockMovie(title: "Test Movie 2")
        ]
        let expectedPageResult = mockPageResult(results: expectedMovies)
        gatewayMock.results = expectedPageResult
        let sut = sut
        
        // when
        let result = try await sut.fetch(request: .popular, page: 1)
        
        // then
        XCTAssertEqual(result.results.count, 2)
        XCTAssertEqual(result.results.map(\.title), ["Test Movie 1", "Test Movie 2"])
        XCTAssertEqual(gatewayMock.callCount, 1)
        XCTAssertEqual(repositoryMock.saveCallCount, 1)
    }
    
    @MainActor
    func test_givenMoviesForAnyPageNotOne_whenFetching_thenReturnPageResultWithoutSaving() async throws {
        // given
        let expectedMovies = [
            mockMovie(title: "Test Movie 1"),
            mockMovie(title: "Test Movie 2")
        ]
        let expectedPageResult = mockPageResult(results: expectedMovies)
        gatewayMock.results = expectedPageResult
        let sut = sut
        
        // when
        let result = try await sut.fetch(request: .popular, page: 2)
        
        // then
        XCTAssertEqual(result.results.count, 2)
        XCTAssertEqual(result.results.map(\.title), ["Test Movie 1", "Test Movie 2"])
        XCTAssertEqual(gatewayMock.callCount, 1)
        XCTAssertEqual(repositoryMock.saveCallCount, 0)
    }
    
    @MainActor
    func test_givenError_whenFetching_thenThrowError() async throws {
        // given
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        gatewayMock.error = expectedError
        let sut = sut
        
        // when & then
        do {
            _ = try await sut.fetch(request: .popular, page: 1)
            XCTFail("Expected error to be thrown, but succeeded")
        } catch {
            XCTAssertEqual(error as NSError, expectedError)
        }

        XCTAssertEqual(gatewayMock.callCount, 1)
    }
    
    @MainActor
    func test_givenOfflineError_whenFetching_thenReturnCachedMovies() async throws {
        // given
        let expectedMovies = [
            mockMovie(title: "Cached Movie 1"),
            mockMovie(title: "Cached Movie 2")
        ]
        repositoryMock.movies = expectedMovies
        gatewayMock.error = OfflineError()
        
        let sut = sut
        
        // when
        let result = try await sut.fetch(request: .popular, page: 1)
        
        // then
        XCTAssertEqual(result.results.count, 2)
        XCTAssertEqual(result.results.map(\.title), ["Cached Movie 1", "Cached Movie 2"])
        XCTAssertEqual(repositoryMock.moviesCallCount, 1)
    }
    
}

class DiscoverMoviesGatewayMock: DiscoverMoviesGateway {
    var results: PageResult<Movie> = mockPageResult()
    var error: Error?
    var callCount = 0
    
    func fetch(request: DiscoverMoviesRequest) async throws -> PageResult<Movie> {
        callCount += 1
        if let error = error {
            throw error
        }
        return results
    }
}

class DiscoverMoviesRepositoryMock: DicoverMoviesRepository {
    var movies: [Movie] = []
    var moviesError: Error?
    var saveError: Error?
    var moviesCallCount = 0
    var saveCallCount = 0

    func movies(for reuqest: DiscoverMoviesRequest) throws -> [Movie] {
        moviesCallCount += 1
        if let error = moviesError {
            throw error
        }
        return movies
    }
    
    func save(movies: [Movie], for request: DiscoverMoviesRequest) throws {
        saveCallCount += 1
        if let error = saveError {
            throw error
        }
    }
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

func mockPageResult<Item: Codable>(
    page: Int = 1,
    results: [Item] = [],
    totalPages: Int = 1,
    totalResults: Int = 1
) -> PageResult<Item> {
    PageResult(
        page: page,
        results: results,
        totalPages: totalPages,
        totalResults: totalResults
    )
}
