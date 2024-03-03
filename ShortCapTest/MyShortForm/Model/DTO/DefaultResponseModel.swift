//
//  DefaultResponseModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

struct DefaultResponseModel<T: Decodable>: Decodable {
    
    let result: String?
    let message: String?
    let data: T?
}
