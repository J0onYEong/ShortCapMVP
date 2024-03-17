//
//  SFViewModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

class SummaryContentViewModel {
    
    var model: SummaryContentModel {
        
        didSet {
            
            fetchCompletion?()
        }
    }
    
    var fetchCompletion: (() -> Void)?
    
    var apiFetcher: APIFetcher
    
    var sfFetcher: SFFetcher
    
    var isFetched: Bool {
        
        model.isFetched
    }
    
    init(model: SummaryContentModel, apiFetcher: APIFetcher, sfFetcher: SFFetcher) {
        self.model = model
        self.apiFetcher = apiFetcher
        self.sfFetcher = sfFetcher
    }
    
    var title: String {
        model.content.title ?? "로딩중 ..."
    }
    
    func checkIsFetched() {
        
        if !isFetched {
            
            // 요약 현황을 확인을 실행하는 url
            if let videoUrl = model.content.url {
                
                Task.detached { [weak self] in
                    
                    do {
                        
                        if let vm = self {
                            
                            let uuidForSummaryContent = try await vm.apiFetcher.requestStartingSummary(vidoeUrl: videoUrl)

                            vm.apiFetcher.requestSummaryState(uuid: uuidForSummaryContent) { [weak self] result in
                                
                                switch result {
                                case .success(let success):
                                    self?.onRequestSuccess(success)
                                case .failure(let failure):
                                    print(failure.localizedDescription)
                                    self?.onFetchRequestFailed()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func onRequestSuccess(_ newModel: SummaryContentModel) {
        
        DispatchQueue.main.async { [weak self] in
            
            if let vm = self {
                
                vm.model = newModel
                vm.model.isFetched = true
                
                // do coreData thing
                vm.sfFetcher.updateLocalSummaryContentWith(model: vm.model)
            }
        }
    }
    
    func onFetchRequestFailed() {
        
        print("요청 실패\(model.content.url ?? "url이 존재하지 않음")")
    }
}
