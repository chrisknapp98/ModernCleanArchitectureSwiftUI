import XCTest
import Dependencies
@testable import Task_4
@testable import MoviesDomain
@testable import UI

@MainActor
class MovieDetailViewModelTests: XCTestCase {
    
    private var movieMock: Movie!
    private var discoverMoviesUseCase: DiscoverMoviesUseCaseProtocolMock!
    private var errorToastCoordinator: ErrorToastCoordinatorMock!
    private var movieWatchlistUseCaseMock: MovieWatchlistUseCaseMock!
    private var movieSeenlistUseCaseMock: MovieSeenlistUseCaseMock!
    private var movieDetailUseCaseMock: MovieDetailUseCaseMock!
    private var movieCreditsUseCaseMock: MovieCreditsUseCaseMock!
    private var movieRecomendationUseCaseMock: MovieRecomendationUseCaseMock!

    private var sut: MovieDetailViewModel {
        withDependencies {
            $0.discoverMoviesUseCase = discoverMoviesUseCase
            $0.errorToastCoordinator = errorToastCoordinator
            $0.movieWatchlistUseCase = movieWatchlistUseCaseMock
            $0.movieSeenlistUseCase = movieSeenlistUseCaseMock
            $0.movieDetailUseCase = movieDetailUseCaseMock
            $0.movieCreditsUseCase = movieCreditsUseCaseMock
            $0.movieRecomendationUseCase = movieRecomendationUseCaseMock
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
        discoverMoviesUseCase = DiscoverMoviesUseCaseProtocolMock()
        errorToastCoordinator = ErrorToastCoordinatorMock()
        movieWatchlistUseCaseMock = MovieWatchlistUseCaseMock()
        movieSeenlistUseCaseMock = MovieSeenlistUseCaseMock()
        movieDetailUseCaseMock = MovieDetailUseCaseMock()
        movieCreditsUseCaseMock = MovieCreditsUseCaseMock()
        movieRecomendationUseCaseMock = MovieRecomendationUseCaseMock()
    }
    
    override func tearDown() {
        movieMock = nil
        discoverMoviesUseCase = nil
        errorToastCoordinator = nil
        movieWatchlistUseCaseMock = nil
        movieSeenlistUseCaseMock = nil
        movieDetailUseCaseMock = nil
        movieCreditsUseCaseMock = nil
        movieRecomendationUseCaseMock = nil
        super.tearDown()
    }
    
    func test_givenFullData_whenFetchDetails_thenAllPropsSet() async {
        // given
        let movieDetails = mockMovieDetail()
        let movieCast = mockMovieCast()
        let recommendedMovies = [mockMovie(id: .init(rawValue: 2)), mockMovie(id: .init(rawValue: 3))]
        let similarMovies = [mockMovie(id: .init(rawValue: 4))]
        
        movieDetailUseCaseMock.movieDetail = movieDetails
        movieCreditsUseCaseMock.movieCast = movieCast
        movieRecomendationUseCaseMock.recommendedMovies = recommendedMovies
        movieRecomendationUseCaseMock.similarMovies = similarMovies
        movieWatchlistUseCaseMock.containsResult = true
        movieSeenlistUseCaseMock.containsResult = false

        let sut = sut
        
        // when
        await sut.fetchDetails()
        
        // then
        XCTAssertFalse(sut.props.isLoading)
        XCTAssertEqual(sut.props.details, movieDetails)
        XCTAssertEqual(sut.props.cast, movieCast)
        XCTAssertEqual(sut.props.recommended, recommendedMovies)
        XCTAssertEqual(sut.props.similar, similarMovies)
        XCTAssertTrue(sut.props.isInWatchlist)
        XCTAssertFalse(sut.props.isInSeenlist)
    }
    
    func test_givenMovieDetails_whenFetchDetails_thenMovieDetails() async {
        // given
        let movieDetails = mockMovieDetail()
        movieDetailUseCaseMock.movieDetail = movieDetails
        let sut = sut
        
        // when
        await sut.fetchDetails()
        
        // then
        XCTAssertFalse(sut.props.isLoading)
        XCTAssertEqual(sut.props.details, movieDetails)
    }
    
    func test_givenError_whenFetchDetails_thenShowError() async {
        // given
        let error = ErrorMock.mockError
        movieDetailUseCaseMock.error = error
        let sut = sut
        
        // when
        await sut.fetchDetails()
        
        // then
        XCTAssertFalse(sut.props.isLoading)
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
        XCTAssertNil(sut.props.details)
    }
    
    func test_givenErrorCast_whenFetchCast_thenShowError() async {
        // given
        let movieDetails = mockMovieDetail()
        movieDetailUseCaseMock.movieDetail = movieDetails
        movieCreditsUseCaseMock.error = ErrorMock.mockError
        
        let sut = sut
        
        // when
        await sut.fetchDetails()
        
        // then
        XCTAssertFalse(sut.props.isLoading)
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
        XCTAssertNil(sut.props.cast)
    }
    
    func test_givenErrorRecommendation_whenFetchRecommendation_thenShowError() async {
        // given
        let movieDetails = mockMovieDetail()
        movieDetailUseCaseMock.movieDetail = movieDetails
        movieRecomendationUseCaseMock.recommendedError = ErrorMock.mockError
        
        let sut = sut
        
        // when
        await sut.fetchDetails()
        
        // then
        XCTAssertFalse(sut.props.isLoading)
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
        XCTAssertEqual(sut.props.recommended.count, 0)
    }

    func test_givenErrorSimilar_whenFetchSimilar_thenShowError() async {
        // given
        let movieDetails = mockMovieDetail()
        movieDetailUseCaseMock.movieDetail = movieDetails
        movieRecomendationUseCaseMock.similarError = ErrorMock.mockError
        
        let sut = sut
        
        // when
        await sut.fetchDetails()
        
        // then
        XCTAssertFalse(sut.props.isLoading)
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
        XCTAssertEqual(sut.props.similar.count, 0)
    }
    
    func test_givenAlreadyLoadedDetails_whenFetchDetails_thenNoExtraCalls() async {
        // given
        let movieDetails = mockMovieDetail()
        let movieCast = mockMovieCast()
        
        movieDetailUseCaseMock.movieDetail = movieDetails
        movieCreditsUseCaseMock.movieCast = movieCast

        let sut = sut
        await sut.fetchDetails()

        // when
        await sut.fetchDetails()
        
        // then
        XCTAssertEqual(movieDetailUseCaseMock.callCount, 1)
        XCTAssertEqual(movieCreditsUseCaseMock.callCount, 1)
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
    var onFetch: (() -> Void)?
    var totalPages = 1
    var callCount = 0
    var totalResults = 0
    var error: Error? = nil

    func fetch(request: DiscoverMoviesRequest, page: Int) async throws -> PageResult<Movie> {
        callCount += 1
        onFetch?()
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

class MovieWatchlistUseCaseMock: MovieWatchlistUseCase {
    // Call counters
    var containsCallCount = 0
    var addCallCount = 0
    var removeCallCount = 0
    var getWatchlistCallCount = 0
    
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
        return watchlistAfterAdding ?? MovieWatchlist(movies: [])
    }
    
    func remove(movie: Movie) throws -> MovieWatchlist {
        removeCallCount += 1
        lastRemovedMovie = movie
        return watchlistAfterRemoving ?? MovieWatchlist(movies: [])
    }
    
    func getWatchlist() throws -> MovieWatchlist {
        getWatchlistCallCount += 1
        return currentWatchlist ?? MovieWatchlist(movies: [])
    }
}

class MovieSeenlistUseCaseMock: MovieSeenlistUseCase {
    // Call counters
    var containsCallCount = 0
    var addCallCount = 0
    var removeCallCount = 0
    var getWatchlistCallCount = 0
    
    // Inputs captured
    var lastAddedMovie: Movie?
    var lastRemovedMovie: Movie?
    
    // Configurable return values
    var containsResult = false
    var watchlistAfterAdding: MovieSeenList?
    var watchlistAfterRemoving: MovieSeenList?
    var currentWatchlist: MovieSeenList?
    
    func contains(movie: Movie) -> Bool {
        containsCallCount += 1
        return containsResult
    }
    
    func add(movie: Movie) throws -> MovieSeenList {
        addCallCount += 1
        lastAddedMovie = movie
        return watchlistAfterAdding ?? MovieSeenList(movies: [])
    }
    
    func remove(movie: Movie) throws -> MovieSeenList {
        removeCallCount += 1
        lastRemovedMovie = movie
        return watchlistAfterRemoving ?? MovieSeenList(movies: [])
    }
    
    func getSeenList() throws -> MovieSeenList {
        getWatchlistCallCount += 1
        return currentWatchlist ?? MovieSeenList(movies: [])
    }
}

class MovieDetailUseCaseMock: MovieDetailUseCaseProtocol {
    var callCount: Int = 0
    var movieDetail: MovieDetail?
    var error: Error?
    
    func fetchDetail(for movieID: Task_4.MovieID) async throws -> Task_4.MovieDetail {
        callCount += 1
        if let error {
            throw error
        }
        guard let movieDetail else {
            throw ErrorMock.notDefined
        }
        return movieDetail
    }
}

enum ErrorMock: Error {
    case notDefined
    case mockError
}

class MovieCreditsUseCaseMock: MovieCreditsUseCase {
    var callCount: Int = 0
    var movieCast: MovieCast?
    var error: Error?
    
    func fetchCast(movieID: Task_4.MovieID) async throws -> Task_4.MovieCast {
        callCount += 1
        if let error {
            throw error
        }
        guard let movieCast else {
            throw ErrorMock.notDefined
        }
        return movieCast
    }
}

class MovieRecomendationUseCaseMock: MovieRecomendationUseCase {
    var similarCallCount: Int = 0
    var recommendedCallCount: Int = 0
    var similarMovies: [Movie] = []
    var recommendedMovies: [Movie] = []
    var similarError: Error?
    var recommendedError: Error?
    
    func fetchSimilar(movieID: Task_4.MovieID) async throws -> [Task_4.Movie] {
        similarCallCount += 1
        if let similarError {
            throw similarError
        }
        return similarMovies
    }
    
    func fetchRecomended(movieID: Task_4.MovieID) async throws -> [Task_4.Movie] {
        recommendedCallCount += 1
        if let recommendedError {
            throw recommendedError
        }
        return recommendedMovies
    }
}

func mockMovieDetail(
    adult: Bool = false,
    backdropPath: String? = "/mockBackdrop.jpg",
    belongsToCollection: MovieDetail.Collection? = mockMovieCollection(),
    budget: Int = 100_000_000,
    genres: [MovieDetail.Genre]? = [mockGenre()],
    homepage: String? = "https://example.com",
    id: MovieID = MovieID(rawValue: 1),
    originCountry: [String] = ["US"],
    originalLanguage: String = "en",
    originalTitle: String = "Mock Original Title",
    overview: String = "This is a mock movie detail for testing purposes.",
    popularity: Double = 8.5,
    posterPath: String? = "/mockPoster.jpg",
    productionCompanies: [MovieDetail.ProductionCompany]? = [
        mockProductionCompany()
    ],
    productionCountries: [MovieDetail.ProductionCountry]? = [
        mockProductionCountry()
    ],
    releaseDate: Date = Date(),
    revenue: Int = 500_000_000,
    runtime: Int = 120,
    spokenLanguages: [MovieDetail.SpokenLanguage] = [
        mockSpokenLanguage()
    ],
    status: String = "Released",
    tagline: String = "Mock tagline here",
    title: String = "Mock Movie Detail",
    video: Bool = false,
    voteAverage: Double = 8.3,
    voteCount: Int = 1234,
    keywords: MovieDetail.Keywords? = MovieDetail.Keywords(keywords: [Keyword(id: 1, name: "mock")])
) -> MovieDetail {
    MovieDetail(
        adult: adult,
        backdropPath: backdropPath,
        belongsToCollection: belongsToCollection,
        budget: budget,
        genres: genres,
        homepage: homepage,
        id: id,
        originCountry: originCountry,
        originalLanguage: originalLanguage,
        originalTitle: originalTitle,
        overview: overview,
        popularity: popularity,
        posterPath: posterPath,
        productionCompanies: productionCompanies,
        productionCountries: productionCountries,
        releaseDate: releaseDate,
        revenue: revenue,
        runtime: runtime,
        spokenLanguages: spokenLanguages,
        status: status,
        tagline: tagline,
        title: title,
        video: video,
        voteAverage: voteAverage,
        voteCount: voteCount,
        keywords: keywords
    )
}

func mockMovieCollection(
    id: Int = 1,
    name: String = "Mock Collection",
    posterPath: String? = nil,
    backdropPath: String? = nil
) -> MovieDetail.Collection {
    MovieDetail.Collection(
        id: id,
        name: name,
        posterPath: posterPath,
        backdropPath: backdropPath
    )
}

func mockGenre(
    id: Int = 0,
    name: String = "Mock Genre"
) -> MovieDetail.Genre {
    MovieDetail.Genre(
        id: id,
        name: name
    )
}

func mockProductionCompany(
    id: Int = 1,
    logoPath: String? = nil,
    name: String = "Mock Production Company",
    originCountry: String = "US"
) -> MovieDetail.ProductionCompany {
    MovieDetail.ProductionCompany(
        id: id,
        logoPath: logoPath,
        name: name,
        originCountry: originCountry
    )
}

func mockProductionCountry(
    iso3166_1: String? = nil,
    name: String = "Mock Production Country"
) -> MovieDetail.ProductionCountry {
    MovieDetail.ProductionCountry(
        iso3166_1: iso3166_1,
        name: name
    )
}

func mockSpokenLanguage(
    englishName: String = "Mock Spoken Language in English",
    name: String = "Mock Spoken Language"
) -> MovieDetail.SpokenLanguage {
    MovieDetail.SpokenLanguage(
        englishName: englishName,
        name: name
    )
}

func mockMovieCast(
    id: Int = 1,
    cast: [Person] = [mockPerson()],
    crew: [Person] = [mockPerson()]
) -> MovieCast {
    MovieCast(
        id: id,
        cast: cast,
        crew: crew
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
