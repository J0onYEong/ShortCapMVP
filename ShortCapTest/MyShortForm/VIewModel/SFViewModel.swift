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
    
    var apiFetcher: APIFetcher
    
    var sfFetcher: SFFetcher
    
    var isFetched: Bool {
        
        model.isFetched
    }
    
    init(model: SFModel, apiFetcher: APIFetcher, sfFetcher: SFFetcher) {
        self.model = model
        self.apiFetcher = apiFetcher
        self.sfFetcher = sfFetcher
    }
    
    var title: String {
        model.title ?? "로딩중 ..."
    }
    
    func checkIsFetched() {
        
        if !isFetched {
            
            Task.detached { [weak self] in
                
                do {
                    
                    if let vm = self {
                        
                        let sFUuid = try await vm.apiFetcher.requestSFSummary(sFUrl: vm.model.url!)

                        vm.apiFetcher.checkRequest(uuid: sFUuid) { [weak self] result in
                            
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
    
    func onRequestSuccess(_ newModel: SFModel) {
        
        DispatchQueue.main.async { [weak self] in
            
            if let vm = self {
                
                vm.model = newModel
                vm.model.isFetched = true
                
                // do coreData thing
                vm.sfFetcher.updateLocalData(model: vm.model)
            }
        }
    }
    
    func onFetchRequestFailed() {
        
        print("요청 실패\(model.url!)")
    }
}
