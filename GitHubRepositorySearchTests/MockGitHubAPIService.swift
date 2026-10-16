import Foundation
@testable import GitHubRepositorySearch

final class MockGitHubAPIService: GitHubAPIServiceProtocol {
    var searchResult: Result<SearchResponse, Error> = .success(SearchResponse(totalCount: 0, items: []))
    var detailResult: Result<Repository, Error> = .success(.mock())
    var searchCallCount = 0
    var lastQuery: String?
    var lastPage: Int?

    func searchRepositories(query: String, page: Int) async throws -> SearchResponse {
        searchCallCount += 1
        lastQuery = query
        lastPage = page
        return try searchResult.get()
    }

    func getRepository(owner: String, repo: String) async throws -> Repository {
        return try detailResult.get()
    }
}

// MARK: - Test Helpers

extension Repository {
    static func mock(
        id: Int = 1,
        name: String = "test-repo",
        fullName: String = "user/test-repo",
        description: String? = "Test repository",
        stargazersCount: Int = 100,
        subscribersCount: Int? = 10,
        language: String? = "Swift",
        htmlUrl: String = "https://github.com/user/test-repo"
    ) -> Repository {
        Repository(
            id: id,
            name: name,
            fullName: fullName,
            description: description,
            stargazersCount: stargazersCount,
            subscribersCount: subscribersCount,
            language: language,
            htmlUrl: htmlUrl,
            owner: Owner(avatarUrl: "https://example.com/avatar.png")
        )
    }
}
