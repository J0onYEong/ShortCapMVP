//
//  SFModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

struct SFModel: Decodable {
    
    let uuid: String?
    let title: String?
    let description: String?
    let keywords: [String]?
    let url: String?
    let summary: String?
    let address: String?
    let createdAt: String?
    
    var isFetched: Bool = false
    
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
