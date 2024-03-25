//
//  SCViewModelForDetail.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/18/24.
//

import Foundation

class SCViewModelForDetail: SCDetailInterface {
    
    var model: SummaryContentModel
    
    var contentTitle: String { model.entity.title ?? "제목이 없습니다." }
    
    var contentSummary: String { model.entity.summary ?? "요약이 없습니다." }
    
    var contentUrl: URL { URL(string: model.entity.url ?? "")! }
    
    var contentKeywords: [String] { model.entity.keywords }
    
    init(model: SummaryContentModel) {
        self.model = model
    }
}
