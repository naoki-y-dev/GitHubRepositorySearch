import Foundation

protocol GitHubAPIServiceProtocol {
    func searchRepositories(query: String, page: Int) async throws -> SearchResponse
    func getRepository(owner: String, repo: String) async throws -> Repository
}

enum GitHubAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case rateLimitExceeded
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "サーバーからの応答が不正です"
        case .rateLimitExceeded:
            return "APIのレート制限に達しました。しばらく待ってから再試行してください"
        case .serverError(let code):
            return "サーバーエラーが発生しました（コード: \(code)）"
        }
    }
}

final class GitHubAPIService: GitHubAPIServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.github.com"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchRepositories(query: String, page: Int) async throws -> SearchResponse {
        guard var components = URLComponents(string: "\(baseURL)/search/repositories") else {
            throw GitHubAPIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "per_page", value: "30"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: "desc"),
        ]
        return try await fetch(SearchResponse.self, from: components.url)
    }

    func getRepository(owner: String, repo: String) async throws -> Repository {
        let url = URL(string: "\(baseURL)/repos/\(owner)/\(repo)")
        return try await fetch(Repository.self, from: url)
    }

    // MARK: - Private

    private func fetch<T: Decodable>(_ type: T.Type, from url: URL?) async throws -> T {
        guard let url else { throw GitHubAPIError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw GitHubAPIError.invalidResponse
        }
        switch http.statusCode {
        case 200:
            return try JSONDecoder().decode(T.self, from: data)
        case 403:
            throw GitHubAPIError.rateLimitExceeded
        default:
            throw GitHubAPIError.serverError(http.statusCode)
        }
    }
}
