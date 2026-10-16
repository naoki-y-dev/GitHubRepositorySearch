import Foundation

final class FavoritesService {
    private let key = "starred_repositories"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [Repository] {
        guard let data = defaults.data(forKey: key),
              let repos = try? JSONDecoder().decode([Repository].self, from: data)
        else { return [] }
        return repos
    }

    func save(_ repos: [Repository]) {
        guard let data = try? JSONEncoder().encode(repos) else { return }
        defaults.set(data, forKey: key)
    }
}
