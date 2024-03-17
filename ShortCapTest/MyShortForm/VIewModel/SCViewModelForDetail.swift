//
//  SCViewModelForDetail.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/18/24.
//

import Foundation

class SCViewModelForDetail: SCDetailInterface {
    
    var model: SummaryContentModel
    
    var contentTitle: String { model.content.title ?? "제목이 없습니다." }
    
    var contentSummary: String { model.content.summary ?? "요약이 없습니다." }
    
    var contentUrl: URL { URL(string: model.content.url ?? "")! }
    
    var contentKeywords: [String] {
        
        model.content.keywords ?? []
    }
    
    init(model: SummaryContentModel) {
        self.model = model
    }
}
