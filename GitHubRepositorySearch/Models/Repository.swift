import Foundation

struct Repository: Identifiable, Codable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stargazersCount: Int
    let subscribersCount: Int?
    let language: String?
    let htmlUrl: String
    let owner: Owner

    var avatarUrl: String { owner.avatarUrl }

    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case fullName = "full_name"
        case stargazersCount = "stargazers_count"
        case subscribersCount = "subscribers_count"
        case htmlUrl = "html_url"
        case owner
    }

    struct Owner: Codable {
        let avatarUrl: String
        enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatar_url"
        }
    }
}

struct SearchResponse: Decodable {
    let totalCount: Int
    let items: [Repository]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
