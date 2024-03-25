//
//  SummaryService.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation
import Combine

typealias DefaultSummaryService = BaseService<SummaryAPI>

protocol SummaryService {
    
    func initiateSummary(videoUrl: String) -> AnyPublisher<SummaryInitiateEntity, Error>
    func getSummaryStatus(videoId: String) -> AnyPublisher<SummaryStatusEntity, Error>
    func getSummaryResult(videoPk: String) -> AnyPublisher<SummaryResultEntity, Error>
}

extension DefaultSummaryService: SummaryService {
    
    func initiateSummary(videoUrl: String) -> AnyPublisher<SummaryInitiateEntity, Error> {
        
        makeRequest(.excute(url: videoUrl))
    }
    
    func getSummaryStatus(videoId: String) -> AnyPublisher<SummaryStatusEntity, Error> {
        
        makeRequest(.check(videoId: videoId))
    }
    
    func getSummaryResult(videoPk: String) -> AnyPublisher<SummaryResultEntity, Error> {
        
        makeRequest(.data(pk: videoPk))
    }
}
