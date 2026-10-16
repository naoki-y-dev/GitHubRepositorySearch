import XCTest
@testable import GitHubRepositorySearch

final class GitHubAPIServiceTests: XCTestCase {
    private var sut: GitHubAPIService!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        sut = GitHubAPIService(session: URLSession(configuration: config))
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - searchRepositories

    func test_searchRepositories_returnsDecodedResponse() async throws {
        MockURLProtocol.requestHandler = { _ in
            let json = """
            {
                "total_count": 1,
                "items": [{
                    "id": 1, "name": "swift", "full_name": "apple/swift",
                    "description": null, "stargazers_count": 65000, "language": "C++",
                    "html_url": "https://github.com/apple/swift",
                    "owner": { "avatar_url": "https://example.com/avatar.png" }
                }]
            }
            """.data(using: .utf8)!
            return (self.response(statusCode: 200), json)
        }

        let result = try await sut.searchRepositories(query: "swift", page: 1)

        XCTAssertEqual(result.totalCount, 1)
        XCTAssertEqual(result.items.first?.name, "swift")
    }

    func test_searchRepositories_throwsRateLimitExceeded_on403() async {
        MockURLProtocol.requestHandler = { _ in (self.response(statusCode: 403), Data()) }

        do {
            _ = try await sut.searchRepositories(query: "swift", page: 1)
            XCTFail("Expected rateLimitExceeded error")
        } catch GitHubAPIError.rateLimitExceeded {
            // pass
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_searchRepositories_throwsServerError_on500() async {
        MockURLProtocol.requestHandler = { _ in (self.response(statusCode: 500), Data()) }

        do {
            _ = try await sut.searchRepositories(query: "swift", page: 1)
            XCTFail("Expected serverError")
        } catch GitHubAPIError.serverError(let code) {
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_searchRepositories_buildsCorrectURL() async throws {
        var capturedURL: URL?
        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            let json = """
            {"total_count": 0, "items": []}
            """.data(using: .utf8)!
            return (self.response(statusCode: 200), json)
        }

        _ = try await sut.searchRepositories(query: "swift ui", page: 2)

        let components = URLComponents(url: capturedURL!, resolvingAgainstBaseURL: false)!
        let items = Dictionary(uniqueKeysWithValues: components.queryItems!.map { ($0.name, $0.value!) })
        XCTAssertEqual(items["q"], "swift ui")
        XCTAssertEqual(items["page"], "2")
        XCTAssertEqual(items["per_page"], "30")
    }

    // MARK: - getRepository

    func test_getRepository_returnsDecodedRepository() async throws {
        MockURLProtocol.requestHandler = { _ in
            let json = """
            {
                "id": 1, "name": "swift", "full_name": "apple/swift",
                "description": "The Swift Programming Language",
                "stargazers_count": 65000, "subscribers_count": 3000,
                "language": "C++", "html_url": "https://github.com/apple/swift",
                "owner": { "avatar_url": "https://example.com/avatar.png" }
            }
            """.data(using: .utf8)!
            return (self.response(statusCode: 200), json)
        }

        let repo = try await sut.getRepository(owner: "apple", repo: "swift")

        XCTAssertEqual(repo.name, "swift")
        XCTAssertEqual(repo.subscribersCount, 3000)
    }

    // MARK: - Helpers

    private func response(statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.github.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}
