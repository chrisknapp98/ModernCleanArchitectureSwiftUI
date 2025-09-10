import Dependencies
import MoviesDomain
import SwiftUI
import UI

@MainActor
@Observable
public final class MovieDetailViewModel {
    struct Props: Equatable {
        var details: MovieDetail?
        var cast: MovieCast?
        var isInWatchlist: Bool = false
        var isInSeenlist: Bool = false
        var isInCustomList: Bool = false
        var recommended: [Movie] = []
        var similar: [Movie] = []
        var isLoading: Bool = true
    }

    @ObservationIgnored
    @Dependency(\.movieDetailUseCase)
    private var movieDetailsUseCase

    @ObservationIgnored
    @Dependency(\.movieCreditsUseCase)
    private var movieCreditsUseCase

    @ObservationIgnored
    @Dependency(\.movieRecomendationUseCase)
    private var movieRecomendationUseCase
  
    @ObservationIgnored
    @Dependency(\.movieWatchlistUseCase)
    private var movieWatchlistUseCase: MovieWatchlistUseCase
  
    @ObservationIgnored
    @Dependency(\.movieSeenlistUseCase)
    private var movieSeenlistUseCase: MovieSeenlistUseCase
    
    @ObservationIgnored
    private var coordinator: any MoviesCoordinator
    
    @ObservationIgnored
    @Dependency(\.errorToastCoordinator)
    private var errorToast
    
    private(set) var props = Props()
    
    public let movie: Movie

    public init(movie: Movie, coordinator: any MoviesCoordinator) {
        self.movie = movie
        self.coordinator = coordinator
    }

    func fetchDetails() async {
        guard shouldLoad else { return }
        
        props.isLoading = true
        
        do {
            props.details = try await movieDetailsUseCase.fetchDetails(for: movie.id)
            props.cast = try await movieCreditsUseCase.fetchCredits(for: movie.id)
            props.recommended = try await movieRecomendationUseCase.fetchRecommended(for: movie.id)
            props.similar = try await movieRecomendationUseCase.fetchSimilar(for: movie.id)
            props.isInWatchlist = try movieWatchlistUseCase.contains(movie: movie)
            props.isInSeenlist = try movieSeenlistUseCase.contains(movie: movie)
        } catch {
            errorToast.show()
        }
        
        props.isLoading = false
    }
    
    func didTap(movie: Movie) {
        coordinator.showDetail(for: movie)
    }
    
    func didTap(person: Person) {
        coordinator.showDetail(for: person)
    }
  
    func addToWatchlist() {
        do {
            if movieWatchlistUseCase.contains(movie: movie) {
                try movieWatchlistUseCase.remove(movie: movie)
                props.isInWatchlist = false
            } else {
                try movieWatchlistUseCase.add(movie: movie)
                props.isInWatchlist = true
            }
        } catch {
            errorToast.show()
        }
    }
  
    func addToSeenList() {
        do {
            if movieSeenlistUseCase.contains(movie: movie) {
                try movieSeenlistUseCase.remove(movie: movie)
                props.isInSeenlist = false
            } else {
                try movieSeenlistUseCase.add(movie: movie)
                props.isInSeenlist = true
            }
        } catch {
            errorToast.show()
        }
    }
  
    func didTapList() {
        coordinator.showAddMovieToCustomList(for: movie)
    }
  
    private var shouldLoad: Bool {
        props.details == nil && props.cast == nil
    }
}
