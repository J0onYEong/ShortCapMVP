//
//  SCDetailInterface.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/18/24.
//

import Foundation

protocol SCDetailInterface {
    
    var contentTitle: String { get }
    
    var contentSummary: String { get }
    
    var contentUrl: URL { get }
    
    var contentKeywords: [String] { get }
}
