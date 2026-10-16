import XCTest
@testable import GitHubRepositorySearch

@MainActor
final class RepositoryDetailViewModelTests: XCTestCase {
    private var mockService: MockGitHubAPIService!

    override func setUp() {
        super.setUp()
        mockService = MockGitHubAPIService()
    }

    override func tearDown() {
        mockService = nil
        super.tearDown()
    }

    func test_load_fetchesDetailAndUpdatesDisplayRepo() async {
        let base = Repository.mock(id: 1, name: "swift", fullName: "apple/swift", subscribersCount: nil)
        let detailed = Repository.mock(id: 1, name: "swift", fullName: "apple/swift", subscribersCount: 3000)
        mockService.detailResult = .success(detailed)

        let sut = RepositoryDetailViewModel(repository: base, apiService: mockService)
        await sut.load()

        XCTAssertEqual(sut.displayRepo.subscribersCount, 3000)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_load_setsErrorMessage_onFailure() async {
        mockService.detailResult = .failure(GitHubAPIError.serverError(500))
        let sut = RepositoryDetailViewModel(
            repository: .mock(fullName: "apple/swift"),
            apiService: mockService
        )

        await sut.load()

        XCTAssertNil(sut.detail)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }

    func test_displayRepo_fallsBackToOriginal_whileLoading() {
        let base = Repository.mock(name: "swift")
        let sut = RepositoryDetailViewModel(repository: base, apiService: mockService)

        XCTAssertEqual(sut.displayRepo.name, "swift")
        XCTAssertTrue(sut.isLoading)
    }

    func test_load_handlesInvalidFullName() async {
        let sut = RepositoryDetailViewModel(
            repository: .mock(fullName: "invalid-no-slash"),
            apiService: mockService
        )

        await sut.load()

        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockService.searchCallCount, 0)
    }
}
