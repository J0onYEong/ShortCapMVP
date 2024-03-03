//
//  SSFModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

struct SSFModel: Decodable {
    
    let uuid: String?
    let title: String?
    let description: String?
    let keywords: [String]?
    let url: String?
    let summary: String?
    let address: String?
    let createdAt: String?
}
