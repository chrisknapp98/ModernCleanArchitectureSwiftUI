import XCTest
import Dependencies
@testable import Task_10
@testable import UI

@MainActor
class PersonDetailsViewViewModelTests: XCTestCase {
    
    private var errorToastCoordinator: ErrorToastCoordinatorMock!
    private var personDetailsUseCaseMock: PersonDetailsUseCaseMock!

    private var sut: PersonDetailsViewViewModel {
        withDependencies {
            $0.errorToastCoordinator = errorToastCoordinator
            $0.personDetailsUseCase = personDetailsUseCaseMock
        } operation: {
            return PersonDetailsViewViewModel(person: mockPerson())
        }
    }
    
    override func setUp() {
        super.setUp()
        errorToastCoordinator = ErrorToastCoordinatorMock()
        personDetailsUseCaseMock = PersonDetailsUseCaseMock()
    }
    
    override func tearDown() {
        errorToastCoordinator = nil
        personDetailsUseCaseMock = nil
        super.tearDown()
    }
    
    func test_givenPersonDetails_whenFetchDetails_thenPersonDetails() async {
        // given
        let name = "Mock Person Details"
        let personDetails = mockPersonDetails(name: name)
        personDetailsUseCaseMock.personDetails = personDetails
        let sut = sut
        
        // when
        await sut.fetch()
        
        // then
        XCTAssertEqual(sut.props.details?.name, personDetails.name)
        XCTAssertEqual(errorToastCoordinator.callCount, 0)
    }
    
    func test_givenError_whenFetchDetails_thenShowError() async {
        // given
        let error = ErrorMock.mockError
        personDetailsUseCaseMock.error = error
        let sut = sut
        
        // when
        await sut.fetch()
        
        // then
        XCTAssertEqual(errorToastCoordinator.callCount, 1)
        XCTAssertNil(sut.props.details)
    }
    
}

class ErrorToastCoordinatorMock: ErrorToastCoordinator {
    var callCount = 0
    
    override func show() {
        callCount += 1
        super.show()
    }
}

enum ErrorMock: Error {
    case notDefined
    case mockError
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

class PersonDetailsUseCaseMock: PersonDetailsUseCase {
    var callCount: Int = 0
    var error: Error?
    var personDetails: PersonDetails?
    
    func fetchPersonDetails(with id: PersonID) async throws -> PersonDetails {
        callCount += 1
        if let error {
            throw error
        }
        guard let personDetails else {
            throw ErrorMock.notDefined
        }
        return personDetails
    }
}

func mockPersonDetails(
    adult: Bool = true,
    alsoKnownAs: [String] = [],
    biography: String = "biography",
    gender: Int = 0,
    id: PersonID = 0,
    knownForDepartment: String = "known for department",
    name: String = "Mock Name",
    popularity: Double = 50.0,
    images: PersonDetails.Images = mockPersonDetailsImages()
) -> PersonDetails {
    PersonDetails(
        adult: adult,
        alsoKnownAs: alsoKnownAs,
        biography: biography,
        gender: gender,
        id: id,
        knownForDepartment: knownForDepartment,
        name: name,
        popularity: popularity,
        images: images
    )
}

func mockPersonDetailsImages(
    profiles: [PersonDetails.Image] = [mockPersonDetailsImage()]
) -> PersonDetails.Images {
    PersonDetails.Images(
        profiles: profiles
    )
}

func mockPersonDetailsImage(
    filePath: String = "/mockProfile.jpg"
) -> PersonDetails.Image {
    PersonDetails.Image(
        filePath: filePath
    )
}
