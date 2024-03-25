//
//  SummaryStatusEntity.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation

struct SummaryStatusData: Decodable {
    
    var status: String
    var videoPk: Int
    
    enum CodingKeys: String, CodingKey {
        
        case status = "status"
        case videoPk = "videoSummaryId"
    }
}

typealias SummaryStatusEntity = BaseEntity<SummaryStatusData>
