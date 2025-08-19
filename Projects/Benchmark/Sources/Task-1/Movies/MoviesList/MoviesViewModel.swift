import Dependencies
import MoviesDomain
import SwiftUI
import UI

@MainActor
@Observable public final class MoviesViewModel {
    var movies: [Movie] = []
    
    @ObservationIgnored
    @Dependency(\.discoverMoviesUseCase)
    private var useCase: DiscoverMoviesUseCaseProtocol
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    @ObservationIgnored
    private let coordinator: MoviesCoordinator

    var request: DiscoverMoviesRequest
    
    public init(coordinator: MoviesCoordinator) {
        self.request = .nowPlaying
        self.coordinator = coordinator
    }
    
    func fetch() async {
        do {
            let page = try await useCase.discoverMovies(request: request)
            movies = page.results
            
            if page.totalResults == 0 {
                errorToast.show(message: "No movies found for the selected filters.")
            }
        } catch {
            errorToast.show(error: error)
        }
    }
    
    func filter(request: DiscoverMoviesRequest) {
        self.request = request
        Task {
            await fetch()
        }
    }
    
    func didSelect(movie: Movie) {
        coordinator.showDetail(for: movie)
    }
}
