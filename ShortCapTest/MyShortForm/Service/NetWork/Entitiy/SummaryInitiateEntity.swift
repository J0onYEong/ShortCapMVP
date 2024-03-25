//
//  SummaryInitiateEntitiy.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation

struct SummaryVideoCodeData: Decodable {
    
    var videoCode: String
}

typealias SummaryInitiateEntity = BaseEntity<SummaryVideoCodeData>
