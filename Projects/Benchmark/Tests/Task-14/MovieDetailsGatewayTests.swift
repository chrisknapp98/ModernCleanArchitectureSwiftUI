import XCTest
@testable import Task_14
@testable import MoviesDomain

final class MovieDetailsGatewayTests: XCTestCase {
    
    private var dataFetchingMock: DataFetchingMock!

    override func setUp() {
        super.setUp()
        dataFetchingMock = DataFetchingMock()
    }
    
    override func tearDown() {
        dataFetchingMock = nil
        super.tearDown()
    }
    
    private var sut: Task_14.MovieDetailsGateway {
        MovieDetailsGateway(client: dataFetchingMock)
    }
    
    func test_givenValidData_whenFetchingMovies_thenReturnsData() async throws {
        // given
        let movieName = "Test Movie"
        let movieDetails = mockMovieDetail(title: movieName)
        let movieDetailsDTO = MovieDetailDTO(movieDetails)

        let encoder = makeMoviesEncoder()
        let jsonData = try encoder.encode(movieDetailsDTO)
        dataFetchingMock.data = jsonData

        let sut = sut

        // when
        let result = try await sut.fetchDetail(for: 0)
        
        // then
        XCTAssertEqual(result.title, movieName)
        XCTAssertEqual(dataFetchingMock.callCount, 1)
    }
    
    func test_givenNotConnectedToInternetNetworkError_whenFetchingMovies_thenThrowsError() async throws {
        // given
        let thrownError = NetworkError.notConnectedToInternet
        dataFetchingMock.error = thrownError

        let sut = sut

        // when
        do {
            _ = try await sut.fetchDetail(for: 0)
            XCTFail("Expected to throw an error, but did not.")
        } catch is OfflineError {
            // then
            XCTAssertTrue(true)
            XCTAssertEqual(dataFetchingMock.callCount, 1)
        } catch {
            XCTFail("Expected OfflineError, but got \(error).")
        }
    }
    
    func test_givenCancelledNetworkError_whenFetchingMovies_thenThrowsError() async throws {
        // given
        let thrownError = NetworkError.cancelled
        dataFetchingMock.error = thrownError

        let sut = sut

        // when
        do {
            _ = try await sut.fetchDetail(for: 0)
            XCTFail("Expected to throw an error, but did not.")
        } catch let error as NetworkError {
            // then
            switch error {
            case .cancelled:
                XCTAssertTrue(true)
                XCTAssertEqual(dataFetchingMock.callCount, 1)
            default:
                XCTFail("Expected NetworkError.cancelled, but got \(error).")
            }
        } catch {
            XCTFail("Expected OfflineError, but got \(error).")
        }
    }
    
    func test_givenInvalidResponseNetworkError_whenFetchingMovies_thenThrowsError() async throws {
        // given
        let thrownError = NetworkError.invalidResponse
        dataFetchingMock.error = thrownError

        let sut = sut

        // when
        do {
            _ = try await sut.fetchDetail(for: 0)
            XCTFail("Expected to throw an error, but did not.")
        } catch let error as NetworkError {
            // then
            switch error {
            case .invalidResponse:
                XCTAssertTrue(true)
                XCTAssertEqual(dataFetchingMock.callCount, 1)
            default:
                XCTFail("Expected NetworkError.cancelled, but got \(error).")
            }
        } catch {
            XCTFail("Expected OfflineError, but got \(error).")
        }
    }
    
    func test_givenAnyNetworkError_whenFetchingMovies_thenThrowsError() async throws {
        // given
        let thrownError = NetworkError.networkError(ErrorMock.mockError)
        dataFetchingMock.error = thrownError

        let sut = sut

        // when
        do {
            _ = try await sut.fetchDetail(for: 0)
            XCTFail("Expected to throw an error, but did not.")
        } catch let error as NetworkError {
            // then
            switch error {
            case .networkError(_):
                XCTAssertTrue(true)
                XCTAssertEqual(dataFetchingMock.callCount, 1)
            default:
                XCTFail("Expected NetworkError.cancelled, but got \(error).")
            }
        } catch {
            XCTFail("Expected OfflineError, but got \(error).")
        }
    }
    
