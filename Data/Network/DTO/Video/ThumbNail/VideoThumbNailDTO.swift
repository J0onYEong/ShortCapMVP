import Foundation

// MARK: - Welcome
struct VideoThumbNailDTO: Codable {
    let kind, etag: String?
    let items: [Item]?
    let pageInfo: PageInfo?
}

// MARK: - Item
struct Item: Codable {
    let kind, etag, id: String?
    let snippet: Snippet?
}

// MARK: - Snippet
struct Snippet: Codable {
    let publishedAt: String?
    let channelID, title, description: String?
    let thumbnails: Thumbnails?
    let channelTitle, categoryID, liveBroadcastContent: String?
    let localized: Localized?

    enum CodingKeys: String, CodingKey {
        case publishedAt
        case channelID = "channelId"
        case title, description, thumbnails, channelTitle
        case categoryID = "categoryId"
        case liveBroadcastContent, localized
    }
}

// MARK: - Localized
struct Localized: Codable {
    let title, description: String?
}

// MARK: - Thumbnails
struct Thumbnails: Codable {
    let `default`, medium, high, standard, maxres: VideoInfo?

    enum CodingKeys: String, CodingKey {
        case `default`, medium, high, standard, maxres
    }
}

// MARK: - Default
struct VideoInfo: Codable {
    let url: String?
    let width, height: Int?
}

// MARK: - PageInfo
struct PageInfo: Codable {
    let totalResults, resultsPerPage: Int?
}
