import XCTest
import Dependencies
@testable import Task_8
@testable import MoviesDomain
@testable import UI

@MainActor
class MovieDetailViewModelTests: XCTestCase {
    
    private var movieMock: Movie!
    private var errorToastCoordinator: ErrorToastCoordinatorMock!
    private var movieSeenlistUseCaseMock: MovieSeenlistUseCaseMock!

    private var sut: MovieDetailViewModel {
        withDependencies {
            $0.errorToastCoordinator = errorToastCoordinator
            $0.movieSeenlistUseCase = movieSeenlistUseCaseMock
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
        movieSeenlistUseCaseMock = MovieSeenlistUseCaseMock()
    }
    
    override func tearDown() {
        movieMock = nil
        errorToastCoordinator = nil
        movieSeenlistUseCaseMock = nil
        super.tearDown()
    }
    
    func test_givenMovieNotOnSeenList_whenAddToSeenList_thenMovieOnSeenList() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieSeenlistUseCaseMock.containsResult = false
        let sut = sut
        
        // when
        sut.addToSeenList()
        
        // then
        XCTAssertTrue(sut.props.isInSeenlist)
        XCTAssertEqual(movieSeenlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieSeenlistUseCaseMock.addCallCount, 1)
        XCTAssertEqual(movieSeenlistUseCaseMock.removeCallCount, 0)
    }
    
    func test_givenMovieOnSeenList_whenAddToSeenList_thenMovieNotOnSeenList() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieSeenlistUseCaseMock.containsResult = true
        let sut = sut
        
        // when
        sut.addToSeenList()
        
        // then
        XCTAssertFalse(sut.props.isInSeenlist)
        XCTAssertEqual(movieSeenlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieSeenlistUseCaseMock.addCallCount, 0)
        XCTAssertEqual(movieSeenlistUseCaseMock.removeCallCount, 1)
    }
    
    func test_givenMovieNotOnSeenList_whenAddToSeenList_thenError() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieSeenlistUseCaseMock.containsResult = false
        movieSeenlistUseCaseMock.addError = ErrorMock.mockError
        let sut = sut
        let previousInSeenListValue = sut.props.isInSeenlist
        
        // when
        sut.addToSeenList()
        
        // then
        XCTAssertEqual(sut.props.isInSeenlist, previousInSeenListValue)
        XCTAssertEqual(movieSeenlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieSeenlistUseCaseMock.addCallCount, 1)
        XCTAssertEqual(movieSeenlistUseCaseMock.removeCallCount, 0)
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
    }
    
    func test_givenMovieOnSeenList_whenAddToSeenList_thenError() async {
        // given
        movieMock = mockMovie(title: "Movie To Add")
        movieSeenlistUseCaseMock.containsResult = true
        movieSeenlistUseCaseMock.removeError = ErrorMock.mockError
        let sut = sut
        let previousInSeenListValue = sut.props.isInSeenlist
        
        // when
        sut.addToSeenList()
        
        // then
        XCTAssertEqual(sut.props.isInSeenlist, previousInSeenListValue)
        XCTAssertEqual(movieSeenlistUseCaseMock.containsCallCount, 1)
        XCTAssertEqual(movieSeenlistUseCaseMock.addCallCount, 0)
        XCTAssertEqual(movieSeenlistUseCaseMock.removeCallCount, 1)
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

class MovieSeenlistUseCaseMock: MovieSeenlistUseCase {
    // Call counters
    var containsCallCount = 0
    var addCallCount = 0
    var removeCallCount = 0
    var getSeenListCallCount = 0
    var addError: Error?
    var removeError: Error?
    
    // Inputs captured
    var lastAddedMovie: Movie?
    var lastRemovedMovie: Movie?
    
    // Configurable return values
    var containsResult = false
    var seenListAfterAdding: MovieSeenList?
    var seenListAfterRemoving: MovieSeenList?
    var currentSeenList: MovieSeenList?
    
    func contains(movie: Movie) -> Bool {
        containsCallCount += 1
        return containsResult
    }
    
    func add(movie: Movie) throws -> MovieSeenList {
        addCallCount += 1
        lastAddedMovie = movie
        if let addError {
            throw addError
        }
        return seenListAfterAdding ?? MovieSeenList(movies: [])
    }
    
    func remove(movie: Movie) throws -> MovieSeenList {
        removeCallCount += 1
        lastRemovedMovie = movie
        if let removeError {
            throw removeError
        }
        return seenListAfterRemoving ?? MovieSeenList(movies: [])
    }
    
    func getSeenList() throws -> MovieSeenList {
        getSeenListCallCount += 1
        return currentSeenList ?? MovieSeenList(movies: [])
    }
}

enum ErrorMock: Error {
    case notDefined
    case mockError
}
