import XCTest
@testable import GitHubRepositorySearch

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var sut: SearchViewModel!
    private var mockService: MockGitHubAPIService!

    override func setUp() {
        super.setUp()
        mockService = MockGitHubAPIService()
        sut = SearchViewModel(apiService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - search()

    func test_search_withValidQuery_returnsRepositories() async {
        let repo = Repository.mock(name: "swift", fullName: "apple/swift")
        mockService.searchResult = .success(SearchResponse(totalCount: 1, items: [repo]))
        sut.query = "swift"

        await sut.search()

        XCTAssertEqual(sut.repositories.count, 1)
        XCTAssertEqual(sut.repositories.first?.name, "swift")
        XCTAssertEqual(sut.totalCount, 1)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_search_withEmptyQuery_doesNotCallAPI() async {
        sut.query = ""
        await sut.search()
        XCTAssertEqual(mockService.searchCallCount, 0)
        XCTAssertTrue(sut.repositories.isEmpty)
    }

    func test_search_withWhitespaceOnlyQuery_doesNotCallAPI() async {
        sut.query = "   "
        await sut.search()
        XCTAssertEqual(mockService.searchCallCount, 0)
    }

    func test_search_trimsQueryBeforeSendingToAPI() async {
        mockService.searchResult = .success(SearchResponse(totalCount: 0, items: []))
        sut.query = "  swift  "
        await sut.search()
        XCTAssertEqual(mockService.lastQuery, "swift")
    }

    func test_search_alwaysStartsFromPage1() async {
        mockService.searchResult = .success(SearchResponse(totalCount: 0, items: []))
        sut.query = "swift"
        await sut.search()
        XCTAssertEqual(mockService.lastPage, 1)
    }

    func test_search_onError_setsErrorMessage() async {
        mockService.searchResult = .failure(GitHubAPIError.rateLimitExceeded)
        sut.query = "swift"
        await sut.search()
        XCTAssertTrue(sut.repositories.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - loadMore()

    func test_loadMore_appendsNextPage() async {
        let firstPage = (1...30).map { Repository.mock(id: $0) }
        let secondPage = (31...60).map { Repository.mock(id: $0) }

        mockService.searchResult = .success(SearchResponse(totalCount: 60, items: firstPage))
        sut.query = "swift"
        await sut.search()

        mockService.searchResult = .success(SearchResponse(totalCount: 60, items: secondPage))
        await sut.loadMore()

        XCTAssertEqual(sut.repositories.count, 60)
        XCTAssertEqual(mockService.lastPage, 2)
    }

    func test_loadMore_doesNotFetch_whenAllResultsLoaded() async {
        let repos = (1...10).map { Repository.mock(id: $0) }
        mockService.searchResult = .success(SearchResponse(totalCount: 10, items: repos))
        sut.query = "swift"
        await sut.search()

        let countBefore = mockService.searchCallCount
        await sut.loadMore()

        XCTAssertEqual(mockService.searchCallCount, countBefore)
    }

    func test_loadMore_setsLoadMoreFailed_onError() async {
        let repos = (1...30).map { Repository.mock(id: $0) }
        mockService.searchResult = .success(SearchResponse(totalCount: 60, items: repos))
        sut.query = "swift"
        await sut.search()

        mockService.searchResult = .failure(GitHubAPIError.rateLimitExceeded)
        await sut.loadMore()

        XCTAssertTrue(sut.loadMoreFailed)
        XCTAssertEqual(sut.repositories.count, 30) // 既存一覧は保持
        XCTAssertFalse(sut.isLoadingMore)
    }

    func test_hasMore_isFalse_whenAllResultsFetched() async {
        let repos = (1...5).map { Repository.mock(id: $0) }
        mockService.searchResult = .success(SearchResponse(totalCount: 5, items: repos))
        sut.query = "swift"
        await sut.search()

        let countBefore = mockService.searchCallCount
        await sut.loadMore()

        XCTAssertEqual(mockService.searchCallCount, countBefore)
    }

    // MARK: - clearSearch()

    func test_clearSearch_resetsAllState() async {
        let repo = Repository.mock()
        mockService.searchResult = .success(SearchResponse(totalCount: 1, items: [repo]))
        sut.query = "swift"
        await sut.search()

        sut.clearSearch()

        XCTAssertEqual(sut.query, "")
        XCTAssertTrue(sut.repositories.isEmpty)
        XCTAssertEqual(sut.totalCount, 0)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.loadMoreFailed)
    }
}
