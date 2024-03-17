//
//  SummaryContentListViewModel.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation

class SummaryContentListViewModel {
    
    var model: SummaryContentListModel = [] {
        
        didSet {
            onModelIsModified?()
        }
    }
    
    var sfFetcher: SFFetcher
    
    var apiFetcher: APIFetcher
    
    var onModelIsModified: (() -> Void)?
    
    init(sfFetcher: SFFetcher, apiFetcher: APIFetcher) {
        
        self.sfFetcher = sfFetcher
        self.apiFetcher = apiFetcher
    }
    
    func fetchLocalData() {
        
        sfFetcher.getSummaryContentModels { result in
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
    
    func generateSFViewModel(index: Int) -> SummaryContentViewModel {
        
        let model = model[index]
        
        let viewModel = SummaryContentViewModel(
            model: model,
            apiFetcher: apiFetcher,
            sfFetcher: sfFetcher
        )
        
        return viewModel
    }
}
