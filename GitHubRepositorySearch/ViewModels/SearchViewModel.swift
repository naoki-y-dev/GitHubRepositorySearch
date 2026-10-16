import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var repositories: [Repository] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var loadMoreFailed: Bool = false
    @Published private(set) var totalCount: Int = 0

    private var hasMore = true
    private var currentPage = 1
    private let perPage = 30
    private let apiService: GitHubAPIServiceProtocol

    init(apiService: GitHubAPIServiceProtocol = GitHubAPIService()) {
        self.apiService = apiService
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            repositories = []
            totalCount = 0
            return
        }

        isLoading = true
        errorMessage = nil
        loadMoreFailed = false
        currentPage = 1

        do {
            let response = try await apiService.searchRepositories(query: trimmed, page: 1)
            repositories = response.items
            totalCount = response.totalCount
            hasMore = repositories.count < totalCount
        } catch {
            errorMessage = error.localizedDescription
            repositories = []
            totalCount = 0
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore, !isLoading else { return }
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isLoadingMore = true
        loadMoreFailed = false
        let nextPage = currentPage + 1

        do {
            let response = try await apiService.searchRepositories(query: trimmed, page: nextPage)
            repositories.append(contentsOf: response.items)
            currentPage = nextPage
            hasMore = repositories.count < totalCount
        } catch {
            loadMoreFailed = true
        }

        isLoadingMore = false
    }

    func clearSearch() {
        query = ""
        repositories = []
        totalCount = 0
        errorMessage = nil
        loadMoreFailed = false
        currentPage = 1
        hasMore = true
    }
}
