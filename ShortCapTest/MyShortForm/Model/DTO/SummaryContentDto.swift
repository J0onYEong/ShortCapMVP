//
//  SummaryContentDto.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/17/24.
//

import Foundation

struct SummaryContentDto: Decodable {
    
    let uuid: String?
    let title: String?
    let description: String?
    let keywords: [String]?
    let url: String?
    let summary: String?
    let address: String?
    let createdAt: String?
    
    init(
        uuid: String? = nil,
        title: String? = nil,
        description: String? = nil,
        keywords: [String]? = nil,
        url: String?,
        summary: String? = nil,
        address: String? = nil,
        createdAt: String? = nil
    ) {
        self.uuid = uuid
        self.title = title
        self.description = description
        self.keywords = keywords
        self.url = url
        self.summary = summary
        self.address = address
        self.createdAt = createdAt
    }
    
    enum CodingKeys: CodingKey {
        case uuid
        case title
        case description
        case keywords
        case url
        case summary
        case address
        case createdAt
    }
}
