import Foundation

@MainActor
final class RepositoryDetailViewModel: ObservableObject {
    @Published private(set) var detail: Repository?
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?

    private let repository: Repository
    private let apiService: GitHubAPIServiceProtocol

    var displayRepo: Repository { detail ?? repository }

    init(repository: Repository, apiService: GitHubAPIServiceProtocol = GitHubAPIService()) {
        self.repository = repository
        self.apiService = apiService
    }

    func load() async {
        let parts = repository.fullName.split(separator: "/").map(String.init)
        guard parts.count == 2 else { isLoading = false; return }

        do {
            detail = try await apiService.getRepository(owner: parts[0], repo: parts[1])
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
