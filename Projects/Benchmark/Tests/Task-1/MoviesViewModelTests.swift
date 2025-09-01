import XCTest
import Dependencies
@testable import Task_1
@testable import MoviesDomain
@testable import UI

@MainActor
final class MoviesViewModelTests: XCTestCase {
    
    private var discoverMoviesUseCase: DiscoverMoviesUseCaseProtocolMock!
    private var errorToastCoordinator: ErrorToastCoordinatorMock!
    
    private var sut: MoviesViewModel {
        withDependencies {
            $0.discoverMoviesUseCase = discoverMoviesUseCase
            $0.errorToastCoordinator = errorToastCoordinator
        } operation: {
            return MoviesViewModel(coordinator: MoviesCoordinatorMock())
        }
    }
    
    override func setUp() {
        super.setUp()
        discoverMoviesUseCase = DiscoverMoviesUseCaseProtocolMock()
        errorToastCoordinator = ErrorToastCoordinatorMock()
    }
    
    override func tearDown() {
        discoverMoviesUseCase = nil
        errorToastCoordinator = nil
        super.tearDown()
    }
    
    func test_givenMovies_whenFetchingMoviesToDiscover_thenFindMovies() async {
        // given
        let expectedMovies = [
            mockMovie(title: "Test Movie 1"),
            mockMovie(title: "Test Movie 2")
        ]
        discoverMoviesUseCase.results = expectedMovies
        let sut = sut
    
        // when
        await sut.fetch()
        
        // then
        XCTAssertEqual(sut.movies.count, 2)
        XCTAssertEqual(sut.movies.map(\.title), ["Test Movie 1", "Test Movie 2"])
        XCTAssertEqual(discoverMoviesUseCase.callCount, 1)
        XCTAssertEqual(errorToastCoordinator.callCount, 0)
    }
    
    func test_givenError_whenFetchingMoviesToDiscover_thenShowErrorToast() async {
        // given
        let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil)
        discoverMoviesUseCase.error = expectedError
        let sut = sut
        
        // when
        await sut.fetch()
        
        // then
        XCTAssertEqual(sut.movies.count, 0)
        XCTAssertEqual(discoverMoviesUseCase.callCount, 1)
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
    }
    
}

class MoviesCoordinatorMock: MoviesCoordinator {
    func showDetail(for movie: Movie) {
        // Mock implementation
    }
    
    func showDetail(for person: Person) {
        // Mock implementation
    }
    
    func showAddMovieToCustomList(for movie: Movie) {
        // Mock implementation
    }
}

class DiscoverMoviesUseCaseProtocolMock: DiscoverMoviesUseCaseProtocol {
    var results: [Movie] = []
    var totalPages = 1
    var callCount = 0
    var totalResults = 0
    var error: Error? = nil

    func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie> {
        callCount += 1
        if let error = error {
            throw error
        }
        return PageResult(
            page: page,
            results: results,
            totalPages: totalPages,
            totalResults: totalResults
        )
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


class ErrorToastCoordinatorMock: ErrorToastCoordinator {
    var callCount = 0
    
    override func show() {
        callCount += 1
        super.show()
    }
}
