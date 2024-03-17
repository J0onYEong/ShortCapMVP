//
//  SummaryContentModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

struct SummaryContentModel {
    
    let content: SummaryContentDto
    
    var isFetched: Bool = false
}

typealias SummaryContentListModel = [SummaryContentModel]
