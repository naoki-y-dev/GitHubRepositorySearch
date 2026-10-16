import XCTest
@testable import GitHubRepositorySearch

final class RepositoryDecodingTests: XCTestCase {

    func test_repository_decodesFromJSON() throws {
        let json = """
        {
            "id": 1,
            "name": "swift",
            "full_name": "apple/swift",
            "description": "The Swift Programming Language",
            "stargazers_count": 65000,
            "subscribers_count": 3000,
            "language": "C++",
            "html_url": "https://github.com/apple/swift",
            "owner": { "avatar_url": "https://example.com/avatar.png" }
        }
        """.data(using: .utf8)!

        let repo = try JSONDecoder().decode(Repository.self, from: json)

        XCTAssertEqual(repo.id, 1)
        XCTAssertEqual(repo.name, "swift")
        XCTAssertEqual(repo.fullName, "apple/swift")
        XCTAssertEqual(repo.description, "The Swift Programming Language")
        XCTAssertEqual(repo.stargazersCount, 65000)
        XCTAssertEqual(repo.subscribersCount, 3000)
        XCTAssertEqual(repo.language, "C++")
        XCTAssertEqual(repo.avatarUrl, "https://example.com/avatar.png")
    }

    func test_repository_subscribersCount_isNil_whenAbsent() throws {
        let json = """
        {
            "id": 1,
            "name": "repo",
            "full_name": "user/repo",
            "description": null,
            "stargazers_count": 10,
            "language": null,
            "html_url": "https://github.com/user/repo",
            "owner": { "avatar_url": "https://example.com/avatar.png" }
        }
        """.data(using: .utf8)!

        let repo = try JSONDecoder().decode(Repository.self, from: json)
        XCTAssertNil(repo.subscribersCount)
        XCTAssertNil(repo.description)
        XCTAssertNil(repo.language)
    }

    func test_searchResponse_decodesCorrectly() throws {
        let json = """
        {
            "total_count": 2,
            "items": [
                {
                    "id": 1, "name": "repo1", "full_name": "user/repo1",
                    "description": null, "stargazers_count": 10, "language": null,
                    "html_url": "https://github.com/user/repo1",
                    "owner": { "avatar_url": "https://example.com/a.png" }
                },
                {
                    "id": 2, "name": "repo2", "full_name": "user/repo2",
                    "description": null, "stargazers_count": 20, "language": "Swift",
                    "html_url": "https://github.com/user/repo2",
                    "owner": { "avatar_url": "https://example.com/b.png" }
                }
            ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(SearchResponse.self, from: json)

        XCTAssertEqual(response.totalCount, 2)
        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.items[1].language, "Swift")
    }
}
