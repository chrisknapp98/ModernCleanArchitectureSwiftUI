import XCTest
import Dependencies
@testable import Task_7
@testable import UI

@MainActor
class MovieDetailViewModelTests: XCTestCase {
    
    private var movieMock: Movie!
    private var errorToastCoordinator: ErrorToastCoordinatorMock!
    private var movieWatchlistUseCaseMock: MovieWatchlistUseCaseMock!

    private var sut: MovieDetailViewModel {
        withDependencies {
            $0.errorToastCoordinator = errorToastCoordinator
            $0.movieWatchlistUseCase = movieWatchlistUseCaseMock
        } operation: {
            return MovieDetailViewModel(
                movie: movieMock,
                coordinator: MoviesCoordinatorMock()
            )
        }
    }
    
    override func setUp() {
        super.setUp()
        movieMock = mockMovie()
        errorToastCoordinator = ErrorToastCoordinatorMock()
        movieWatchlistUseCaseMock = MovieWatchlistUseCaseMock()
    }
    
    override func tearDown() {
        movieMock = nil
        errorToastCoordinator = nil
        movieWatchlistUseCaseMock = nil
        super.tearDown()
    }
    
    func test_givenMovieNotOnWatchlist_whenAddToWatchlist_thenMovieOnWatchlist() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieWatchlistUseCaseMock.containsResult = false
        let sut = sut
        
        // when
        sut.addToWatchlist()
        
        // then
        XCTAssertTrue(sut.props.isInWatchlist)
        XCTAssertEqual(movieWatchlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieWatchlistUseCaseMock.addCallCount, 1)
        XCTAssertEqual(movieWatchlistUseCaseMock.removeCallCount, 0)
    }
    
    func test_givenMovieOnWatchlist_whenAddToWatchlist_thenMovieNotOnWatchlist() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieWatchlistUseCaseMock.containsResult = true
        let sut = sut
        
        // when
        sut.addToWatchlist()
        
        // then
        XCTAssertFalse(sut.props.isInWatchlist)
        XCTAssertEqual(movieWatchlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieWatchlistUseCaseMock.addCallCount, 0)
        XCTAssertEqual(movieWatchlistUseCaseMock.removeCallCount, 1)
    }
    
    func test_givenMovieNotOnWatchlist_whenAddToWatchlist_thenError() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieWatchlistUseCaseMock.containsResult = false
        movieWatchlistUseCaseMock.addError = ErrorMock.mockError
        let sut = sut
        
        // when
        sut.addToWatchlist()
        
        // then
        XCTAssertFalse(sut.props.isInWatchlist)
        XCTAssertEqual(movieWatchlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieWatchlistUseCaseMock.addCallCount, 1)
        XCTAssertEqual(movieWatchlistUseCaseMock.removeCallCount, 0)
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
    }
    
    func test_givenMovieOnWatchlist_whenAddToWatchlist_thenError() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieWatchlistUseCaseMock.containsResult = true
        movieWatchlistUseCaseMock.removeError = ErrorMock.mockError
        let sut = sut
        
        // when
        sut.addToWatchlist()
        
        // then
        XCTAssertFalse(sut.props.isInWatchlist)
        XCTAssertEqual(movieWatchlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieWatchlistUseCaseMock.addCallCount, 0)
        XCTAssertEqual(movieWatchlistUseCaseMock.removeCallCount, 1)
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

class MovieWatchlistUseCaseMock: MovieWatchlistUseCase {
    // Call counters
    var containsCallCount = 0
    var addCallCount = 0
    var removeCallCount = 0
    var getWatchlistCallCount = 0
    var addError: Error?
    var removeError: Error?
    
    // Inputs captured
    var lastAddedMovie: Movie?
    var lastRemovedMovie: Movie?
    
    // Configurable return values
    var containsResult = false
    var watchlistAfterAdding: MovieWatchlist?
    var watchlistAfterRemoving: MovieWatchlist?
    var currentWatchlist: MovieWatchlist?
    
    func contains(movie: Movie) -> Bool {
        containsCallCount += 1
        return containsResult
    }
    
    func add(movie: Movie) throws -> MovieWatchlist {
        addCallCount += 1
        lastAddedMovie = movie
        if let addError {
            throw addError
        }
        return watchlistAfterAdding ?? MovieWatchlist(movies: [])
    }
    
    func remove(movie: Movie) throws -> MovieWatchlist {
        removeCallCount += 1
        lastRemovedMovie = movie
        if let removeError {
            throw removeError
        }
        return watchlistAfterRemoving ?? MovieWatchlist(movies: [])
    }
    
    func getWatchlist() throws -> MovieWatchlist {
        getWatchlistCallCount += 1
        return currentWatchlist ?? MovieWatchlist(movies: [])
    }
}

enum ErrorMock: Error {
    case notDefined
    case mockError
}
