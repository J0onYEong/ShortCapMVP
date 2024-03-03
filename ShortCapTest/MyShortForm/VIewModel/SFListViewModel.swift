//
//  SFListViewModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

class SFListViewModel {
    
    var model: [SFModel] = [] {
        
        didSet {
            onModelIsModified?()
        }
    }
    
    var fetcher: SFFetcher
    
    var apiFetcher: APIFetcher
    
    var onModelIsModified: (() -> Void)?
    
    init(fetcher: SFFetcher, apiFetcher: APIFetcher) {
        
        self.fetcher = fetcher
        self.apiFetcher = apiFetcher
    }
    
    func fetchCellData() {
        
        fetcher.getSFModels { result in
            switch result {
            case .success(let success):
                
                DispatchQueue.main.async {
                    
                    self.model = success
                }
            case .failure(let failure):
                
                print(failure)
            }
        }
    }
    
    func generateSFViewModel(index: Int) -> SFViewModel {
        
        let model = model[index]
        
        let viewModel = SFViewModel(model: model, fetcher: apiFetcher)
        
        return viewModel
    }
}
