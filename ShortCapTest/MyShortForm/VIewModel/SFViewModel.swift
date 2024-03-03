//
//  SFViewModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

class SFViewModel {
    
    var model: SFModel {
        
        didSet {
            
            fetchCompletion?()
        }
    }
    
    var fetchCompletion: (() -> Void)?
    
    var fetcher: APIFetcher
    
    var isFetched: Bool {
        
        model.isFetched
    }
    
    init(model: SFModel, fetcher: APIFetcher) {
        self.model = model
        self.fetcher = fetcher
    }
    
    var title: String {
        model.title ?? "로딩중 ..."
    }
    
    func checkIsFetched() {
        
        if !isFetched {
            
            Task.detached {
                
                do {
                    
                    let sFUuid = try await self.fetcher.requestSFSummary(sFUrl: self.model.url!)

                    self.fetcher.checkRequest(uuid: sFUuid) { result in
                        
                        switch result {
                        case .success(let success):
                            self.onRequestSuccess(success)
                        case .failure(let failure):
                            print(failure.localizedDescription)
                            self.onFetchRequestFailed()
                        }
                    }
                }
            }
        }
    }
    
    func onRequestSuccess(_ newModel: SFModel) {
        
        DispatchQueue.main.async {
            
            self.model = newModel
            self.model.isFetched = true
            
            // do coreData thing
        }
    }
    
    func onFetchRequestFailed() {
        
        print("요청 실패\(model.url!)")
    }
}
