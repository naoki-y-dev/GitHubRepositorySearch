import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [Repository] = []

    private let service: FavoritesService

    init(service: FavoritesService = FavoritesService()) {
        self.service = service
        favorites = service.load()
    }

    func isFavorite(_ repo: Repository) -> Bool {
        favorites.contains { $0.id == repo.id }
    }

    func toggle(_ repo: Repository) {
        if isFavorite(repo) {
            favorites.removeAll { $0.id == repo.id }
        } else {
            favorites.insert(repo, at: 0)
        }
        service.save(favorites)
    }
}
