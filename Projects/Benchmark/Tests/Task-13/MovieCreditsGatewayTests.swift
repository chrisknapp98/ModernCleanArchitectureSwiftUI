import XCTest
@testable import Task_13
@testable import HTTPClient
@testable import MoviesDomain

final class MovieCreditsGatewayTests: XCTestCase {
    
    private var dataFetchingMock: DataFetchingMock!

    override func setUp() {
        super.setUp()
        dataFetchingMock = DataFetchingMock()
    }
    
    override func tearDown() {
        dataFetchingMock = nil
        super.tearDown()
    }
    
    private var sut: Task_13.MovieCreditsGateway {
        MovieCreditsGateway(client: dataFetchingMock)
    }
    
    func test_givenValidData_whenFetchingMovies_thenReturnsData() async throws {
        // given
        let castId = 777
        let cast = mockMovieCast(id: castId)

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(cast)
        dataFetchingMock.data = jsonData

        let sut = sut

        // when
        let fetchedCast = try await sut.fetchCast(movieID: 0)

        // then
        XCTAssertEqual(fetchedCast.id, castId)
        XCTAssertEqual(dataFetchingMock.callCount, 1)
    }
    
    func test_givenAnyError_whenFetchingMovies_thenRethrowsError() async throws {
        // given
        let thrownError = ErrorMock.mockError
        dataFetchingMock.error = thrownError

        let sut = sut

        // when
        do {
            _ = try await sut.fetchCast(movieID: 0)
            XCTFail("Expected to throw an error, but did not.")
        } catch {
            // then
            XCTAssertTrue(true)
            XCTAssertEqual(dataFetchingMock.callCount, 1)
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

func mockMovieCast(
    id: Int = 0,
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
