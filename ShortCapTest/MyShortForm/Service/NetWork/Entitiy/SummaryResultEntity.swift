//
//  SummaryResultEntity.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation

struct SummaryResultData: Decodable {
    
    var title: String?
    var description: String?
    var keywords: [String]
    var url: String?
    var summary: String?
    var address: String?
    var createdAt: String?
    var videoPk: String?
    
    enum CodingKeys: String, CodingKey {
        
       case title = "title"
       case description = "description"
       case keywords = "keywords"
       case url = "url"
       case summary = "summary"
       case address = "address"
       case createdAt = "createdAt"
       case videoPk = "video_code"
    }
    
    init(title: String? = nil, description: String? = nil, keywords: [String]=[], url: String? = nil, summary: String? = nil, address: String? = nil, createdAt: String? = nil, videoPk: String? = nil) {
        self.title = title
        self.description = description
        self.keywords = keywords
        self.url = url
        self.summary = summary
        self.address = address
        self.createdAt = createdAt
        self.videoPk = videoPk
    }
}

typealias SummaryResultEntity = BaseEntity<SummaryResultData>
