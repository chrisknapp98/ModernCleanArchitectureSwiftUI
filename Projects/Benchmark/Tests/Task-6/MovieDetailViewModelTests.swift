import XCTest
import Dependencies
@testable import Task_6
@testable import UI

@MainActor
class MovieDetailViewModelTests: XCTestCase {
    
    private var movieMock: Movie!
    private var moviesCoordinatorMock: MoviesCoordinatorMock!

    private var sut: MovieDetailViewModel {
        return MovieDetailViewModel(
            movie: movieMock,
            coordinator: moviesCoordinatorMock
        )
    }
    
    override func setUp() {
        super.setUp()
        movieMock = mockMovie()
        moviesCoordinatorMock = MoviesCoordinatorMock()
    }
    
    override func tearDown() {
        movieMock = nil
        moviesCoordinatorMock = nil
        super.tearDown()
    }
    
    func test_givenMovie_whenTapOnMovie_thenCallCoordinatorOnce() {
        // given
        let person = mockPerson(name: "New Person")
        let sut = sut
        
        // when
        sut.didTap(person: person)
        
        // then
        XCTAssertEqual(moviesCoordinatorMock.showMovieDetailCallCount, 0)
        XCTAssertEqual(moviesCoordinatorMock.showPersonDetailCallCount, 1)
        XCTAssertEqual(moviesCoordinatorMock.showAddMovieToCustomListCallCount, 0)
        XCTAssertEqual(moviesCoordinatorMock.lastPersonDetail?.name, person.name)
    }
}

class MoviesCoordinatorMock: MoviesCoordinator {
    var showMovieDetailCallCount = 0
    var showPersonDetailCallCount = 0
    var showAddMovieToCustomListCallCount = 0
    var lastMovieDetail: Movie?
    var lastPersonDetail: Person?
    
    func showDetail(for movie: Movie) {
        showMovieDetailCallCount += 1
        lastMovieDetail = movie
    }
    
    func showDetail(for person: Person) {
        showPersonDetailCallCount += 1
        lastPersonDetail = person
    }
    
    func showAddMovieToCustomList(for movie: Movie) {
        showAddMovieToCustomListCallCount += 1
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

func mockPerson(
    id: PersonID = 1,
    name: String = "Mock Person",
    knownForDepartment: String? = nil,
    originalName: String? = nil,
    popularity: Double? = nil,
    profilePath: String? = nil,
    castID: Int? = nil,
    character: String? = nil,
    creditID: String? = nil,
    department: String? = nil,
    job: String? = nil
) -> Person {
    Person(
        id: id,
        name: name,
        knownForDepartment: knownForDepartment,
        originalName: originalName,
        popularity: popularity,
        profilePath: profilePath,
        castID: castID,
        character: character,
        creditID: creditID,
        department: department,
        job: job
    )
}
