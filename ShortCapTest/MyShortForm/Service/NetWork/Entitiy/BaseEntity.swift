//
//  Base.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation

struct BaseEntity<T: Decodable>: Decodable {
    
    var result: String?
    var message: String?
    var data: T?
}
