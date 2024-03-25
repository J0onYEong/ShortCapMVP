//
//  SummaryContentModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

struct SummaryContentModel {
    
    let entity: SummaryResultData
    
    var isFetched: Bool = false
    
    init(entity: SummaryResultData, isFetched: Bool = false) {
        self.entity = entity
        self.isFetched = isFetched
    }
}

typealias SummaryContentListModel = [SummaryContentModel]