    func test_givenAnyError_whenFetchingMovies_thenRethrowsError() async throws {
        // given
        let thrownError = ErrorMock.mockError
        dataFetchingMock.error = thrownError

        let sut = sut

        // when
        do {
            _ = try await sut.fetchDetail(for: 0)
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

private func makeMoviesEncoder() -> JSONEncoder {
    let df = DateFormatter()
    df.calendar = Calendar(identifier: .gregorian)
    df.locale = Locale(identifier: "en_US_POSIX")
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.dateFormat = "YYYY-MM-DD"

    let enc = JSONEncoder()
    enc.keyEncodingStrategy = .convertToSnakeCase
    enc.userInfo[.dateFormatter] = df
    enc.dateEncodingStrategy = .formatted(df)
    return enc
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

// Super ugly but needed if production code should be untouched
struct MovieDetailDTO: Encodable {
    var adult: Bool
    var backdropPath: String?
    var belongsToCollection: CollectionDTO?
    var budget: Int
    var genres: [GenreDTO]?
    var homepage: String?
    var id: MovieID
    var originCountry: [String]
    var originalLanguage: String
    var originalTitle: String
    var overview: String
    var popularity: Double
    var posterPath: String?
    var productionCompanies: [ProductionCompanyDTO]?
    var productionCountries: [ProductionCountryDTO]?
    var releaseDate: Date
    var revenue: Int
    var runtime: Int
    var spokenLanguages: [SpokenLanguageDTO]
    var status: String
    var tagline: String
    var title: String
    var video: Bool
    var voteAverage: Double
    var voteCount: Int
    var keywords: KeywordsDTO?
}

extension MovieDetailDTO {
    struct CollectionDTO: Encodable {
        var id: Int
        var name: String
        var posterPath: String?
        var backdropPath: String?
    }

    struct GenreDTO: Encodable {
        var id: Int
        var name: String
    }

    struct ProductionCompanyDTO: Encodable {
        var id: Int
        var logoPath: String?
        var name: String
        var originCountry: String
    }

    struct ProductionCountryDTO: Encodable {
        var iso3166_1: String?
        var name: String
    }

    struct SpokenLanguageDTO: Encodable {
        var englishName: String
        var name: String
    }

    struct KeywordsDTO: Encodable {
        var keywords: [Keyword]?
    }
}

// Mapper from production model → DTO (handy if you construct MovieDetail first)
extension MovieDetailDTO {
    init(_ m: MovieDetail) {
        self.adult = m.adult
        self.backdropPath = m.backdropPath
        self.belongsToCollection = m.belongsToCollection.map {
            .init(id: $0.id, name: $0.name, posterPath: $0.posterPath, backdropPath: $0.backdropPath)
        }
        self.budget = m.budget
        self.genres = m.genres?.map { .init(id: $0.id, name: $0.name) }
        self.homepage = m.homepage
        self.id = m.id
        self.originCountry = m.originCountry
        self.originalLanguage = m.originalLanguage
        self.originalTitle = m.originalTitle
        self.overview = m.overview
        self.popularity = m.popularity
        self.posterPath = m.posterPath
        self.productionCompanies = m.productionCompanies?.map {
            .init(id: $0.id, logoPath: $0.logoPath, name: $0.name, originCountry: $0.originCountry)
        }
        self.productionCountries = m.productionCountries?.map {
            .init(iso3166_1: $0.iso3166_1, name: $0.name)
        }
        self.releaseDate = m.releaseDate
        self.revenue = m.revenue
        self.runtime = m.runtime
        self.spokenLanguages = m.spokenLanguages.map { .init(englishName: $0.englishName, name: $0.name) }
        self.status = m.status
        self.tagline = m.tagline
        self.title = m.title
        self.video = m.video
        self.voteAverage = m.voteAverage
        self.voteCount = m.voteCount
        self.keywords = m.keywords.map { .init(keywords: $0.keywords) }
    }
}
